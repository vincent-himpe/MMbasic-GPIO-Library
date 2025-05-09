# PicoMite MMBasic GPIO Library
## An MMBasic Library that enables low-level GPIO control on RP2040 / RP2350 PicoMites

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

The PAD in an RP2xxx is the final stage before a signal leaves the chip, or the first stage when it enters the chip. It connects the physical pin to the internal circuitry.
The output driver takes the logic level, comging from the GPIO function multiplexer, and drives it onto the pin. The driver has programmable slew rate and drive strength as well as an Output enable.
The input buffer can perform a Schmitt-trigger function
A pull-up and Pull-down register can be enabled as well as a special mode called bus-keep.


![IO-Pad diagram](/Images/IO-PAD.png)



### Sub GPIO.DriveStrength (GPIO,Strength)
- GPIO : integer 0 to 29 or more (depending on CPU)
- Strength : 0..3 where 0= 2mA, 1 = 4mA, 2= 8mA and 3 = 12mA

>[!CAUTION]
>The total allowed power draw for the processor is ~100mA. Setting all IO cells to 12mA can thermally overload the chip.

>[!Note]
>MMBasic initializes an output as 8mA using the SETPIN command. Use the DriveStrength command AFTER setpin to alter the MMBasic default.  

### Sub GPIO.Tristate (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)  

Disables the output driver of a PAD. The effect is the pin becomes high-impedant (tri-state). I/O code and Peripherals no longer have control over the output driver. Input statements and reading operatinons keep function normally. If you tristate a serial port RX pin you can still receive. If you tristate the TX pin nothing will leave the pin.

### Sub GPIO.OutputEnable (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
  
Counterpart of GPIO.Tristate. Re-enables the driver.

### Sub GPIO.Isolate (GPIO, State)
- GPIO : integer 0 to 29 or more (depending on CPU)
- State : 1 or 0 where 1 = Isolated, 0 = Connected  
>[!WARNING]
>ONLY on RP2350. Attempting this on RP2040 will throw an error  

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
Enables a special mode where the pull-up/down resistor keep the current state on a pin. The input floats by default. When you make the input high the Pull-up is enabled. When you float the input again the pull-up keeps the input (weak) high. When you make an input low the pull-down is activated. This works as a kind of state memory. Useful to suppress nois from very high impedant sources.

### Sub GPIO.SlewFast (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)  
Sets the slewrate of the output driver to fast. This can cause ringing on improperly terminated signals, but it does speed up the transition edge.

### Sub GPIO.SlewSlow (GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)  
Sets the slewrate of the output driver to slow. This reduces ringing and overshoot/undershoot. Useful on I2C busses.  

### Sub GPIO.OpenMode(GPIO,state)  
- GPIO : integer 0 to 29 or more (depending on CPU)
- State : 0..3  where
  - 0 = Open Collector/Source , no pullup
  - 1 = Open Collector/Source , with pull-up
  - 2 = Open Emitter/Drain , no pulldown
  - 3 = Open Emitter/Drain , with pull-down

This is an advanced pin-state that allows open-collector/open-emitter type behavior with or without pull-up/pull-down. You need to use the GPIO.Float and GPIO.Drive functions to set the pin high/low.

### Sub SPIO.Float(GPIO)  
- GPIO : integer 0 to 29 or more (depending on CPU)
Turns the pin driver OFF so it floats to its programmed OPEN mode (with or withour resistor)

### Sub SPIO.Drive(GPIO)  
- GPIO : integer 0 to 29 or more (depending on CPU)
Turns the pin driver ON so it goes to its programmed DRIVE mode ( HIGH in case of Open emitter/drain, LOW in case of open Collector/Source)

### Sub GPIO.INen(GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Enables the input sampler so you can read a pin, even if configured as output by MMbasic

### Sub GPIO.DISen(GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Disables the input sampler. This masks off any 'return' level that you are drive on the pin.

### Sub GPIO.Sample(GPIO)
- GPIO : integer 0 to 29 or more (depending on CPU)
Samples the input buffer directly. (It needs to be enabled using GPIO.INen)
MMBasics PIN() command does not read from a pin that is configured as output. it returns the state of the output flipflop. If the pin is in tristate and pulled low, MMBasic still returns '1' . The GPIO.Sample command returns the physical pin data.
 
---
## SIO functions  
These operations allow for PARALLEL ATOMIC operations on the IO pins (PRead = Parallel Read)  

### Function GPIO.PRead() as integer  
Returns the state of all GPIO INPUT bits as an integer.  
### Sub GPIO.Pread.  
This is a shadow routine used for interactive mode. It serves no purpose in a program. Note the PERIOD at the end of the command, that is the sign that this is a Shadow routine.  

>[!TIP]
>A Shadow is a subroutine that calls a function with the same name but discards the output. This is useful on the command line when Verbose mode is on. Ordinarily you would have to call a function with  
>x = GPIO.Pread()  
>Print GPIO.Pread()  
> Instead, you can simply invoke the shadow routine:
> GPIO.Pread.  
> The above command will directly call GPIO.Pread(), discard the output and print the formatted return value (if verbose is on). Saves keyboard pounding.

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

### Sub GPIO.Pstate.
Shadow for GPIO.Pstate()

### Sub GPIO.Pset(State)  
This SETS the given bits on the OUTPUT register.  Each corresponding bit in STATE is made High. This is essentially a masked OR of the current OUTPUT with STATE. This is an ATOMIC HARDWARE operation performed by the processor and not a read-modify-write.  
Example : GPIO.Pset(&b000110) will simultaneously make GPIPO1 and GPIO2 logic HIGH, without altering the state of any other GPIO. Note that the state of the OUTPUT ENABLE still controls the active driver.  

### Sub GPIO.Pclear(State)    
This clears the given bits in the OUTPUT register. Each corresponding bit in STATE is made low. This is the equivalent of an AND operation with the inverse of STATE. This is an ATOMIC HARDWARE operation performed by the processor and not a read-modify-write.  
Example : GPIO.Pset(&b01010) will simultaneously make GPIPO1 and GPIO3 logic LOW, without altering the state of any other GPIO. Note that the state of the OUTPUT ENABLE still controls the active driver.  

### Sub GPIO.PXor(State)    
This toggles the given bits in the OUTPUT register. Each corresponding bit in STATE is toggled from the current state. This is the equivalent of an XOR operation. This is an ATOMIC HARDWARE operation performed by the processor and not a read-modify-write.  
Example : GPIO.PXOR(&b01100) will simultaneously toggle GPIPO2 and GPIO3 from their current state, without altering the state of any other GPIO. Note that the state of the OUTPUT ENABLE still controls the active driver.  

### Sub GPIO.OEwrite(State)  
Writes STATE directly on the GPIO OUTPUT ENABLE of the drivers. 
>[!caution]
>You must take care not to alter unwanted pins inadvertently.

>[!TIP]
>Use the GPIO.OEset and OEClear operators to perform masking.

### Function GPIO.OEstate()  
Returns the current state of the GPIO OUTPUT ENABLE bits.  

### Sub GPIO.OEstate.
Shadow for GPIO.OEstate()

### Sub GPIO.OEset(State)  
This SETS the given bits on the OUTPUT ENABLE register.  Each corresponding bit in STATE is made High. This is essentially a masked OR of the current OUTPUT ENABLE with STATE. This is an ATOMIC HARDWARE operation performed by the processor and not a read-modify-write.  

### Sub GPIO.OEclear(State)    
This clears the given bits in the OUTPUT ENABLE register. Each corresponding bit in STATE is made low. This is the equivalent of an AND operation with the inverse of STATE. This is an ATOMIC HARDWARE operation performed by the processor and not a read-modify-write.  

### Sub GPIO.OEXor(State)    
This toggles the given bits in the OUTPUT ENABLE register. Each corresponding bit in STATE is toggled from the current state. This is the equivalent of an XOR operation. This is an ATOMIC HARDWARE operation performed by the processor and not a read-modify-write.  



 

 

 











