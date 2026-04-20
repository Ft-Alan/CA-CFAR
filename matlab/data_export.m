%editing for vivado exporting
resetglobalfimath
F = fimath( ...
    'RoundingMethod','Floor', ...
    'OverflowAction','Saturate', ...
    'ProductMode','FullPrecision', ...
    'SumMode','FullPrecision');

%Noise signal generation
N = 8192;
Pn = 1;
M = 4; % No. of antennas
power_s = fi(zeros(1,N), 0, 20, 12, 'fimath', F);

w = [1; -1j; -1; 1j];
w_fp = fi(w, 1, 18, 12,'fimath', F);
burst_indices = 200:500:(N-200);
alpha = fi(4.54, 0, 16, 12, 'fimath', F); 

rng(42); %seed value
noise1 = sqrt(Pn/2) * (randn(M,N) + 1j*randn(M,N));

noise1 = noise1 - mean(noise1, 2); %dc offset

%setting SNR here
SNR_dB = 12;
A = sqrt(10^(SNR_dB/10));
target_mask = false(1,N); %an array for 2k false
for k = 1:length(burst_indices)
    idx = burst_indices(k);
    target_mask(idx:idx+3) = true;
end

%all 4 samples are taken as true

total_targets = 0;
detected_targets = 0;

target_vector = (A/2) * w;
rx = noise1;

for k = 1:length(burst_indices)
    idx = burst_indices(k);
    %rx(:, idx) = rx(:, idx) + target_vector;
    rx(:, idx:idx+3) = rx(:, idx:idx+3) + target_vector;
end

noise = rx;
noise_fp = fi(noise, 1, 18, 12,'fimath', F); %fixed point

%beamforming

beam2 = (w_fp' * noise_fp);

beam2 = fi(beam2, 1, 18, 12, 'fimath', F);
beam2 = bitsra(beam2,1); %right shifting so as to divide by 2
beam2 = fi(beam2, 1, 18, 12, 'fimath', F); %fixed point beam

%beam is the floating point and beam2 is the fixed point signal formed
%after beamforming


% fixed point power
real_power = real(beam2);
imag_power = imag(beam2);

real_sq = real_power .* real_power;
imag_sq = imag_power .* imag_power;

power_fp = real_sq + imag_sq;
power_fp = fi(power_fp, 0, 20, 12, 'fimath', F);


%power smoothing
s = power_fp(1) + power_fp(2) + power_fp(3) + power_fp(4);
power_s(4) = bitsra(s,2);

for i = 5:N
    
    temp = s - power_fp(i-4) + power_fp(i);
    s = fi(temp, 0, 24, 12, 'fimath', F);
    power_s(i)  = bitsra(s,2);
end

window_sum = fi(0, 0, 24, 12, 'fimath', F);
guard_sum = fi(0, 0, 24, 12, 'fimath', F);

% CFAR sliding window
itr = 15;

for  c = itr - 14:itr + 13
    temp = window_sum + power_s(c);
    window_sum = fi(temp, 0, 24, 12, 'fimath', F);
end


for k = itr - 8:itr + 7
    temp = guard_sum + power_s(k);
    guard_sum = fi(temp, 0, 24, 12, 'fimath', F);
end


while itr <= N-14
    %decision
    temp3 = window_sum - guard_sum;
    running_sum = fi(temp3, 0, 24, 12, 'fimath', F);


    LHS = fi(12, 0, 6, 0, 'fimath', F)*power_s(itr);
    RHS = alpha*running_sum;

    if target_mask(itr)
        total_targets = total_targets + 1;

        if LHS > RHS
            detected_targets = detected_targets + 1;
        end
    end
    
    if itr < N-14
    %running sum
    temp = window_sum - power_s(itr-14) + power_s(itr+14);
    window_sum = fi(temp, 0, 24, 12, 'fimath', F);

    temp2 = guard_sum - power_s(itr-8) + power_s(itr+8);
    guard_sum = fi(temp2, 0, 24, 12, 'fimath', F);

    end
    itr = itr + 1;
    
end

Pd = detected_targets / total_targets;
disp("Pd at " + SNR_dB + " is "  + Pd)

%antenna export

for ant = 1:4
    
    fid_r = fopen(sprintf('ant%d_r.mem',ant),'w');
    fid_i = fopen(sprintf('ant%d_i.mem',ant),'w');

    for i = 1:N
        fprintf(fid_r,'%018s\n',bin(real(noise_fp(ant,i))));
        fprintf(fid_i,'%018s\n',bin(imag(noise_fp(ant,i))));
    end

    fclose(fid_r);
    fclose(fid_i);

end

% beamformer export

fid_r = fopen('beam_r.mem','w');
fid_i = fopen('beam_i.mem','w');

for i = 1:N
    fprintf(fid_r,'%018s\n',bin(real(beam2(i))));
    fprintf(fid_i,'%018s\n',bin(imag(beam2(i))));
end

fclose(fid_r);
fclose(fid_i);

% power

fid = fopen('power.mem','w');

for i = 1:N
    fprintf(fid,'%020s\n',bin(power_fp(i)));
end

fclose(fid);

% smoothed power

fid = fopen('power_s.mem','w');

for i = 1:N
    fprintf(fid,'%020s\n',bin(power_s(i)));
end

fclose(fid);

% save all matlab detections to a file
fid = fopen('matlab_detections.mem', 'w');
for itr_check = 15:N-14
    win = sum(power_s(itr_check-14 : itr_check+13));
    grd = sum(power_s(itr_check-8  : itr_check+7));
    run = win - grd;
    
    lhs_val = double(fi(12,0,6,0)) * double(power_s(itr_check));
    rhs_val = double(alpha) * double(run);
    det = lhs_val > rhs_val;
    
    if target_mask(itr_check)
        fprintf(fid, 'itr=%d | det=%d | lhs=%.4f | rhs=%.4f | margin=%.4f\n', ...
            itr_check, det, lhs_val, rhs_val, lhs_val - rhs_val);
    end
end
fclose(fid);
fprintf('Saved matlab_detections.mem\n');
