# CFAR-Based Radar Target Detection (RTL + MATLAB)

## 🚀 Overview

This project implements a **CFAR (Constant False Alarm Rate) based radar target detection system** using a full signal processing pipeline:

**Beamforming → Power Computation → Power Smoothing → CA-CFAR Detection**

The design is developed in **MATLAB (reference model)** and implemented in **Verilog (RTL)** using **fixed-point arithmetic**, with careful validation between software and hardware behavior.

---

## 🎯 Key Features

* ✅ **CA-CFAR detector (Cell Averaging)**
* ✅ **Beamforming using 4 antennas**
* ✅ **Fixed-point RTL design**
* ✅ **MATLAB ↔ RTL validation**
* ✅ **Pipeline-aware implementation**
* ✅ **Detection performance analysis (Pd, Pfa)**

---

## 🧠 System Architecture

```
Antenna Inputs (4 channels)
        ↓
Beamforming
        ↓
Power Calculation (I² + Q²)
        ↓
Power Smoothing (Moving Average)
        ↓
CFAR Detection
        ↓
Detection Output
```

---

## 📊 Signal Model

* Complex Gaussian noise:

  ```
  x = n_r + j n_i
  ```
* Targets injected at specific indices with controlled SNR
* Beamforming enhances signal strength before detection

---

## ⚙️ CFAR Algorithm

Detection rule:

```
CUT > α × Noise Estimate
```

Where:

* CUT = Cell Under Test
* α = scaling factor (threshold control)
* Noise Estimate = average of surrounding training cells

---

## 🔧 Implementation Details

### 📌 MATLAB (Reference Model)

* Signal generation (complex Gaussian noise)
* Target injection
* Beamforming
* Power calculation
* Smoothing
* CFAR detection
* Export to `.mem` files for RTL

### 📌 RTL (Verilog)

Modules:

* `beamformer.v`
* `power_calc.v`
* `power_smooth.v`
* `cfar.v`
* `bram_sp.v` (data input)

Key aspects:

* Fixed-point arithmetic (Q-format)
* Pipeline alignment
* Resource-efficient design

---

## 🧪 Validation

* MATLAB and RTL outputs are compared
* Pipeline delay accounted for
* Matching achieved for:

  * Detection positions
  * Threshold behavior

---

## 📈 Results

| Metric           | Value |
| ---------------- | ----- |
| Injected Targets | 64    |
| Detected Targets | 56    |
| Total Detections | 100   |
| False Alarms     | 44    |

### Interpretation:

* CFAR correctly detects targets (Pd ≈ 0.8 at 12 dB SNR)
* Additional detections correspond to **expected false alarms**
* Demonstrates **Pd–Pfa tradeoff**

---

## ⚖️ Tradeoff Insight

* Lower threshold (α ↓):

  * ↑ Detection probability
  * ↑ False alarms

* Higher threshold (α ↑):

  * ↓ False alarms
  * ↓ Detection probability

---

## 🧱 Fixed-Point Design

* MATLAB `fi` used for modeling
* Bit-width alignment with RTL
* Rounding and truncation carefully handled

---

## 🧩 Challenges Faced

* Pipeline misalignment between MATLAB and RTL
* Fixed-point precision mismatch
* Threshold scaling differences
* Debugging false alarms vs true detections

---

## 🖥️ FPGA Integration

* Input data stored in BRAM (`.mem` files)
* Streaming architecture using address counter
* Detection output visualized using LEDs

---

## 📁 Repository Structure

```
├── matlab/
│   ├── signal_generation.m
│   ├── cfar_model.m
│   └── data_export.m
│
├── rtl/
│   ├── beamformer.v
│   ├── power_calc.v
│   ├── power_smooth.v
│   ├── cfar.v
│   └── bram_sp.v
│
├── tb/
│   └── cfar_tb.v
│
├── data/
│   ├── ant1_r.mem
│   ├── ant1_i.mem
│   └── power_s.mem
│
└── README.md
```

---

## 🛠️ Tools Used

* MATLAB (fixed-point modeling)
* Vivado (RTL simulation & synthesis)
* Verilog HDL

---

## 📌 Learning Outcomes

* RTL design for signal processing
* Fixed-point implementation
* MATLAB ↔ hardware validation
* Understanding CFAR and radar detection
* Debugging pipeline and timing issues

---

## 🔮 Future Work

* Real-time FPGA deployment
* Advanced CFAR (OS-CFAR, GO-CFAR)
* Hardware optimization (timing/power)
* Integration with real radar data

---

## 📜 License

This project is for academic and educational purposes.

---

## 👤 Author

Alan Joseph Abraham
M.Tech Electronics Enginnering
Specialisation in VLSI Design

---
