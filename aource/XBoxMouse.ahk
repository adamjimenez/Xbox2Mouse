; -----------------PUBLIC VARS, DECLARATION
#SingleInstance force 
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

ToggleMouseSimulator := 0 ; Default value
ToggleTrigger := 0 ; Default value
HaltProgram := 0 ; Default value
LastRT := 0 ; Default values
LastLT := 0 ; Default values

; Global strings
AppVersion = 1.5
AppJoystickMessage = No joysticks or gamepads were detected! Please press button A when you have inserted a controller or right click the system tray and select "Reload"!`nThis message will not be shown again!

; -----------------LOAD SETTINGS
inifile = %A_ScriptDir%\XBoxMouse.ini


; Increase the following value to make the mouse cursor move faster:
IniRead, JoyMultiplier, %inifile%, JoyStickSettings, JoyMultiplier, 0.50 
IniWrite, %JoyMultiplier%, %inifile%, JoyStickSettings, JoyMultiplier 

; Decrease the following value to require less joystick displacement-from-center 
; to start moving the mouse.  However, you may need to calibrate your joystick 
; -- ensuring it's properly centered -- to avoid cursor drift. 
; A perfectly tight and centered joystick could use a value of 1:
IniRead, JoyThreshold, %inifile%, JoyStickSettings, JoyThreshold, 10.0 
IniWrite, %JoyThreshold%, %inifile%, JoyStickSettings, JoyThreshold 

IniRead, JoyMouseScrollAccelerationStart, %inifile%, JoyStickSettings, JoyMouseScrollAccelerationStart, 0.730 
IniWrite, %JoyMouseScrollAccelerationStart%, %inifile%, JoyStickSettings, JoyMouseScrollAccelerationStart 

IniRead, JoyMouseScrollAcceleration, %inifile%, JoyStickSettings, JoyMouseScrollAcceleration, 1.20 
IniWrite, %JoyMouseScrollAcceleration%, %inifile%, JoyStickSettings, JoyMouseScrollAcceleration 

; MouseSimulator off by default on startup?
IniRead, ToggleMouseSimulator, %inifile%, MouseSimulator, DisabledOnStartup, 0
IniWrite, %ToggleMouseSimulator%, %inifile%, MouseSimulator, DisabledOnStartup 

; Change the following to true to invert the Y-axis, which causes the mouse to 
; move vertically in the direction opposite the stick
IniRead, InvertYAxis, %inifile%, MouseSimulator, InvertYAxis, 0 
IniWrite, %InvertYAxis%, %inifile%, MouseSimulator, InvertYAxis 


; Change these values to use joystick button numbers other than 1, 2, and 3 for
; the left, right, and middle mouse buttons.  Available numbers are 1 through 32.
; Use the Joystick Test Script to find out your joystick's numbers more easily.
IniRead, ButtonLeft, %inifile%, MouseSimulator, ButtonLeft, 1
IniWrite, %ButtonLeft%, %inifile%, MouseSimulator, ButtonLeft 
IniRead, ButtonRight, %inifile%, MouseSimulator, ButtonRight, 2
IniWrite, %ButtonRight%, %inifile%, MouseSimulator, ButtonRight 
IniRead, ButtonMiddle, %inifile%, MouseSimulator, ButtonMiddle, 3
IniWrite, %ButtonMiddle%, %inifile%, MouseSimulator, ButtonMiddle 

; If your joystick has a POV control, you can use it as a mouse wheel.  The
; following value is the number of milliseconds between turns of the wheel.
; Decrease it to have the wheel turn faster:
IniRead, WheelDelay, %inifile%, MouseSimulator, WheelDelay, 5
IniWrite, %WheelDelay%, %inifile%, MouseSimulator, WheelDelay 

; First run?
IniRead, FirstRun, %inifile%, Settings, FirstRun, 1
IniWrite, 0, %inifile%, Settings, FirstRun 

; Autodetect joysticks, default on
IniRead, AutoDetectJoysticks, %inifile%, Settings, AutoDetectJoysticks, 1
IniWrite, %AutoDetectJoysticks%, %inifile%, Settings, AutoDetectJoysticks 

; Load xbox trigger settings - uses Xinput for detection due to trigger using only a single axis
; Is Trigger on by default? Toggled while running by pressing L+R+Button2
IniRead, ToggleTrigger, %inifile%, XBoxTriggerButtons, TriggerButtonsOnByDefault, 1
IniWrite, %ToggleTrigger%, %inifile%, XBoxTriggerButtons, TriggerButtonsOnByDefault 

; Minimum to be considered "pressed", between 1 (0.39%) and 255 (100%) for trigger buttons
IniRead, TriggerThreshold, %inifile%, XBoxTriggerButtons, TriggerThreshold, 64.0
IniWrite, %TriggerThreshold%, %inifile%, XBoxTriggerButtons, TriggerThreshold 

; InvertVolume
IniRead, InvertVolumeButtons, %inifile%, XBoxTriggerButtons, InvertVolumeButtons, 0
IniWrite, %InvertVolumeButtons%, %inifile%, XBoxTriggerButtons, InvertVolumeButtons 

; Keys to bind to triggers.
IniRead, LT_Key, %inifile%, XBoxTriggerButtons, LeftTriggerKey, z
IniWrite, %LT_Key%, %inifile%, XBoxTriggerButtons, LeftTriggerKey 

IniRead, RT_Key, %inifile%, XBoxTriggerButtons, RightTriggerKey, x
IniWrite, %RT_Key%, %inifile%, XBoxTriggerButtons, RightTriggerKey 

; Load settings if emulator integration shortcuts are enabled by default
IniRead, EmulatorEnhancement, %inifile%, Settings, EmulatorEnhancement, 1
IniWrite, %EmulatorEnhancement%, %inifile%, Settings, EmulatorEnhancement 

; Load settings if cursor should never hide
IniRead, NeverHideCursor, %inifile%, Settings, NeverHideCursor, 0
IniWrite, %NeverHideCursor%, %inifile%, Settings, NeverHideCursor 

; Bonus extra settings
IniRead, ExtrasLWinDisable, %inifile%, Extras, DisableLeftWindowsKey, 0
IniWrite, %ExtrasLWinDisable%, %inifile%, Extras, DisableLeftWindowsKey 
if ExtrasLWinDisable = 1
{
Hotkey, LWin, Blank, On
}

IniRead, ExtrasRWinDisable, %inifile%, Extras, DisableRightWindowsKey, 0
IniWrite, %ExtrasRWinDisable%, %inifile%, Extras, DisableRightWindowsKey 
if ExtrasRWinDisable = 1
{
	Hotkey, RWin, Blank, On 
}

IniRead, EscapeDoubleTapDelay, %inifile%, Settings, EscapeDoubleTapDelay, 200
IniWrite, %EscapeDoubleTapDelay%, %inifile%, Settings, EscapeDoubleTapDelay 

IniRead, MouseCursorSpeedSlowdownMultiplier, %inifile%, Settings, MouseCursorSpeedSlowdownMultiplier, 3
IniWrite, %MouseCursorSpeedSlowdownMultiplier%, %inifile%, Settings, MouseCursorSpeedSlowdownMultiplier 

IniRead, WindowedFullscreen, %inifile%, Extras, WindowedFullscreen, 0
IniWrite, %WindowedFullscreen%, %inifile%, Extras, WindowedFullscreen
if WindowedFullscreen = 1
{
	Hotkey ^!F12, WindowedFullscreenToggle, on
}


; Error handling ini writing
if ErrorLevel
	msgbox 16, ,There was an error reading the %inifile%! Please make sure that it is not copy protected or being used by another program!

; ----------------- STUFF TO DO AFTER LOADING SETTINGS
	
; First run message
if FirstRun
{
	Gosub ShowHelpAbout
}

; Auto detect joysticks and save the right number
if AutoDetectJoysticks = 1
{
	; Auto-detect the joystick number if called for:
	if JoystickNumber <= 0
	{
		Loop 16  ; Query each joystick number to find out which ones exist.
		{
			GetKeyState, JoyName, %A_Index%JoyName
			if JoyName <>
			{
				JoystickNumber = %A_Index%
				break
			}
		}
		if JoystickNumber <= 0
		{
			IniRead, JoyStickMessageShowOnce, %inifile%, Settings, JoyStickMessageShowOnce, 0
			if JoyStickMessageShowOnce
			{
				HaltProgram := 1 ; Do nothing to prevent overuse of cpu 
			}
			else
			{
				MsgBox, 48, XBoxMouse simulator V%AppVersion%, %AppJoystickMessage%
				IniWrite, 1, %inifile%, Settings, JoyStickMessageShowOnce 
				HaltProgram := 1 ; Do nothing to prevent overuse of cpu 
			}
		}
	}
}
else
{
	IniRead, JoyStickNumber, %inifile%, Settings, JoyStickNumber, 1
	IniWrite, %JoyStickNumber%, %inifile%, Settings, JoyStickNumber 
}
	
; ----------------- TRAY ICON COSMETICS

if A_IsCompiled
{
	Menu Tray, Icon, %A_ScriptDir%\%A_ScriptName%
}
Menu tray, NoStandard
Menu Tray, Tip, XBox Controller Mouse Simulator V%AppVersion% by Nicklas Hult
Menu tray, add, Enable Mouse Simulator, ToggleMouseSet  ; Creates a new menu item.
Menu tray, add, Enable L/R Trigger Buttons, ToggleTriggerSet  ; Creates a new menu item.
Menu tray, add, Enable Emulator Enhancement Hotkeys, ToggleEmulatorEnhancement  ; Creates a new menu item.
Menu tray, add  ; Creates a separator line.
Menu tray, add, Edit Advanced Settings, MenuHandler  ; Creates a new menu item.
	If ToggleMouseSimulator = 0
	{
		Menu, tray, Check, Enable Mouse Simulator
	}
	If ToggleTrigger = 1
	{
		Menu, tray, Check, Enable L/R Trigger Buttons
	}
	If EmulatorEnhancement = 1
	{
		Menu, tray, Check, Enable Emulator Enhancement Hotkeys
	}
Menu tray, add, Reload, MenuHandlerReload  ; Creates a new menu item.
Menu tray, add  ; Creates a separator line.
Menu tray, add, Help/About, MenuHandlerHelp  ; Creates a new menu item.
Menu tray, add, Exit, MenuHandlerExit  ; instead of default exit
	
; -----------------LOAD HOTKEYS

if HaltProgram = 0 ; prevent looping overuse of cpu when no controller is connected
{
	SystemCursor("Init") ; Initialize Cursor hiding
	XInput_Init() ; Initialize XInput for trigger button recognition
	
	; Load hotkeys
	JoystickPrefix = %JoystickNumber%Joy
	Hotkey, %JoystickPrefix%%ButtonLeft%, ButtonLeft
	Hotkey, %JoystickPrefix%%ButtonRight%, ButtonRight
	Hotkey, %JoystickPrefix%%ButtonMiddle%, ButtonMiddle
	Hotkey, %JoystickPrefix%4, KeyKeyboard
	Hotkey, %JoystickPrefix%5, KeyTabPrev
	Hotkey, %JoystickPrefix%6, KeyTabNext
	Hotkey, %JoystickPrefix%7, KeyEscape
	Hotkey, %JoystickPrefix%8, KeyEnter
	Hotkey, %JoystickPrefix%9, SaveState
	Hotkey, %JoystickPrefix%10, LoadState

	; -----------------LOADING PARAMETERS

	; Calculate the axis displacements that are needed to start moving the cursor:
	JoyThresholdUpper := 50 + JoyThreshold
	JoyThresholdLower := 50 - JoyThreshold

	if InvertYAxis
		YAxisMultiplier = -1
	else
		YAxisMultiplier = 1
			
	; Start watching for joystick input
	SetTimer CheckAll, 25 ; Modifier hotkeys to change settings
	SetTimer LeftRightTrigger, 5 ; XBox trigger as normal buttons
	SetTimer WatchJoystick, 10  ; Monitor the movement of the joystick.
	SetTimer WatchJoystick2, 250 ; Movement of the scroller (joystick 2)
	SetTimer DigitalPad, %WheelDelay%
	GetKeyState, JoyInfo, %JoystickNumber%JoyInfo
	;IfInString, JoyInfo, P  ; Joystick has POV control
}
else
{
	; Reload by pressing joysticks first button
	Hotkey, Joy1, JoyReload
	Hotkey, 2Joy1, JoyReload
	Hotkey, 3Joy1, JoyReload
	Hotkey, 4Joy1, JoyReload
	Hotkey, 5Joy1, JoyReload
	Hotkey, 6Joy1, JoyReload
}
	
return  ; End of auto-execute section.
;-----------------------------------------------END OF AUTO-EXECUTE SECTION------------------------------------------------------

; Reload AutoDetection
JoyReload:
	if HaltProgram = 1
		Reload
return


; TRAY ICON MENU ITEMS
MenuHandler:
	Run, open "%A_ScriptDir%\XBoxMouse.ini"
return

; SHOW ABOUT/HELP GUI WINDOW
MenuHandlerHelp:
	Gosub ShowHelpAbout
return

MenuHandlerReload:
	Reload
return

MenuHandlerExit:
	ExitApp
return

; CHECK MODIFIER BUTTONS HELD DOWN
;check if all buttons are pressed at the same time
CheckAll:
	
	; Check if modifier buttons are down
	if GetKeyState(JoystickPrefix . 5)
		LeftModDown := 1
	else
		LeftModDown := 0
		
	if GetKeyState(JoystickPrefix . 6)
		RightModDown := 1
	else
		RightModDown := 0
	; Sum modifiers together to get if both are down or if any are down
	TotalModDown := RightModDown + LeftModDown
	If TotalModDown = 2
		BothModDown = 1
	else
		BothModDown = 0
	
	;Debug
	;Tooltip Modifier %LeftModDown% and %RightModDown% and %BothModDown%
	
	; Old script part, I know this uses an older way of triggering buttons and I will clean up this properly some day.
	if !GetKeyState(JoystickPrefix . 5) ;Hold down button 5 to proceed
		Return
	if !GetKeyState(JoystickPrefix . 6) ;Hold down button 6 to proceed
		Return
	
	BlockKeyTab := 1
	BlockPOVTab := 1 ; Prevent user from using pov key while checking for inputs, makes alt tabbing work uninterrupted
	if GetKeyState(JoystickPrefix . 2)
		{
			BlockPOVTab := 0
			Goto ToggleMouseSet
		}
	else if GetKeyState(JoystickPrefix . 4)
		{
			BlockPOVTab := 0
			Goto ToggleTriggerSet	
		}
	else if GetKeyState(JoystickPrefix . 3)
		{
			BlockPOVTab := 0
			Goto ToggleEmulatorEnhancement	
		}
	else if KeyToHoldDown = Right
		{
			Goto GoAltTab
		}
	else if KeyToHoldDown = Left
		{
			Goto GoAltTab
		}
	else
		{
			BlockPOVTab := 0
		}
return

; ENABLES THE MODIFIER CHECKALL TIMER AGAIN AFTER A WHILE
ReActivateCheckAll: 
	Settimer CheckAll, on
return

; ALT TAB MENU
GoAltTab:
	SetMouseDelay, -1  ; Makes movement smoother.
	if A_OSVersion in WIN_XP,WIN_NT4,WIN_95,WIN_98,WIN_ME  ; Check if old OS is running, then the new alt tab wont work
	{
		; old alt+tab solution
		BlockPOVTab := 1
		Send {Alt down}
		KeyWait %JoystickPrefix%5
		KeyWait %JoystickPrefix%6
		Send {Alt up}
	}
	else
	{
		BlockPOVTab := 0
		; new alt+tab solution for vista and windows 7
		Send {Alt down}{Shift down}{Tab}
		KeyWait %JoystickPrefix%5
		KeyWait %JoystickPrefix%6
		Send {Alt up}{shift up}
	}
	BlockPOVTab := 0
return

; TOGGLE TRIGGER NORMAL BUTTON BEHAVIOUR FUNCTION
ToggleTriggerSet:
	SetMouseDelay, -1  ; Makes movement smoother.
;	Tooltip Test
	if ToggleTrigger = 1
	{
		Tooltip L/R Trigger Buttons`nDISABLED
		ToggleTrigger = 0
		Settimer, LeftRightTrigger, off
		IniWrite, %ToggleTrigger%, %inifile%, XBoxTriggerButtons, TriggerButtonsOnByDefault 
		Menu, tray, Uncheck, Enable L/R Trigger Buttons
	}
	else
	{
		Tooltip L/R Trigger Buttons`nENABLED
		ToggleTrigger = 1
		Settimer, LeftRightTrigger, on
		IniWrite, %ToggleTrigger%, %inifile%, XBoxTriggerButtons, TriggerButtonsOnByDefault 
		Menu, tray, Check, Enable L/R Trigger Buttons
	}
	Settimer CheckAll, off
	Settimer TooltipOff, 2000
	Settimer ReActivateCheckAll, 1000
return

; Disable Trigger Axis
; if ToggleTrigger = 1
; tooltip test
; Send %JoystickNumber%JoyZ, 50
; return

; TOGGLE EMULATOR ENHANCEMENT
ToggleEmulatorEnhancement:
	SetMouseDelay, -1  ; Makes movement smoother.
	if EmulatorEnhancement = 0
	{
		Tooltip Emulator Enhancement Hotkeys`nENABLED
		EmulatorEnhancement = 1
		SetTimer HideMouseCursorCheckIdle, off
		Menu, tray, Check, Enable Emulator Enhancement Hotkeys
		IniWrite, %EmulatorEnhancement%, %inifile%, Settings, EmulatorEnhancement 
	}
	else
	{
		Tooltip Emulator Enhancement Hotkeys`nDISABLED
		EmulatorEnhancement = 0
		Menu, tray, Uncheck, Enable Emulator Enhancement Hotkeys
		IniWrite, %EmulatorEnhancement%, %inifile%, Settings, EmulatorEnhancement 
	}
	Settimer CheckAll, off
	Settimer TooltipOff, 2000
	Settimer ReActivateCheckAll, 1000
return

; TOGGLE MOUSE CONTROLLER FUNCTION
ToggleMouseSet:
	SetMouseDelay, -1  ; Makes movement smoother.
	if ToggleMouseSimulator = 1
	{
		Tooltip Mouse Simulator`nENABLED
		ToggleMouseSimulator = 0
		SetTimer HideMouseCursorCheckIdle, off
			if NeverHideCursor
			{
			}
			else
			{
				DllCall("ShowCursor","Uint",1) 
				SystemCursor("On")
			}
		Menu, tray, Check, Enable Mouse Simulator
	}
	else
	{
		Tooltip Mouse Simulator`nDISABLED
			if NeverHideCursor
			{
			}
			else
			{
				DllCall("ShowCursor","Uint",0) 
				SetTimer HideMouseCursorCheckIdle, 250
			}
		ToggleMouseSimulator = 1
		Menu, tray, Uncheck, Enable Mouse Simulator
	}
	Settimer CheckAll, off
	Settimer TooltipOff, 2000
	Settimer ReActivateCheckAll, 1000
Return

; DISABLE TOOLTIP AFTER A WHILE 
TooltipOff: 
	ToolTip
	Settimer TooltipOff, off
return

; TOGGLE ON SCREEN KEYBOARD
KeyKeyboard:
	if (ToggleMouseSimulator = 1)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	if GetKeyState(JoystickPrefix . 5) ; ignore inputs while holding down this button
		{
		if GetKeyState(JoystickPrefix . 6) ; ignore inputs while holding down this button
			Return
		}
		
	;Start ON SCREEN keyboard
	Process, Exist, osk.exe ; check to see if process is running
	If (ErrorLevel = 0) ; If it is not running
	   {
	   DllCall("Wow64DisableWow64FsRedirection", "uint*", OldValue) 
	   Run osk.exe
	   DllCall("Wow64RevertWow64FsRedirection", "uint", OldValue) 
	   }
	Else ; If it is running, ErrorLevel equals the process id for the target program (Printkey). Then close it.
	   {
		;DllCall("Wow64DisableWow64FsRedirection", "uint*", OldValue) 
		Process, Close, %ErrorLevel%
		;DllCall("Wow64RevertWow64FsRedirection", "uint", OldValue) 
	   } 
	Process, Exist, MSSWCHX.EXE ; check to see if WINDOWS XP OLD keyboard process is running to prevent multiple instances
	Process, Close, %ErrorLevel%
return


; READ LEFT AND RIGHT TRIGGER BUTTONS AND REPLACE WITH KEYBOARD IF SET
LeftRightTrigger:
	SetMouseDelay, -1  ; Makes movement smoother.
	Loop, 4 
	{
		if XInput_GetState(A_Index-1, State)=0 {
			LT := json(State,"bLeftTrigger") >= TriggerThreshold
			RT := json(State,"bRightTrigger") >= TriggerThreshold
			if (LT != LastLT) 
			{
				Gosub LeftTrigger
				LastLT := LT
			}
			if (RT != LastRT) 
			{
				Gosub RightTrigger
				LastRT := RT
			}
		}
	}
return

IncreaseVolume:
	SoundGet master_volume
	Send {Volume_Up}
	Tooltip %master_volume% Increasing Audio Volume...
	SetTimer TooltipOff, 500
return

DecreaseVolume:
	SoundGet master_volume
	Send {Volume_Down}
	Tooltip %master_volume% Decreasing Audio Volume...
	SetTimer TooltipOff, 500
return

; LEFT TRIGGER BUTTON REPLACEMENT
LeftTrigger:
	if ToggleMouseSimulator = 0 ; Is the mouse simulator active? If it is then
	{
		if InvertVolumeButtons = 1
		{
			Gosub IncreaseVolume
		}
		else
		{
			Gosub DecreaseVolume
		}
	}
	else if ToggleTrigger = 0 ; Are the trigger replacements disabled?
	{
		; Do nothing
	}
	else ; Send replacement key
	{
		Send % "{" . LT_Key . (LT ? " Down}" : " Up}") ;%
	}
return

; RIGHT TRIGGER BUTTON REPLACEMENT
RightTrigger:
	if ToggleMouseSimulator = 0 ; Is the mouse simulator active? If it is then
	{
		if InvertVolumeButtons = 1
		{
			Gosub DecreaseVolume
		}
		else
		{
			Gosub IncreaseVolume
		}
	}
	else if ToggleTrigger = 0 ; Are the trigger replacements disabled?
	{
		; Do nothing
	}
	else ; Send replacement key
	{
		Send % "{" . RT_Key . (RT ? " Down}" : " Up}") ;%
	}
return

; PREVIOUS TAB BUTTON
KeyTabPrev:
	if (ToggleMouseSimulator = 1)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	
	; MOUSE SLOWDOWN START
		; Lower Mouse Speed while keeping key down
		JoyMultiplier:=JoyMultiplier/MouseCursorSpeedSlowdownMultiplier
		; Store data from mouse to determine if it moved
		DeltaXcheck := DeltaX
		DeltaYcheck := DeltaY
		joyXcheck := joyX
		joyYcheck := joyY
	KeyWait %JoystickPrefix%5
		
		; Restore Mouse Speed when releasing key
		JoyMultiplier:=JoyMultiplier*MouseCursorSpeedSlowdownMultiplier
		; Abort command if mouse moved
		if !(DeltaYcheck = DeltaY)
		{
			return
		}
		if !(DeltaXcheck = DeltaY)
		{
			return
		}
		if !(joyYcheck = joyY)
		{
			return
		}
		if !(joyXcheck = joyX)
		{
			return
		}
	; MOUSE SLOWDOWN END

	; ABORT IF MODIFIERS WERE USED
	if GetKeyState(JoystickPrefix . 6)
		return
	if BlockKeyTab = 1
	{
		BlockKeyTab = 0
		return
	}
	
	; CUSTOM COMMAND INTEGRATION
		WinGetActiveStats Title, Width, Height, X, Y
		{
			if InStr(Title, "Firefox") ; Is firefox running?
			{
				Send {Ctrl down}{PgUp}{Ctrl up}
			}
			else if InStr(Title, "Google Chrome") ; Is chrome running?
			{
				Send {Ctrl down}{PgUp}{Ctrl up}
			}
			else if InStr(Title, "Internet Explorer") ; Is IE running?
			{
				Send {Ctrl down}{shift down}{Tab}{shift up}{Ctrl up}
			}
			else
			{
				if WinActive("ahk_class CabinetWClass") ; If Windows Explorer is running
				{
					Send {Alt down}{Left}{Alt up}
				}
				else if WinActive("ahk_class QWidget") ; If vlc is running
				{
					;do nothing
				}
				else ; No integration
				{
					;do nothing
				}
			}
		}
return


; NEXT TAB BUTTON
KeyTabNext:
	if (ToggleMouseSimulator = 1)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	
	; MOUSE SLOWDOWN START
		; Lower Mouse Speed while keeping key down
		JoyMultiplier:=JoyMultiplier/MouseCursorSpeedSlowdownMultiplier
		; Store data from mouse to determine if it moved
		DeltaXcheck := DeltaX
		DeltaYcheck := DeltaY
		joyXcheck := joyX
		joyYcheck := joyY
	KeyWait %JoystickPrefix%6
		
		; Restore Mouse Speed when releasing key
		JoyMultiplier:=JoyMultiplier*MouseCursorSpeedSlowdownMultiplier
		; Abort command if mouse moved
		if !(DeltaYcheck = DeltaY)
		{
			return
		}
		if !(DeltaXcheck = DeltaY)
		{
			return
		}
		if !(joyYcheck = joyY)
		{
			return
		}
		if !(joyXcheck = joyX)
		{
			return
		}
	; MOUSE SLOWDOWN END

	; ABORT IF MODIFIERS WERE USED
	if GetKeyState(JoystickPrefix . 5)
		return
	if BlockKeyTab = 1
	{
		BlockKeyTab = 0
		return
	}
	
	; CUSTOM COMMAND INTEGRATION
		WinGetActiveStats Title, Width, Height, X, Y
		{
			if InStr(Title, "Firefox") ; Is firefox running?
			{
				Send {Ctrl down}{PgDn}{Ctrl up}
			}
			else if InStr(Title, "Google Chrome") ; Is chrome running?
			{
				Send {Ctrl down}{PgDn}{Ctrl up}
			}
			else if InStr(Title, "Internet Explorer") ; Is IE running?
			{
				Send {Ctrl down}{Tab}{Ctrl up}
			}
			else
			{
				if WinActive("ahk_class CabinetWClass") ; If Windows Explorer is running
				{
					Send {Alt down}{Right}{Alt up}
				}
				else if WinActive("ahk_class QWidget") ; If vlc is running
				{
					Send {Space}
				}
				else ; No integration
				{
					;do nothing
				}
			}
		}
return


; ESCAPE KEY BUTTON
KeyEscape:
	if (ToggleMouseSimulator = 1)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	; Check if back button was pressed twice quickly, then it will use ALT+F4 instead
	if (BothModDown = 1) ; ignore inputs while holding down this button
		{
		Send {AltDown}{F4}{AltUp}
		}
	else if DoubleEscapeActive = 1
		{
		Send {AltDown}{F4}{AltUp}
		}
	else
		{
		Send {Esc}
		Settimer DoubleEscape, %EscapeDoubleTapDelay%
		DoubleEscapeActive = 1
		}
return

DoubleEscape: 
	DoubleEscapeActive = 0
	SetTimer DoubleEscape, off
return

; ENTER KEY BUTTON
KeyEnter:
	if (ToggleMouseSimulator = 1)
		return
	if (BothModDown = 1) ; new way of checking modifiers!
	{
		Send {RWin down}
		Sleep 10
		Send {P}
		Sleep 10
		Send {RWin up}
	}
	else
	{
		Send {Enter}
	}
return

; SAVE STATE BUTTON - DIFFERENT DEPENDING ON THE EMULATOR CURRENTLY RUNNING IN FOCUS
SaveState:
	if (ToggleMouseSimulator = 0) ; only run when mouse is disabled
		return
	if (EmulatorEnhancement = 0)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	WinGetActiveStats Title, Width, Height, X, Y
	{
		if InStr(Title, "Dolphin") ; Is dolphin running?
		{
			Send {shift down}{F1}{shift up}
			sleep 1000
			Send {shift down}{F2}{shift up}
		}
		else if InStr(Title, "Snes9X") ; Is snes9X running?
		{
			Send {shift down}{F5}{shift up}
		}
		else if InStr(Title, "GSdx |") ; Is PCSX2 running?
		{
			Send {F1}
		}
		else if InStr(Title, "pSX") ; Is pSX or ePSXe running?
		{
			if InStr(Title, "ePSXe") ; Is ePSXe running?
			{
				Tooltip ePSXe - Saving state...
				SendInput {F1 down}
				Sleep 100
				SendInput {F1 up}
				Sleep 300
				Tooltip ePSXe - Saved state
				Settimer TooltipOff, 1000
			}
			else ; is pSX running?
			{
				Send {F1}
			}
		}
		else if InStr(Title, "Project64") ; Is Project 64 running?
		{
			Send {F5}
		}
	}		
return


; LOAD STATE BUTTON - DIFFERENT DEPENDING ON THE EMULATOR CURRENTLY RUNNING IN FOCUS
LoadState:
	if (ToggleMouseSimulator = 0) ; only run when mouse is disabled
		return
	if (EmulatorEnhancement = 0)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	WinGetActiveStats Title, Width, Height, X, Y
	{
		if InStr(Title, "Dolphin") ; Is dolphin running?
		{
			Send {F1}
		}
		else if InStr(Title, "Snes9X") ; Is snes9X running?
		{
			Send {F7}
		}			
		else if InStr(Title, "GSdx |") ; Is PCSX2 running?
		{
			Send {F3}
		}
		else if InStr(Title, "pSX") ; Is pSX or ePSXe running?
		{
			if InStr(Title, "ePSXe") ; Is ePSXe running?
			{
				Tooltip ePSXe - Loading state...
				SendInput {F3 down}
				Sleep 100
				SendInput {F3 up}
				Sleep 300
				Tooltip ePSXe - Loaded state
				Settimer TooltipOff, 1000
			}
			else ; is pSX running?
			{
				Send {F6}
			}
		}
		else if InStr(Title, "Project64") ; Is Project running?
		{
			Send {F7}
		}
	}	
return

; -----------------HOTKEY FUNCTIONS


ButtonLeft:
	if (ToggleMouseSimulator = 1)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	MouseClick, left,,, 1, 0, D  ; Hold down the left mouse button.
	SetTimer, WaitForLeftButtonUp, 10
return


WaitForLeftButtonUp:
	if (ToggleMouseSimulator = 1)
		return
	if GetKeyState(JoystickPrefix . ButtonLeft)
		return  ; The button is still, down, so keep waiting.
	; Otherwise, the button has been released.
	SetMouseDelay, -1  ; Makes movement smoother.
	SetTimer, WaitForLeftButtonUp, off
	MouseClick, left,,, 1, 0, U  ; Release the mouse button.
return


ButtonRight:
	if (ToggleMouseSimulator = 1)
		return
	if GetKeyState(JoystickPrefix . 5) ; ignore inputs while holding down this button
		{
		if GetKeyState(JoystickPrefix . 6) ; ignore inputs while holding down this button
			Return
		}
	SetMouseDelay, -1  ; Makes movement smoother.
	MouseClick, right,,, 1, 0, D  ; Hold down the right mouse button.
	SetTimer, WaitForRightButtonUp, 10
return


WaitForRightButtonUp:
	if (ToggleMouseSimulator = 1)
		return
	if GetKeyState(JoystickPrefix . ButtonRight)
		return  ; The button is still, down, so keep waiting.
	; Otherwise, the button has been released.
	SetTimer, WaitForRightButtonUp, off
	MouseClick, right,,, 1, 0, U  ; Release the mouse button.
return


ButtonMiddle:
	if (ToggleMouseSimulator = 1)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	MouseClick, middle,,, 1, 0, D  ; Hold down the right mouse button.
	SetTimer, WaitForMiddleButtonUp, 10
return

WaitForMiddleButtonUp:
	if (ToggleMouseSimulator = 1)
		return
	if GetKeyState(JoystickPrefix . ButtonMiddle)
		return  ; The button is still, down, so keep waiting.
	; Otherwise, the button has been released.
	SetTimer, WaitForMiddleButtonUp, off
	MouseClick, middle,,, 1, 0, U  ; Release the mouse button.
return

; -----------------JOYSTICK FUNCTIONS

; The subroutines below do not use KeyWait because that would sometimes trap the
; WatchJoystick quasi-thread beneath the wait-for-button-up thread, which would
; effectively prevent mouse-dragging with the joystick.
WatchJoystick:
	if (ToggleMouseSimulator = 1)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	MouseNeedsToBeMoved := false  ; Set default.
	SetFormat, float, 03
	GetKeyState, joyx, %JoystickNumber%JoyX
	GetKeyState, joyy, %JoystickNumber%JoyY
	if joyx > %JoyThresholdUpper%
	{
		MouseNeedsToBeMoved := true
		DeltaX := joyx - JoyThresholdUpper
	}
	else if joyx < %JoyThresholdLower%
	{
		MouseNeedsToBeMoved := true
		DeltaX := joyx - JoyThresholdLower
	}
	else
		DeltaX = 0
	if joyy > %JoyThresholdUpper%
	{
		MouseNeedsToBeMoved := true
		DeltaY := joyy - JoyThresholdUpper
	}
	else if joyy < %JoyThresholdLower%
	{
		MouseNeedsToBeMoved := true
		DeltaY := joyy - JoyThresholdLower
	}
	else
		DeltaY = 0
	if MouseNeedsToBeMoved
	{
		SetMouseDelay, -1  ; Makes movement smoother.
		MouseMove, DeltaX * JoyMultiplier, DeltaY * JoyMultiplier * YAxisMultiplier, 0, R
	}
return


; Watch second joystick, the mouse scroller
WatchJoystick2:
	if (ToggleMouseSimulator = 1)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	GetKeyState, joyr, %JoystickNumber%JoyR
	GetKeyState, joyu, %JoystickNumber%JoyU
	JoyNeedsToBeMoved := false  ; Set default.
	
	; VERTICAL 
	if joyr > 60
	{
		JoyNeedsToBeMoved := true
		;DeltaR := joyr - 60
	}
	else if (joyr = %EmptyVar%)
	{
		return
	}
	else if joyr < 40
	{
		JoyNeedsToBeMoved := true
		;DeltaR := joyr - 40
	}
	else
	{
		JoyNeedsToBeMoved := false
		SetTimer Joystick2ScrollVerticalTimer, off
		;DeltaR = 0
	}

	
	; ACTION
	if JoyNeedsToBeMoved
	{
		SetMouseDelay, -1  ; Makes movement smoother.

		; VERTICAL DIRECTION
		if joyr < 50
		{
			ScrollSpeedVertical := ((joyr)*10^JoyMouseScrollAcceleration)*JoyMouseScrollAccelerationStart
			VerticalDirection = 0
		}
		else
		{
			ScrollSpeedVertical := ((100 - joyr)*10^JoyMouseScrollAcceleration)*JoyMouseScrollAccelerationStart
			VerticalDirection = 1
		}
		
		; INSTANT SINGLE SCROLL "NUDGE" makes the scrolling experience softer and more comfortable
		if JoyBuffer = 0
		{
			;Tooltip %joyr% %ScrollSpeedVertical% ;debugging info
				if VerticalDirection = 1
					Send {WheelDown}
				else
					Send {WheelUp}
			JoyBuffer := 1
		}
		else
		{
			SetTimer Joystick2ScrollVerticalTimer, %ScrollSpeedVertical%
		}
		;SetTimer Joystick2ScrollHorisontalTimer, %ScrollSpeedHorisontal%
	}
	else
	{
		SetTimer Joystick2ScrollVerticalTimer, off
		JoyBuffer = 0
		;SetTimer Joystick2ScrollHorisontalTimer, off
	}
return

Joystick2ScrollVerticalTimer:
	if VerticalDirection = 1
	{
		Send {WheelDown}
	}
	else
	{
		Send {WheelUp}
	}
return

; Joystick2ScrollHorisontalTimer:
	; if HorisontalDirection = 1
	; {
		; Send {WheelLeft}
	; }
	; else
	; {
		; Send {WheelRight}
	; }
; return


; EXTRAS FUNCTIONS

Blank: ; Disable key
Return

; -----------------DIGITAL PAD FUNCTIONS

DigitalPad:
	if (ToggleMouseSimulator = 1)
		return
	SetMouseDelay, -1  ; Makes movement smoother.
	GetKeyState, POV, %JoystickNumber%JoyPOV
	KeyToHoldDownPrev = %KeyToHoldDown%  ; Prev now holds the key that was down before (if any).

	; Some joysticks might have a smooth/continous POV rather than one in fixed increments.
	; To support them all, use a range:
	if POV < 0   ; No angle to report
		KeyToHoldDown =
	else if POV > 31500                 ; 315 to 360 degrees: Forward
		KeyToHoldDown = Up
	else if POV between 0 and 4500      ; 0 to 45 degrees: Forward
		KeyToHoldDown = Up
	else if POV between 4501 and 13500  ; 45 to 135 degrees: Right
		KeyToHoldDown = Right
	else if POV between 13501 and 22500 ; 135 to 225 degrees: Down
		KeyToHoldDown = Down
	else                                ; 225 to 315 degrees: Left
		KeyToHoldDown = Left

	if KeyToHoldDown = %KeyToHoldDownPrev%  ; The correct key is already down (or no key is needed).
		return  ; Do nothing. 

	if KeyToHoldDownPrev   ; There is a previous key to release.
		{
			Send, {%KeyToHoldDownPrev% up}  ; Release it.
		}

	; NIRKLARS SPECIFIC CHANGE WHEN USING ALT+TAB SHORTCUT
	if BlockPOVTab = 1
	{
		if KeyToHoldDown = Left
		{
			Send {Shift down}{Tab}{Shift up}
		}
		else if KeyToHoldDown = Right
		{
			Send {Tab}
		}
	}
	else
	{
		; BEFORE NIRKLARS/NORMAL FEATURE
		; Otherwise, release the previous key and press down the new key:
		SetKeyDelay -1  ; Avoid delays between keystrokes.
		if KeyToHoldDown   ; There is a key to press down.
			{
				Send, {%KeyToHoldDown% down}  ; Press it down.
			}
	}
return

WindowedFullscreenToggle:
	WinGet, TempWindowID, ID, A
	If (WindowID != TempWindowID)
	{
	  WindowID:=TempWindowID
	  WindowState:=0
	}
	If (WindowState != 1)
	{
	  WinGetPos, WinPosX, WinPosY, WindowWidth, WindowHeight, ahk_id %WindowID%
	  WinSet, Style, ^0xC40000, ahk_id %WindowID%
	  WinMove, ahk_id %WindowID%, , 0, 0, A_ScreenWidth, A_ScreenHeight
	}
	Else
	{
	  WinSet, Style, ^0xC40000, ahk_id %WindowID%
	  WinMove, ahk_id %WindowID%, , WinPosX, WinPosY, WindowWidth, WindowHeight
	}
	WindowState:=!WindowState
return

; ########################################## FUNCTIONS / SUBS ####################################

ShowHelpAbout:
Gui Destroy
	Gui Margin, 5, 5
	Gui +ToolWindow +AlwaysOnTop +NoActivate +Center
	Gui Add, Text, xm ym, Welcome to XBoxMouse simulator V%AppVersion%!
	Gui Add, Text, xp yp+14, 
	Gui Add, Text, xp yp+14, This program is written to run silently in the background.
	Gui Add, Text, xp yp+14, To change settings or exit this program please right click the system tray icon.
	Gui Add, Text, xp yp+14, 
	Gui Add, Text, xp yp+14, To quickly toggle enabling or disabling functions hold down LB+RB on your controller and press B, Y or X.
	Gui Add, Text, xp yp+14, For more detailed controls and hotkeys please visit
	Gui Add, Text, xp+240 yp cBlue gLink2 vURL_Link2, the website!
	Gui Add, Text, xp-240 yp+14,
	Gui Add, Text, xp yp+14, To change advanced settings please edit the ini file manually and reload the program.
	Gui Add, Text, xp yp+14, If you accidentally mess up the settings in "BoxMouse.ini" please manually delete the file and reload the program.
	Gui Add, Text, xp yp+14, The ini file is located in the same directory as this program but can be quickly edited from the system tray.
	Gui Add, Text, xp yp+14,
	Gui Add, Text, xp yp+14, To uninstall this program simply delete the exe file and the ini file.
	Gui Add, Text, xp yp+14,
	Gui Add, Text, xp yp+14, This message is only shown once, if you wish to read it again, please right click the system tray icon and click help/about.
	Gui Add, Text, xp yp+14, 
	Gui Add, Text, xp yp+14, For more information please visit the website!
	Gui Add, Text, xp yp+14 cBlue gLink1 vURL_Link1, http://nirklars.wordpress.com
	Gui Add, Text, xp yp+14, 
	Gui Add, Text, xp yp+14, Best Regards
	Gui Add, Text, xp yp+14, Nicklas Hult
	Gui Add, Button, xp+250 h23 w75, OK

;Setup Links
	; Retrieve scripts PID
	Process Exist
	pid_this := ErrorLevel
	; Retrieve unique ID number (HWND/handle)
	WinGet hw_gui, ID, ahk_class AutoHotkeyGUI ahk_pid %pid_this%
	; Call "HandleMessage" when script receives WM_SETCURSOR message
	WM_SETCURSOR = 0x20
	OnMessage(WM_SETCURSOR, "HandleMessage")
	; Call "HandleMessage" when script receives WM_MOUSEMOVE message
	WM_MOUSEMOVE = 0x200
	OnMessage(WM_MOUSEMOVE, "HandleMessage")

;Show window
	Gui Show, w600, XBox Controller Mouse Simulator V%AppVersion% by Nicklas Hult
return

;Object References
ButtonOK:
	Gui destroy
return
Link1:
	Run http://nirklars.wordpress.com
	Gui destroy
return
Link2:
	Run http://nirklars.wordpress.com/xboxmouse/#controls
	Gui destroy
return

; ########################################## INCLUDED FUNCTIONS - DO NOT EDIT !!!!! ##########################################

/*

	HIDE IDLE CURSOR WHEN MOUSE CONTROLLER IS OFF
	START

*/

HideMouseCursorCheckIdle:
	SetMouseDelay, -1  ; Makes movement smoother.
	TimeIdle := A_TimeIdlePhysical // 1000
	if TimeIdle >= 2
	{
		SystemCursor("Off")
	}
	else
	{
		DllCall("ShowCursor","Uint",1) 
		SystemCursor("On")
	}
	return

	#Persistent
	OnExit, ShowCursor  ; Ensure the cursor is made visible when the script exits.
return

; Show Cursor Function Start
ShowCursor:
	SystemCursor("On")
ExitApp

SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{
    static AndMask, XorMask, $, h_cursor
        ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
    if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
    {
        $ = h                                          ; active default cursors
        VarSetCapacity( h_cursor,4444, 1 )
        VarSetCapacity( AndMask, 32*4, 0xFF )
        VarSetCapacity( XorMask, 32*4, 0 )
        system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
        StringSplit c, system_cursors, `,
        Loop %c0%
        {
            h_cursor   := DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
            h%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
            b%A_Index% := DllCall("CreateCursor","uint",0, "int",0, "int",0
                , "int",32, "int",32, "uint",&AndMask, "uint",&XorMask )
        }
    }
    if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
        $ = b  ; use blank cursors
    else
        $ = h  ; use the saved cursors

    Loop %c0%
    {
        h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
        DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
    }
}




/*
    Function: XInput_Init
    
    Initializes XInput.ahk with the given XInput DLL.
    
    Parameters:
        dll     -   The path or name of the XInput DLL to load.
*/
XInput_Init(dll="xinput1_3")
{
    global
    if _XInput_hm
        return
    
    ;======== CONSTANTS DEFINED IN XINPUT.H ========
    
    ; NOTE: These are based on my outdated copy of the DirectX SDK.
    ;       Newer versions of XInput may require additional constants.
    
    ; Device types available in XINPUT_CAPABILITIES
    XINPUT_DEVTYPE_GAMEPAD          = 0x01

    ; Device subtypes available in XINPUT_CAPABILITIES
    XINPUT_DEVSUBTYPE_GAMEPAD       = 0x01

    ; Flags for XINPUT_CAPABILITIES
    XINPUT_CAPS_VOICE_SUPPORTED     = 0x0004

    ; Constants for gamepad buttons
    XINPUT_GAMEPAD_DPAD_UP          = 0x0001
    XINPUT_GAMEPAD_DPAD_DOWN        = 0x0002
    XINPUT_GAMEPAD_DPAD_LEFT        = 0x0004
    XINPUT_GAMEPAD_DPAD_RIGHT       = 0x0008
    XINPUT_GAMEPAD_START            = 0x0010
    XINPUT_GAMEPAD_BACK             = 0x0020
    XINPUT_GAMEPAD_LEFT_THUMB       = 0x0040
    XINPUT_GAMEPAD_RIGHT_THUMB      = 0x0080
    XINPUT_GAMEPAD_LEFT_SHOULDER    = 0x0100
    XINPUT_GAMEPAD_RIGHT_SHOULDER   = 0x0200
    XINPUT_GAMEPAD_A                = 0x1000
    XINPUT_GAMEPAD_B                = 0x2000
    XINPUT_GAMEPAD_X                = 0x4000
    XINPUT_GAMEPAD_Y                = 0x8000

    ; Gamepad thresholds
    XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  = 7849
    XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE = 8689
    XINPUT_GAMEPAD_TRIGGER_THRESHOLD    = 30

    ; Flags to pass to XInputGetCapabilities
    XINPUT_FLAG_GAMEPAD             = 0x00000001
    
    ;=============== END CONSTANTS =================
    
    _XInput_hm := DllCall("LoadLibrary" ,"str",dll)
    
    if !_XInput_hm
    {
        MsgBox, Failed to initialize XInput: %dll%.dll not found.
        return
    }
    
    _XInput_GetState        := DllCall("GetProcAddress" ,"uint",_XInput_hm ,"str","XInputGetState")
    _XInput_SetState        := DllCall("GetProcAddress" ,"uint",_XInput_hm ,"str","XInputSetState")
    _XInput_GetCapabilities := DllCall("GetProcAddress" ,"uint",_XInput_hm ,"str","XInputGetCapabilities")
    
    if !(_XInput_GetState && _XInput_SetState && _XInput_GetCapabilities)
    {
        XInput_Term()
        MsgBox, Failed to initialize XInput: function not found.
        return
    }
}

/*
    Function: XInput_GetState
    
    Retrieves the current state of the specified controller.

    Parameters:
        UserIndex   -   [in] Index of the user's controller. Can be a value from 0 to 3.
        State       -   [out] Receives the current state of the controller.
    
    Returns:
        If the function succeeds, the return value is ERROR_SUCCESS (zero).
        If the controller is not connected, the return value is ERROR_DEVICE_NOT_CONNECTED (1167).
        If the function fails, the return value is an error code defined in Winerror.h.
            http://msdn.microsoft.com/en-us/library/ms681381.aspx

    Remarks:
        XInput.dll returns controller state as a binary structure:
            http://msdn.microsoft.com/en-us/library/bb174834.aspx
        XInput.ahk converts this structure to a string, compatible with Titan's json():
            http://www.autohotkey.com/forum/topic34565.html
*/
XInput_GetState(UserIndex, ByRef State)
{
    global _XInput_GetState
    
    VarSetCapacity(xiState,16)
    
    if ErrorLevel := DllCall(_XInput_GetState ,"uint",UserIndex ,"uint",&xiState)
        State =
    else
        State := "{
        ( C LTrim Join
            'dwPacketNumber':" NumGet(xiState,0) ",
            ;   Seems less convenient - though more technically accurate - to require
            ;   "Gamepad." prefix to access any of the useful properties with json().
            ;'Gamepad':{
                'wButtons':" NumGet(xiState,4,"UShort") ",
                'bLeftTrigger':" NumGet(xiState,6,"UChar") ",
                'bRightTrigger':" NumGet(xiState,7,"UChar") ",
                'sThumbLX':" NumGet(xiState,8,"Short") ",
                'sThumbLY':" NumGet(xiState,10,"Short") ",
                'sThumbRX':" NumGet(xiState,12,"Short") ",
                'sThumbRY':" NumGet(xiState,14,"Short") "
            ;}
        )}"
    
    return ErrorLevel
}

/*
    Function: XInput_SetState
    
    Sends data to a connected controller. This function is used to activate the vibration
    function of a controller.
    
    Parameters:
        UserIndex       -   [in] Index of the user's controller. Can be a value from 0 to 3.
        LeftMotorSpeed  -   [in] Speed of the left motor, between 0 and 65535.
        RightMotorSpeed -   [in] Speed of the right motor, between 0 and 65535.
    
    Returns:
        If the function succeeds, the return value is 0 (ERROR_SUCCESS).
        If the controller is not connected, the return value is 1167 (ERROR_DEVICE_NOT_CONNECTED).
        If the function fails, the return value is an error code defined in Winerror.h.
            http://msdn.microsoft.com/en-us/library/ms681381.aspx
    
    Remarks:
        The left motor is the low-frequency rumble motor. The right motor is the
        high-frequency rumble motor. The two motors are not the same, and they create
        different vibration effects.
*/
XInput_SetState(UserIndex, LeftMotorSpeed, RightMotorSpeed)
{
    global _XInput_SetState
    return DllCall(_XInput_SetState ,"uint",UserIndex ,"uint*",LeftMotorSpeed|RightMotorSpeed<<16)
}

/*
    Function: XInput_GetCapabilities
    
    Retrieves the capabilities and features of a connected controller.
    
    Parameters:
        UserIndex   -   [in] Index of the user's controller. Can be a value in the range 0–3.
        Flags       -   [in] Input flags that identify the controller type.
                                0   - All controllers.
                                1   - XINPUT_FLAG_GAMEPAD: Xbox 360 Controllers only.
        Caps        -   [out] Receives the controller capabilities.
    
    Returns:
        If the function succeeds, the return value is 0 (ERROR_SUCCESS).
        If the controller is not connected, the return value is 1167 (ERROR_DEVICE_NOT_CONNECTED).
        If the function fails, the return value is an error code defined in Winerror.h.
            http://msdn.microsoft.com/en-us/library/ms681381.aspx
*/
XInput_GetCapabilities(UserIndex, Flags, ByRef Caps)
{
    global _XInput_GetCapabilities
    
    VarSetCapacity(xiCaps,20)
    
    if ErrorLevel := DllCall(_XInput_GetCapabilities ,"uint",UserIndex ,"uint",Flags ,"uint",&xiCaps)
        Caps =
    else
        Caps := "{
        ( LTrim Join
            'Type':" NumGet(xiCaps,0,"UChar") ",
            'SubType':" NumGet(xiCaps,1,"UChar") ",
            'Flags':" NumGet(xiCaps,2,"UShort") ",
            'Gamepad':{
                'wButtons':" NumGet(xiCaps,4,"UShort") ",
                'bLeftTrigger':" NumGet(xiCaps,6,"UChar") ",
                'bRightTrigger':" NumGet(xiCaps,7,"UChar") ",
                'sThumbLX':" NumGet(xiCaps,8,"Short") ",
                'sThumbLY':" NumGet(xiCaps,10,"Short") ",
                'sThumbRX':" NumGet(xiCaps,12,"Short") ",
                'sThumbRY':" NumGet(xiCaps,14,"Short") "
            },
            'Vibration':{
                'wLeftMotorSpeed':" NumGet(xiCaps,16,"UShort") ",
                'wRightMotorSpeed':" NumGet(xiCaps,18,"UShort") "
            }
        )}"
    
    return ErrorLevel
}

/*
    Function: XInput_Term
    Unloads the previously loaded XInput DLL.
*/
XInput_Term() {
    global
    if _XInput_hm
        DllCall("FreeLibrary","uint",_XInput_hm), _XInput_hm :=_XInput_GetState :=_XInput_SetState :=_XInput_GetCapabilities :=0
}

; TODO: XInputEnable, 'GetBatteryInformation and 'GetKeystroke.






/*
	Function: JSON

	Parameters:
		js - source
		s - path to element
		v - (optional) value to overwrite

	Returns:
		Value of element (prior to change).

	License:
		- Version 2.0 <http://www.autohotkey.net/~polyethene/#json>
		- Dedicated to the public domain <http://creativecommons.org/licenses/publicdomain/>
*/
json(ByRef js, s, v = "") {
	j = %js%
	Loop, Parse, s, .
	{
		p = 2
		RegExMatch(A_LoopField, "([+\-]?)([^[]+)((?:\[\d+\])*)", q)
		Loop {
			If (!p := RegExMatch(j, "(?<!\\)(""|')([^\1]+?)(?<!\\)(?-1)\s*:\s*((\{(?:[^{}]++|(?-1))*\})|(\[(?:[^[\]]++|(?-1))*\])|"
				. "(?<!\\)(""|')[^\7]*?(?<!\\)(?-1)|[+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:,|$|\})", x, p))
				Return
			Else If (x2 == q2 or q2 == "*") {
				j = %x3%
				z += p + StrLen(x2) - 2
				If (q3 != "" and InStr(j, "[") == 1) {
					StringTrimRight, q3, q3, 1
					Loop, Parse, q3, ], [
					{
						z += 1 + RegExMatch(SubStr(j, 2, -1), "^(?:\s*((\[(?:[^[\]]++|(?-1))*\])|(\{(?:[^{\}]++|(?-1))*\})|[^,]*?)\s*(?:,|$)){" . SubStr(A_LoopField, 1) + 1 . "}", x)
						j = %x1%
					}
				}
				Break
			}
			Else p += StrLen(x)
		}
	}
	If v !=
	{
		vs = "
		If (RegExMatch(v, "^\s*(?:""|')*\s*([+\-]?\d+(?:\.\d*)?|true|false|null?)\s*(?:""|')*\s*$", vx)
			and (vx1 + 0 or vx1 == 0 or vx1 == "true" or vx1 == "false" or vx1 == "null" or vx1 == "nul"))
			vs := "", v := vx1
		StringReplace, v, v, ", \", All
		js := SubStr(js, 1, z := RegExMatch(js, ":\s*", zx, z) + StrLen(zx) - 1) . vs . v . vs . SubStr(js, z + StrLen(x3) + 1)
	}
	Return, j == "false" ? 0 : j == "true" ? 1 : j == "null" or j == "nul"
		? "" : SubStr(j, 1, 1) == """" ? SubStr(j, 2, -1) : j
}


; HANDLE LINKS FUNCTION
HandleMessage(p_w, p_l, p_m, p_hw)
  {
    global   WM_SETCURSOR, WM_MOUSEMOVE,
    static   URL_hover, h_cursor_hand, h_old_cursor, CtrlIsURL, LastCtrl
   
    If (p_m = WM_SETCURSOR)
      {
        If URL_hover
          Return, true
      }
    Else If (p_m = WM_MOUSEMOVE)
      {
        ; Mouse cursor hovers URL text control
        StringLeft, CtrlIsURL, A_GuiControl, 3
        If (CtrlIsURL = "URL")
          {
            If URL_hover=
              {
                Gui, Font, cBlue underline
                GuiControl, Font, %A_GuiControl%
                LastCtrl = %A_GuiControl%
               
                h_cursor_hand := DllCall("LoadCursor", "uint", 0, "uint", 32649)
               
                URL_hover := true
              }                 
              h_old_cursor := DllCall("SetCursor", "uint", h_cursor_hand)
          }
        ; Mouse cursor doesn't hover URL text control
        Else
          {
            If URL_hover
              {
                Gui, Font, norm cBlue
                GuiControl, Font, %LastCtrl%
               
                DllCall("SetCursor", "uint", h_old_cursor)
               
                URL_hover=
              }
          }
      }
  }