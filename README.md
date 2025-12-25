# FPGA_Image_Denoising
Hardware implementation of an image cleaning block using Median Filtering algorithm. Features real-time RGB processing and pipelined architecture in VHDL.

## 📂 Repository Structure
The project files are organized as follows:

* **`codes/`**: Contains all source VHDL files (`Top_Level`, `pipe`, `FSM`, `Image_Line_Processor`, `rom`, `ram`) and RGB Files (.mif) of the noisy input image.
* **`simulation and synthesize/`**: Includes simulation waveforms (ModelSim) and synthesis images.
* **`Photos/`**: 
    * `Noisy_Input.jpg`: The original image corrupted with noise.
    * `Cleaned_Output.jpg`: The final image reconstructed after FPGA processing.
 
## ⚙️ System Architecture & Design

### 1. Top Level Design
The `Top_Level` entity Manages the entire operation. It instantiates:
* **Three Parallel Processing Pipelines:** One for each color channel (Red, Green, Blue). This allows simultaneous processing of the full RGB spectrum, tripling the throughput compared to serial processing.
* **Central FSM:** Synchronizes the memory read/write operations for all three channels.

### 2. The Pipeline Block 
Acts as a wrapper for each color channel. It connects:
* **ROM (Read-Only Memory):** Stores the noisy image pixel data.
* **Image Line Processor:** The algorithmic core.
* **RAM (Random Access Memory):** Stores the processed (clean) pixels.

### 3. Image Line Processor ( The Algorithmic Core)
This block implements the **3x3 Median Filter** logic.
* **Buffered Data Path:** Maintains three **258-pixel wide buffers** (Image Width + 2 padding). A dedicated function performs **Padding and Load**, automatically replicating edges as the new row enters the shift-register hierarchy.
* **Massive Parallelism:** Uses a VHDL `generate` loop to instantiate **256 parallel sorting networks**, creating a simultaneous 3x3 mask for every column.
* **Throughput:** Processes the entire video line in a single clock cycle, outputting a complete denoised `Fixed_Row`.

### 4. Finite State Machine (FSM)
The FSM controls the data flow and memory addressing. It handles:
* **Latency Management:** Accounts for the delay introduced by the pipeline (filling the line buffers) before enabling write signals (`ram_en`).
* **Boundary Handling:** Manages edge cases (First Row, Middle Rows, Last Row) to ensure the window operates correctly at image boundaries.

### 5. On-Chip Memory Units
The memory blocks were generated using **Intel Quartus Prime IP Catalog (Megafunctions)** to utilize the FPGA's dedicated memory resources.

* **Input ROM (`rom1.vhd`):** * Configured as a **Single-Port Read-Only Memory**.
    * **Initialization:** Loaded automatically at runtime with the `.mif` files (containing the noisy RGB data). This simulates the reception of image data.
    
* **Output RAM (`Ram.vhd`):** * Configured as a **Single-Port Random Access Memory**.
    * **Write Control:** The `wren` (Write Enable) signal is driven by the FSM's delay chain. This ensures that data is only written to RAM exactly when valid processed pixels emerge from the pipeline.

## 🧪 Verification & Simulation Strategy
Before running the full image processing on the FPGA, a rigorous verification process was conducted to validate the timing and control logic.

### Phase 1: Timing Validation (Dummy Data)
To verify the FSM transitions and pipeline latency without the complexity of image data, a **Test MIF (Memory Initialization File)** was created.
* **Setup:** A 256-depth memory file was populated with sequential counter values (Address `0x00` = Data `0x00`, Address `0x01` = Data `0x01`, etc.).
* **Goal:** To confirm that the `Read Address` -> `Pipeline Delay` -> `Write Address` correlation was exact.
* **Result:** Simulation waveforms confirmed that the `ram_en` (write enable) signal asserted exactly after the pipeline filled, ensuring data integrity. (See screenshots in `simulation and synthesize/`).

### Phase 2: Full Image Simulation
* **Python Pre-Processing:** A Python script converted the noisy RGB image into three `.mif` files (Red, Green, Blue).
* **RTL Simulation:** The design was simulated using the actual image data.
* **Python Post-Processing:** The resulting memory dumps were reconstructed back into an image using Python to visually verify the noise removal.

## 🚀 Hardware Implementation Flow
1.  **Image Conversion:** Python script parses the noisy image -> Generates `Lena_r.mif`, `Lena_g.mif`, `Lena_b.mif`.
2.  **Synthesis:** The VHDL code is synthesized using **Intel Quartus Prime**.
3.  **Place & Route:** The design is mapped to the Cyclone IV E FPGA resources.
4.  **Processing:** The FPGA reads from ROM, filters noise via hardware logic, and writes to RAM.
5.  **Reconstruction:** The RAM content is exported and rebuilt into the final "Cleaned" image.

## 🛠 Tools & Technologies
* **Language:** VHDL (IEEE 1076)
* **FPGA Family:** Intel Cyclone IV E
* **EDA Tools:** Quartus Prime, ModelSim
* **Scripting:** Python (for Image <-> MIF conversion)


 
