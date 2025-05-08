# MMBasic GPIO Library
## A MMBasic that enables low-level GPIO control

### Overview
MMBasic has built in functions to control the GPIO pins and those perform perfectly fine.
There are situations where you may nee dfiner control beyond what is offered by the built-in capabilities.

The GPIO PADS on the RP2040 / RP2350 allow fine control over the GPIO Pins in the microcontroller.
Things like drive strength, slew rate, output enable, isolation and more can be controlled per pin.  
See section 2.19.4 in the rp2040 datasheet for more info.  
The PADS bypass ALL peripherals and act directly on the pin itself.  

The SIO registers in the RP2040 / RP2350 allow Atomic, Syncronous Parallel control of the GPIO Pads.  
You can alter multiple GPIO pins in one Atomic operation, including read/write, set,clear and xor on both the input,output and output enable signals.  
For more info on these registers see Section 2.3.1.7 in the rpi2040 datasheet.  

### Usage
Simply include the library as part of your code and call the GPIO.Startup routine.

>[!WARNING]
>You MUST call GPIO.Startup before any attempting any operations.  

The GPIO.Startup identifies the actual processor in use and sets the control vectors. These are core dependent. If you do not set this, the routines will throw an error and abort your program. 

The GPIO.Verbose operator allows you to switch to an interactive mode. This is useful when calling functions direclty form the command line. Verbose mode returns direct information and status of a given command.
By default this mode is disable

GPIO.Verbose 0  ' Turn off verbose mode
GPIO.Verbose 1  ' Turn on verbose mode  

---
## PAD Functions.

### Sub GPIO.DriveStrength (GPIO,Strength)
- GPIO : integer 0 to 29 or more (depending on CPU)
- Strength : 0..3 where 0= 2mA, 1 = 4mA, 2= 8mA and 3 = 12mA

>[!CAUTION]
>The total allowed power draw for the processor is ~100mA. Setting all IO cells to 12mA can thermally overload the chip.

>[!Note]
>MMBasic initializes an output as 8mA using the SETPIN command. Use the DriveStrength command AFTER setpin to alter the MMBasic default.  

### sub GPIO.Tristate (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)

Disables the output driver of a PAD. The effect is the pin becomes high-impedant (tri-state). I/O code and Peripherals no longer have control over the output driver. Input statements and reading operatinons keep function normally. If you tristate a serial port RX pin you can still receive. If you tristate the TX pin nothing will leave the pin.

### Sub GPIO.OutputEnable (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Counterpart of GPIO.Tristate. Re-enables the driver.

### Sub GPIO.Isolate (GPIO, State)
- GPIO : integer 0 to 29 or more (depending on CPU)
- State : 1 or 0 where 1 = Isolated, 0 = Connected
***ONLY on RP2350. Attempting this on RP204 will throw and error***

Puts the PAD in isolation mode. This is a feature of the 2350. It allows disconnecting the internal peripherals from the PAD cell without needing to reconfigure them upon reconnection.

### Sub GPIO.PullUp (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Enables the Pull-up register on GPIO. Mutually exclusive with GPIOPullDown.

### Sub GPIO.PullDown (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Enables the Pull-Down register on GPIO. Mutually exclusive with GPIOPullUp.

### Sub GPIO.NoPull (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Disables both Pull-Up and Pull-Down on GPIO.

### Sub GPIO.BusKeep (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Enables a special mode on RP2350 where the pull-up/down resistor keep the current state on a pin. The input floats by default. When you make the input high the Pull-up is enabled. When you float the input again the pull-up keeps the input (weak) high. When you make an input low the pull-down is activated. This works as a kind of state memory. Useful to suppress nois from very high impedant sources.
*** Attempting this on a rp2040 will throw an error ***

### Sub GPIO.SlewFast (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Sets the slewrate of the output driver to fast. This can cause ringing on improperly terminated signals, but it does speed up the transition edge.

### Sub GPIO.SlewSlow (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Sets the slewrate of the output driver to slow. This reduces ringing and overshoot/undershoot. Useful on I2C busses.  

---
## SIO functions  
These operations allow for PARALLEL ATOMIC operations on the IO pins (PRead = Parallel Read)  

### Function GPIO.PRead() as integer  
Returns the state of all GPIO INPUT bits as an integer.  
### Sub GPIO.Pread.
This is a shadow routine used for interactive mode. It serves no purpose in a program

>[!INFORMATION]
>A Shadow is a subroutine that calls a function with the same name but discards the output. This is useful on the command line when Verbose mode is on. Ordinarily you would have to call a function with
>x = GPIO.Pread()  
>Print GPIO.Pread()  
>
>GPIO.Pread.  
>The above command will directly call GPIO.Pread(), discard the output and print the formatted return value (if verbose is on). Saves keyboard pounding.

### Sub GPIO.Pwrite(State)
Writes STATE directly on the GPIO OUTPUT drivers. 
>[!caution]
>You must take care not to alter unwanted pins inadvertently.
>[!TIP]
>Use the GPIO.Pset and PClear operators to perform masking.

### Function GPIO.Pstate()
Returns the current state of the GPIO OUTPUT drivers.
>[!NOTE]
>This is ***NOT*** the same as Pread. Pread returns the INPUT state of the pin (The level seen by the pin INPUT). Pstate returns the OUTPUT driver state: the control bit of the driver itself.

 ### sub GPIO.Pstate.
 Shadow for GPIO.Pstate()

 











