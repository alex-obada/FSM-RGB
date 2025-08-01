# VHDL RGB LED Controller on FPGA

This project implements a finite state machine (FSM) for controlling RGB LEDs, written in VHDL, targeting an FPGA board via the Vivado toolchain.
It was developed as part of a university assignment focused on digital system design and hardware description languages, although I treated it more like a personal project.


## 🧠 How It Works

The system uses a modular VHDL design and pulse-width modulation (PWM) to control the intensity of each RGB color channel.

It supports three operation modes, selectable via hardware switches:

- **Manual Mode (00)**: The user sets the brightness of each color (Red, Green, Blue) using 4-bit values (0–15), applied via PWM signals. This allows up to 4096 color combinations. The values are shown in hexadecimal on a 7-segment display.
- **Test Mode (01)**: The LED gradually fades each color in and out (Red -> Green -> Blue), one at a time. Transitions are smooth and time-controlled via an internal `Tick` signal, which is parameterizable through input switches.
- **Automatic Mode (10)**: A fully autonomous color cycle is generated. The system transitions through a smooth RGB color wheel without user interaction.


<br>

![Blackbox](assets/blackbox.svg)

<br>

The FSM starts in an **Idle** state, and the desired mode is entered by setting the appropriate switch combination and pressing the OK button. Pressing Reset returns the system to Idle.

To ensure modularity and reusability, each mode is implemented as a separate component. Shared PWM generators and clock dividers provide consistent brightness control across modes. A 7-segment display provides real-time feedback for active mode and values.

## 📊 System Architecture

Below is the block diagram of the internal structure, showing the Control Unit (UC), Execution Unit (UE), and the communication signals between them:

![System Architecture](assets/cu-eu-blackbox.svg)

## 🔄 State Diagram

The following diagram describes the transitions between operational modes (Idle, Manual, Test, Automatic) based on user input:

![State Diagram](assets/state-diagram.svg)



## 📄 [Full project documentation (Romanian)](docs/RO-A13.pdf)