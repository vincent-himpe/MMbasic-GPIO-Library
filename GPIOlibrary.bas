  ' ---------------------------------------------------------
  ' GPIO low level access library v1.0 RC2
  ' Written by Vincent Himpe
  ' Creative Commons Zero Universal
  ' RC2 adds GPIO.Inmask and GPIO.Outmask
  
  GPIO.Verbose 1
  GPIO.Startup  ' This must be called at startup
END           ' remove this when including in code
  
  
  
  ' Internal Variables
  DIM __GPIO_Verbose AS INTEGER = 0
  DIM __GPIO_Platform AS INTEGER = 0
  dim __GPIO_SIO_BASE as INTEGER = 0
  
  ' Start the library. This needs to be called
SUB GPIO.Startup
  if __GPIO_Verbose>0 then
    print" -----------------------------------------"
    print" GPIO Driver for MMBasic by Vincent Himpe"
    print" Version 1.0 RC2"
    print" released under Creative Commons Zero Universal"
    print ""
  end if
  GPIO.SetCPU 2040
  IF (INSTR(MM.DEVICE$,"2350")>0) THEN GPIO.SetCPU 2350
  select case __GPIO_Platform
    case 2040
      __GPIO_SIO_BASE = &hd0000000
    case 2350
      __GPIO_SIO_BASE = &hd0000000
  end select
  
  
END SUB
  
  ' Turn On/Off verbose mode. 0=off , anything else = on
SUB GPIO.Verbose(State AS INTEGER)
  __GPIO_Verbose = State
END SUB
  
  ' Set the CPU Type manually. Valid selections are 2040 or 2350
SUB GPIO.SetCPU(cpu AS INTEGER)
  __GPIO_Platform = cpu
  IF __GPIO_Verbose >0 THEN
    PRINT "GPIO : CPU ";__GPIO_Platform
  END IF
END SUB
  
  
  ' Retrieves the Register address for a GPIO pin
FUNCTION GPIO.GetHandle(GPIO AS INTEGER) AS INTEGER
  LOCAL x AS INTEGER
  IF __GPIO_Platform = 2040 THEN
    x = &h4001C000
  ELSE
    x = &h40038000
  END IF
  x = x + ((GPIO+1)*4)
  IF __GPIO_Verbose<>0 THEN
    PRINT "GPIO : GP"; GPIO; " Handle @ 0x"; HEX$(x,8)
  END IF
  GPIO.GetHandle = x
END FUNCTION
  
  ' Retrieves a byte from a GPIO_Pad register
FUNCTION GPIO.Get(GPIO AS INTEGER) AS INTEGER
  LOCAL x AS INTEGER
  if __GPIO_Platform = 0 then error "GPIO : GPIO.Startup not executed"
  x = PEEK(BYTE GPIO.GetHandle(GPIO))
  IF __GPIO_Verbose<>0 THEN
    PRINT "GPIO : GP";GPIO; " Read    76543210"
    PRINT "GPIO :             &b"; BIN$(x,8)
  END IF
  GPIO.Get = x
END FUNCTION
  
  ' Retrieves a word from a GPIO_Pad register
FUNCTION GPIO.GetShort(GPIO AS INTEGER) AS INTEGER
  LOCAL x AS INTEGER
  if __GPIO_Platform = 0 then error "GPIO : GPIO.Startup not executed"
  x = PEEK(SHORT GPIO.GetHandle(GPIO))
  IF __GPIO_Verbose<>0 THEN
    PRINT "GPIO : GP";GPIO; " Read    FEDCBA76543210"
    PRINT "GPIO :             &b"; BIN$(x,16)
  END IF
  GPIO.Get = x
END FUNCTION
  
  ' Writes a Byte to a GPIO_Pad register
SUB GPIO.Set(GPIO AS INTEGER, content AS INTEGER)
  LOCAL x AS INTEGER
  LOCAL y AS INTEGER
  x = content AND &h0FF  ' mask off unwanted bits
  y = GPIO.GetHandle(GPIO)
  IF __GPIO_Verbose<>0 THEN
    PRINT "GPIO : GP"; GPIO; " Write   76543210"
    PRINT "GPIO :             &b"; BIN$(x,8)
  END IF
  POKE BYTE y,x
END SUB
  
  ' Writes a word to a GPIO_Pad register
SUB GPIO.SetShort(GPIO AS INTEGER, content AS INTEGER)
  LOCAL x AS INTEGER
  LOCAL y AS INTEGER
  x = content AND &h001FF  ' mask off unwanted bits
  y = GPIO.GetHandle(GPIO)
  IF __GPIO_Verbose<>0 THEN
    PRINT "GPIO : GP"; GPIO; " Write   FEDCBA76543210"
    PRINT "GPIO :             &b"; BIN$(x,16)
  END IF
  POKE SHORT y,x
END SUB
  
  ' Set the drive strength of a GPIO_pad. 0..3 2mA,4mA,8mA,12mA
SUB GPIO.DriveStrength(GPIO AS INTEGER ,Strength AS INTEGER)
  LOCAL x AS INTEGER = GPIO.Get(GPIO)
  x = x AND &b11001111
  SELECT CASE Strength
    CASE 0,1,2,3
      x = x OR (Strength <<4)
      GPIO.Set GPIO,x
      IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " Drivestrength ";Strength
    CASE ELSE
      PRINT "GPIO : Error, Valid Strength : 0..3"
  END SELECT
END SUB
  
  ' Turn off the output driver of a GPIO_PAD. This tristates the pin.
SUB GPIO.Tristate(GPIO AS INTEGER)
  LOCAL x AS INTEGER = GPIO.Get(GPIO)
  x = x OR &b10000000
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " Tristated"
END SUB
  
  ' Set the GPIO_PAD in isolation. Only on 2350
SUB GPIO.Isolate(GPIO AS INTEGER ,State AS INTEGER)
  IF __GPIO_Platform = 2040 THEN
    error "GPIO : Isolation needs RP2350x processor"
  ELSE
    LOCAL x AS INTEGER = GPIO.GetShort(GPIO)
    IF State<>0 THEN
      x = x OR &b100000000
      PRINT "GPIO : GP"; GPIO; " Isolated"
    ELSE
      x = x AND &b011111111
      PRINT "GPIO : GP"; GPIO; " Connected"
    END IF
    GPIO.SetShort GPIO,x
  END IF
END SUB
  
  ' Turn the output driver on. Counterpart of Tristate
SUB GPIO.OutputEnable(GPIO AS INTEGER)
  LOCAL x AS INTEGER = GPIO.Get(GPIO)
  x = x AND &b01111111
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " Driver enabled"
END SUB
  
  ' Turns on the pull-up resistor. Mutually exclusive with pulldown.
SUB GPIO.Pullup(GPIO AS INTEGER)
  LOCAL x AS INTEGER= GPIO.Get(GPIO)
  x = x AND &b11110011
  x = x OR  &b00001000
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " Pullup Enabled"
END SUB
  
  ' Turns on the pull-down resistor. Mutually exclusive with pulldown.
SUB GPIO.PullDown(GPIO AS INTEGER)
  LOCAL x  AS INTEGER = GPIO.Get(GPIO)
  x = x AND &b11110011
  x = x OR  &b00000100
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " PullDown Enabled"
END SUB
  
  ' Turns off both pull-up and pull-down resistor.
SUB GPIO.NoPull(GPIO AS INTEGER)
  LOCAL x  AS INTEGER = GPIO.Get(GPIO)
  x = x AND &b11110011
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " Pulls disabled"
END SUB
  
  ' Turns on Bus-Keep mode
  ' This only works if the output driver is disabled and the port is an input
SUB GPIO.BusKeep(GPIO AS INTEGER)
  LOCAL x  AS INTEGER = GPIO.Get(GPIO)
  x = x OR  &b00001100
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " BusKeep Enabled"
END SUB
  
  ' Set the driver slewrate to Fast
SUB GPIO.SlewFast(GPIO AS INTEGER)
  LOCAL x  AS INTEGER = GPIO.Get(GPIO)
  x = x AND &b11111110
  x = x OR  &b00000001
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " Slewrate FAST"
END SUB
  
  ' Set the driver Slewrate to slow
SUB GPIO.SlewSlow(GPIO AS INTEGER)
  LOCAL x  AS INTEGER = GPIO.Get(GPIO)
  x = x AND &b11111110
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " Slewrate SLOW"
END SUB

' Enable the Input sampler so you can read even if the pin is an output
SUB GPIO.INen(GPIO AS INTEGER)
  LOCAL x  AS INTEGER = GPIO.Get(GPIO)
  x = x or &b01000000
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " Input Cell enabled"
END SUB

' Disable the Input sampler
SUB GPIO.INdis(GPIO AS INTEGER)
  LOCAL x  AS INTEGER = GPIO.Get(GPIO)
  x = x AND &b10111111
  GPIO.Set GPIO,x
  IF __GPIO_Verbose<>0 THEN PRINT "GPIO : GP"; GPIO; " Input Cell Disabled"
END SUB

' Read the true input buffer (it needs to be enabled )
Function GPIO.Sample(Gpio as integer) as integer
    local x as integer = gpio.pread
    local y as integer = 0
    if x and (1<<gpio) >0 then y =1
    gpio.sample = y  
end function

  
' Open-Drain, Open-Source mode control
  
  ' Switch a pin to Open-x state (tristated)
Sub GPIO.Float (GPIO as INTEGER)
  GPIO.OEClear(1<<GPIO)
end sub
  
  ' Switch a pin into driven state
sub GPIO.Drive (GPIO as INTEGER)
  GPIO.OESet(1<<GPIO)
end sub
  
Sub GPIO.OpenMode (GPIO as INTEGER,State as INTEGER)
  select case State
    case else
    case 0  ' open collector/source , no pull-up
      GPIO.OEClear(1<<GPIO)   ' disable driver
      GPIO.NoPull(GPIO)       ' resistors off
      GPIO.PClear(1 <<GPIO)   ' set driver to 0
    case 1  ' open collector/source , no pull-up
      GPIO.OEClear(1<<GPIO)   ' disable driver
      GPIO.Pullup (GPIO)      ' resistor in pull-up
      GPIO.PClear(1 <<GPIO)   ' set driver to 0
    case 2  ' open Emitter/Drain, no pull-down
      GPIO.OEClear(1<<GPIO)   ' disable driver
      GPIO.NoPull(GPIO)       ' resistors off
      GPIO.PSet(1 <<GPIO)     ' set driver to 1
    case 3  ' open Emitter/Drain, pull-down
      GPIO.OEClear(1<<GPIO)   ' disable driver
      GPIO.PullDown(GPIO)     ' resistors in pulldown
      GPIO.PClear(1 <<GPIO)     ' set driver to 0
      error "GPIO : Invalid Mode state"
  end select
end sub
  
  ' -----------------------------------------------------------------
  ' Parallel I/O access. These functions are Atomic and synchronous
  ' -----------------------------------------------------------------
   
   ' need to rework this to auto change based on platform.
   
  
' Allow a mask to set the input mode for pins. a bit set to 1 will set the GPIO
' to MMBasic DIN mode .
' Example : GPIO.Inmask &b0101 wil set GP0 and GP2 to DIN mode 
Sub GPIO.InMask(mask as integer)
    local x as integer
    local y as integer = 1
    local command as string
    for x = 0 to 27
        if (mask and y) >0 then
           command = "SETPIN GP"+str$(x)+",Din"
           execute command
        end if   
        y = y << 1
    next x    
end sub
 
' Allow a mask to set the input mode for pins. A bit set to 1 will set the GPIO
' to MMBasic Dout mode  
' Example : GPIO.Inmask &b01010 wil set GP1 and GP2 to Dout mode
Sub GPIO.Outmask(mask as integer)  
    local x as integer
    local y as integer = 1
    local command as string
    for x = 0 to 27
        if (mask and y) >0 then
           command = "SETPIN GP"+str$(x)+",Dout"
           execute command
        end if   
        y = y << 1
    next x    
end sub

' Read all GPIO INPUT pins in one shot. RP2040
Function GPIO.PRead() as INTEGER
  local x as integer = peek (word __GPIO_SIO_BASE+ &h04)
  if __GPIO_Verbose <>0 then print "GPIO  : Pread  ";bin$(x,29)
  GPIO.PRead = x
end Function
  ' Read all GPIO INPUT pins in one shot. RP2350
Function GPIO.PReadL() as INTEGER
  local x as integer = peek (word __GPIO_SIO_BASE+ &h08)
  x = x <<16
  x = x or peek (word __GPIO_SIO_BASE+ &h04)
  if __GPIO_Verbose <>0 then print "GPIO  : Pread  ";bin$(x,47)
  GPIO.PReadLong = x
end Function

  ' Shadow sub for Pread so you can invoke without requiring the return value
  ' only useful when verbose is on
sub GPIO.Pread.
  local x = GPIO.PRead()
end sub

sub GPIO.PreadL.
  local x = GPIO.PReadL()
end sub

  
  ' Write all GPIO 0..29 output drivers in one shot. RP2040
  ' QSPI / USB Safe
Sub GPIO.Pwrite (State as INTEGER)
  local x AS INTEGER = __GPIO_SIO_BASE+ &h010
  ' masking off bits that are prohibited to alter
  ' this depends on cpu architecture
  local Safestate as INTEGER = State and &h03FFFFFFF
  poke word x,Safestate
end sub

  ' Write all GPIO 0..47 output drivers in one shot. RP2350
  ' QSPI / USB in danger if not locked by the safe zone
Sub GPIO.PwriteL (State as INTEGER)
  
  local x AS INTEGER = __GPIO_SIO_BASE+ &h010
  Local Xl as integer = x + &h04
  if __GPIO_Platform = 2040 then Error "GPIO : PwriteL should only be used on RP2350"
  local Safestate as INTEGER = State and &h0FFFFFFFF
  poke word x,Safestate
  Safestate = (state >>16) or &h0FFFF
  poke word xl,Safestate
end sub

  
  ' Retrieve the current state of the output drivers
Function GPIO.Pstate() as INTEGER
  local x AS INTGER = peek (word __GPIO_SIO_BASE+ &h010)
  if __GPIO_Verbose <>0 then print "GPIO  : Pstate ";bin$(x,32)
  GPIO.Pstate = x
end function

  ' Retrieve the current state of the output drivers RP2350
Function GPIO.PstateL() as INTEGER
  local x AS INTEGER = __GPIO_SIO_BASE+ &h010
  Local Xl as integer = x + &h04
  if __GPIO_Platform = 2040 then Error "GPIO : PstateL should only be used on RP2350"
  Local state as integer = peek (word xl)
  state = state <<16
  state = state or peek ( word x)
  if __GPIO_Verbose <>0 then print "GPIO  : Pstate ";bin$(x,47)
  GPIO.Pstate = x
end function

  
  ' Shadow sub for Pstate so you can invoke without requiring the return value
  ' only useful when verbose is on
Sub GPIO.Pstate.
  local x AS INTEGER = GPIO.Pstate()
end sub

  ' Shadow sub for PstateL so you can invoke without requiring the return value
  ' only useful when verbose is on
Sub GPIO.PstateL.
  local x AS INTEGER = GPIO.PstateL()
end sub

  
  ' Sets the selected bits in the OUTPUT driver. Logical OR
sub GPIO.PSet(State as INTEGER)
  local x AS INTEGER = __GPIO_SIO_BASE+ &h014
  if __GPIO_Platform = 2350 then Error "GPIO : Pset should only be used on RP2040. Use PsetL for 2350 "
  ' masking off bits that are prohibited to alter
  ' this depends on cpu architecture
  local Safestate as INTEGER = State and &h03FFFFFFF
  poke word x,Safestate
end sub

  ' Sets the selected bits in the OUTPUT driver. Logical OR
sub GPIO.PSetL(State as INTEGER)
  local x AS INTEGER = __GPIO_SIO_BASE+ &h014
  if __GPIO_Platform = 2040 then Error "GPIO : PsetL should only be used on RP2350. Use Pset for 2040 "
  ' masking off bits that are prohibited to alter
  ' this depends on cpu architecture
  local Safestate as INTEGER = State and &h03FFFFFFF
  poke word x,Safestate
end sub


  
  ' Clear the selected bits in the OUTPUT driver. Logical AND~
sub GPIO.PClear(State as INTEGER)
  local x AS INTEGER = __GPIO_SIO_BASE+ &h018
  ' masking off bits that are prohibited to alter
  ' this depends on cpu architecture
  local Safestate as INTEGER = State and &h03FFFFFFF
  poke word x,Safestate
end sub
  
  ' XOR the selected bits in the OUTPUT driver
sub GPIO.PXor(State as INTEGER)
  local x AS INTEGER =  __GPIO_SIO_BASE+ &h01C
  ' masking off bits that are prohibited to alter
  ' this depends on cpu architecture
  local Safestate as INTEGER = State and &h03FFFFFFF
  poke word x,Safestate
end sub
  
  ' Retrieve the state of the Output Enable on the pads
Function GPIO.OEstate() as INTEGER
  local x = peek (word __GPIO_SIO_BASE+ &h20)
  if __GPIO_Verbose <>0 then print "GPIO  : OEstate ";bin$(x,32)
  GPIO.OEstate = x
end Function
  ' Shadow sub for OEstate so you can invoke without requiring the return value
  ' only useful when verbose is on
sub GPIO.OEstate.
  local x = GPIO.OEstate()
end sub
  
  ' Set the state of the Output Enable on the pads
Sub GPIO.OEwrite (State as INTEGER)
  local x AS INTEGER =  __GPIO_SIO_BASE+ &h020
  ' masking off bits that are prohibited to alter
  ' this depends on cpu architecture
  local Safestate as INTEGER = State and &h03FFFFFFF
  poke word x,Safestate
end sub
  
  ' Set selected bits in the Output enable of the OUTPUT driver. Logical OR
sub GPIO.OESet(State as INTEGER)
  local x AS INTEGER =  __GPIO_SIO_BASE+ &h024
  ' masking off bits that are prohibited to alter
  ' this depends on cpu architecture
  local Safestate as INTEGER = State and &h03FFFFFFF
  poke word x,Safestate
end sub
  
  ' Clear bits in the Output Enable of the OUTPUT driver. Logical AND~
sub GPIO.OEClear(State as INTEGER)
  local x AS INTEGER =  __GPIO_SIO_BASE+ &h028
  ' masking off bits that are prohibited to alter
  ' this depends on cpu architecture
  local Safestate as INTEGER = State and &h03FFFFFFF
  poke word x,Safestate
end sub
  
  ' XOR bits in the Output Enable of the OUTPUT driver.
sub GPIO.OEXor(State as INTEGER)
  local x AS INTEGER = __GPIO_SIO_BASE+ &h02c
  ' masking off bits that are prohibited to alter
  ' this depends on cpu architecture
  local Safestate as INTEGER = State and &h03FFFFFFF
  poke word x,Safestate
end sub
  
  
  ' Internal debug routine to show contents of a GPIO_PAD register
SUB GPIO.Dump(GPIO AS INTEGER)
  LOCAL regaddr AS INTEGER = GPIO.GetHandle(GPIO)
  LOCAL padsGPIO AS INTEGER = PEEK(BYTE regaddr)
  PRINT "GPIO @ 0x"; HEX$(regaddr,16)
  PRINT ""
  PRINT "         76543210"
  PRINT "         "; (BIN$(padsGPIO,8))
  PRINT "---------------------------"
END SUB
