#SingleInstance force
;Jimothy Script
;updated by LJ
;2021-11-20
;----------------------------
; change log:
;2021-11-21 added simple Briv selection tool. - banur
;
;----------------------------
;Level Up Script
;by mikebaldi1980
;5/27/21
;put together with the help from many different people. thanks for all the help.
;----------------------------
;	User Settings
;	various settings to allow the user to Customize how the Script behaves
;----------------------------			
global ScriptSpeed = 1500   ;sets the delay after a directedinput, ms
global gHewSlot = -1			;Hew's formation slot
global gClickLeveling = 1
global gFkeySpam = 1
global gUkeySpam = 1
global gJFkeySpam = 0
global gJUkeySpam = 1
global gGForce = 1
global gBrivStackStop = 1
global gRight = 1
global gEFormationZone = 0
global gJUseEFormation = 0
global gEFormationZoneUI = 0
global gMinStacksUI = 0
global gSpeedTime = 0
global gAzakaFarm = 0
global gSpamQ = 1
global gMaxMonsters = 125
global gMaxLevel = 2001
global gMinStacks = 50
global gLevelZone = 100
;variables to consider changing if restarts are causing issues
global gOpenProcess	= 10000	;time in milliseconds for your PC to open Idle Champions
global gGetAddress = 5000		;time in milliseconds after Idle Champions is opened for it to load pointer base into memory
;end user settings
global gSlotData := []
global gSeatToggle := [1,1,1,1,1,1,1,1,1,1,1,1]
global gZoneSkip := []
global gUltToggle := []
global gFKeys := 
global gUKeys := 
global gScriptPID := DllCall("GetCurrentProcessId")
global gLastTitle := 0

;address of Contractual Obligations
global addressCO := 0x2707C875E30

SetWorkingDir, %A_ScriptDir%

;wrapper with memory reading functions sourced from: https://github.com/Kalamity/classMemory
#include classMemory.ahk

;Check if you have installed the class correctly.
if (_ClassMemory.__Class != "_ClassMemory")
{
	msgbox class memory not correctly installed. Or the (global class) variable "_ClassMemory" has been overwritten
	ExitApp
}

;pointer addresses and offsets
#include IC_MemoryFunctions.ahk

loop, 12
{
    IniRead, tVal, ATSettings.ini, Section1, cbSeat%A_Index%, 0
	CheckboxSeat%A_Index% := tVal
;	gSeatToggle[A_Index] := tVal
}
loop, 10
{
    IniRead, tVal, ATSettings.ini, Section1, cbUlt%A_Index%, 0
	CheckboxUlt%A_Index% := tVal
}

IniRead, gFKeySpam, ATSettings.ini, Section1, FKeySpam, 1
IniRead, gUKeySpam, ATSettings.ini, Section1, UKeySpam, 1
IniRead, gJFKeySpam, ATSettings.ini, Section1, JFKeySpam, 0
IniRead, gJUKeySpam, ATSettings.ini, Section1, JUKeySpam, 1
IniRead, gGForce, ATSettings.ini, Section1, GForce, 1
IniRead, gMaxLevel, ATSettings.ini, Section1, MaxZone, 2001
IniRead, gLevelZone, ATSettings.ini, Section1, LevelZone, 100
IniRead, gJUseEFormation, ATSettings.ini, Section1, JUseEFormation, 0
IniRead, gEFormationZone, ATSettings.ini, Section1, EFormationZone, 0
IniRead, gMinStacks, ATSettings.ini, Section1, MinStacks, 50
IniRead, gRight, ATSettings.ini, Section1, Right, 1
IniRead, gSpamQ, ATSettings.ini, Section1, SpamQ, 1
IniRead, gBrivStackStop, ATSettings.ini, Section1, BrivStop, 1
IniRead, gClickLeveling, ATSettings.ini, Section1, ClickDmg, 1
loop, 50
{
	IniRead, tVal, ATSettings.ini, Section1, SkipZone%A_Index%, 0
	CheckboxZoneSkip%A_Index% := tVal
	gZoneSkip[A_Index] := tVal
}
Gui, MyWindow:New
Gui, MyWindow:+Resize -MaximizeBox
Gui, MyWindow:Add, Button, x415 y25 w60 gSave_Clicked, Save
Gui, MyWindow:Add, Button, x415 y+10 w60 gRun_Clicked, `Leveler
Gui, MyWindow:Add, Button, x415 y+10 w60 gAzaka_Clicked, Azaka
Gui, MyWindow:Add, Button, x415 y+10 w60 gJimothy_Clicked, Jimothy
Gui, MyWindow:Add, Button, x415 y+10 w60 gReload_Clicked, `Reload
Gui, MyWindow:Add, Button, hidden default gCheck_Values, Ok
Gui, MyWindow:Add, Tab3, x5 y5 w400 vTabs, Help|Leveler/Ults|E Formation Zones|Jimothy|Azaka
Gui, Tab, Help
Gui, MyWindow:Add, Text, x15 y30, Not much help here yet
Gui, MyWindow:Add, Text, x15 y+15, Leveler - levels and Spams ults for you
Gui, MyWindow:Add, Text, x15 y+15, Azaka - Untested but should be the same as before
Gui, MyWindow:Add, Text, x15 y+15, Jimothy - Uses Briv, Jim and Hew to get to z2001
Gui, MyWindow:Add, Text, x15 y+8, Q Formation must have Hew, Briv and Jim
Gui, MyWindow:Add, Text, x15 y+8, E Formation must not have Briv

;Gui, Tab, Settings
;Gui, MyWindow:Add, Checkbox, vgFkeySpam Checked%gFkeySpam% x15 y+5, Spam Fkeys
;Gui, MyWindow:Add, Checkbox, vgMaxLevelStop Checked%gMaxLevelStop% x15 y+5, Stop at max Zone

Gui, Tab, Jimothy
Gui, MyWindow:Add, Checkbox, vgJFKeySpam Checked%gJFKeySpam% x15 y+5 gChanged, Use Leveler
Gui, MyWindow:Add, Checkbox, vgJUKeySpam Checked%gJUKeySpam% x15 y+5 gChanged, Use Ultimates
Gui, MyWindow:Add, Checkbox, vgBrivStackStop Checked%gBrivStackStop% x15 y+5 gChanged, Stop if Briv runs out of Stacks
Gui, MyWindow:Add, Text,  vStackID x15 y+15, Minimum number of Haste stacks to keep
Gui, MyWindow:Add, Edit, vgMinStacksUI gStacks_Edit x+4 w34 0x2000 Limit4, % gMinStacks
GuicontrolGet, temp, Pos, StackID
GuiControl, Move, gMinStacksUI, % "Y" tempY -30

Gui, MyWindow:Add, Checkbox, vgJUseEFormation Checked%gJUseEFormation% x15 y+10 gChanged
Gui, MyWindow:Add, Text ,x32 ys+102 vJUEFID,Use E Formation until Zone
Gui, MyWindow:Add, Edit, vgEFormationZoneUI gFormationZone_Edit x+2 0x2000 w34 Limit4, % gEFormationZone
GuicontrolGet, temp, Pos, gEFormationZoneUI
GuiControl, Move, gEFormationZoneUI, % "Y" tempY -29

Gui, MyWindow:Add, Text, x15 y+30, Jimothy Status:
Gui, MyWindow:Add, Text, vJimothy_ClickedID x+2, Press Jimothy to start
Gui, MyWindow:Add, Text, x15 y+15, Hew Alive: 
Gui, MyWindow:Add, Text, vHewAliveID x+2 w30, ???
Gui, MyWindow:Add, Text, x+15, Hew Slot: 
Gui, MyWindow:add, Text, vHewSlotID x+2 w50, ???
Gui, MyWindow:Add, Text, x15 y+2, Current Level:
Gui, MyWindow:Add, Text, vReadCurrentZoneID x+2 w50, ???
Gui, MyWindow:Add, Text, x15 y+2, Briv Stacks:
Gui, MyWindow:Add, Text, vReadBrivStacksID x+2 w50, ???

Gui, MyWindow:Add, Text, x15 y+10, Monsters Spawned:
Gui, MyWindow:Add, Text, x+5 vReadMonstersSpawnedID, ???
Gui, MyWindow:Add, Text, x+5 , /
Gui, MyWindow:Add, Edit, vNewMaxMonsters x+2 0x2000, % gMaxMonsters
Gui, MyWindow:Add, Text, x+5, Max Monsters
GuicontrolGet, temp, Pos, NewMaxMonsters
GuiControl, Move, NewMaxMonsters, % "Y" tempY -31

Gui, Tab, Azaka
Gui, MyWindow:Add, Edit, vNewaddressCO x15 y+10 w150, % addressCO
Gui, MyWindow:Add, Text, x+5, numContractsFufilled Mem Address
Gui, MyWindow:Add, Text, x15 y+15, numContractsFufilled:
Gui, MyWindow:Add, Text, vnumContractsFufilledID x+2 w50, % numContractsFufilled
Gui, MyWindow:Add, Text, x15 y+2, TigerCount:
Gui, MyWindow:Add, Text, vTigerCountID x+2 w50, % TigerCount
Gui, MyWindow:Add, Text, x15 y+2, Address CO:
Gui, MyWindow:Add, Text, vAddressCOID x+2 w100,

Gui, Tab, Leveler/Ults
Gui, MyWindow:Add, Text, x15 y35, Seats to level with Fkeys below Zone
Gui, MyWindow:Add, Edit, vLZEditID x+2 w50 +0x2000 ;vgLevelZone gChanged Range1-2001, % gLevelZone
Gui, MyWindow:Add, UpDown, vgLevelZone x+4 gChanged Range1-2001, % gLevelZone
GuiControl, Move, LZEditID, y+5
GuiControl, Move, gLevelZone, y+5


Loop, 12
{
	i := CheckboxSeat%A_Index%
	if Mod(A_Index, 6) = 1
		Gui, MyWindow:Add, Checkbox, vCheckboxSeat%A_Index% Checked%i% x15 y+5 w60 gBuild_Keys, Seat %A_Index%
	Else 
		Gui, MyWindow:Add, Checkbox, vCheckboxSeat%A_Index% Checked%i% x+5 w60 gBuild_Keys, Seat %A_Index%
}

Gui, MyWindow:Add, Checkbox, vgClickLeveling Checked%gClickLeveling% x15 y+20 gChanged, `Click Leveling
Gui, MyWindow:Add, Checkbox, vgRight Checked%gRight% x15 y+5 gChanged, Spam Right
Gui, MyWindow:Add, Checkbox, vgSpamQ Checked%gSpamQ% x15 y+5 gChanged, Spam Q
Gui, MyWindow:Add, Checkbox, vgGForce Checked%gGForce% x15 y+5 gChanged, Force auto progress

Gui, MyWindow:Add, Checkbox, vgUKeySpam Checked%gUKeySpam% x15 y+15 gChanged, Spam Ultimates
Gui, MyWindow:Add, Text, x15 y+5 w120, Ultimates to Spam:
Loop, 10
{
	i := CheckboxUlt%A_Index%
	if Mod(A_Index, 5) = 1
		Gui, MyWindow:Add, Checkbox, vCheckboxUlt%A_Index% Checked%i% x15 y+5 w60 gBuild_Keys, Slot %A_Index%
	Else 
		Gui, MyWindow:Add, Checkbox, vCheckboxUlt%A_Index% Checked%i% x+5 w60 gBuild_Keys, Slot %A_Index%
}


Gui, Tab, E Formation Zones

Gui, MyWindow:Add, Text, x15 y38 , Briv skip
Gui, MyWindow:Add, DDL, vgBrivSkip x+5 y35 w35 gBriv_Changed, 1||2|3|4|5|6|7|8|9
Gui, MyWindow:Add, Checkbox, vg100PercentBriv %g100PercentBriv% x+5 y38 gBriv_Changed, 100`%
Gui, MyWindow:Add, Button, vgLockFour %gLockFour% x+5 y33 gBriv_Lock, Unlock z4``s

Gui, MyWindow:add, Text, vBrivWarning x15 y+15 w400, Select your Briv

Gui, MyWindow:Add, Text, x15 y+10 , Use E Formation on these Zones
Loop, 50
{
	i := gZoneSkip[A_Index]
	if Mod(A_Index, 5) = 1
	Gui, MyWindow:Add, Checkbox, vCheckboxZoneSkip%A_Index% Checked%i% x15 y+5 w60 gSkip_Clicked, z%A_Index%
	Else 
	Gui, MyWindow:Add, Checkbox, vCheckboxZoneSkip%A_Index% Checked%i% x+5 w60 gSkip_Clicked, z%A_Index%
}

Gui, MyWindow:Show

WinSetTitle, ahk_pid %gScriptPID%, ,Adventure Time with LJ.

Build_Keys: ; Intentional placement so this function runs after Gui setup 
{
	Gui, Submit, NoHide
	gFKeys :=
	Loop, 12
	{
		if (CheckboxSeat%A_Index%)
		{
			gFKeys = %gFKeys%{F%A_Index%}
		}
	}
	gUKeys :=
	Loop, 10
	{
		if (CheckboxUlt%A_Index%)
		{
			if (A_Index = 10)
				gUKeys = %gUKeys%{0}
			else
				gUKeys = %gUKeys%{%A_Index%}
		}
	}
	return
}

return

Changed:
{
	Gui, Submit, NoHide
	Return
}

Stacks_Edit:
{
	Gui, Submit, NoHide
	if gMinStacksUI < 50
	{
		Gui, Font, cRed
		GuiControl, Font, StackID
	}
	Else
	{
		Gui, Font
		GuiControl, Font, StackID
		gMinStacks = %gMinStacksUI%
	}
	Return
}

FormationZone_Edit:
{
	Gui, Submit, NoHide
	if (gEFormationZoneUI > gMaxLevel OR gEFormationZoneUI <= 0)
	{
		Gui, Font, cRed
		GuiControl, Font, JUEFID
	}
	Else
	{
		Gui, Font
		GuiControl, Font, JUEFID
		gEFormationZone = %gEFormationZoneUI%
	}
	Return
}

Check_Values:
{
	if gMinStacksUI < 50
		gMinStacks := 50
	if gEFormationZoneUI > %gMaxLevel%
		gEFormationZone = %gMaxLevel%
	if gEFormationZoneUI < 1
		gEFormationZone = 1
	GuiControl, , gMinStacksUI , %gMinStacks%
	GuiControl, , gEFormationZoneUI , %gEFormationZone%
	Gui, Submit, NoHide
	Return
}

Skip_Clicked:
{
	Gui, Submit, NoHide
	Loop, 50
	{
		Checked := CheckboxZoneSkip%A_Index%
		gZoneSkip[A_Index] := %Checked%
	}
	GuiControl, , BrivWarning ,Selection Modified hope you know what your doing
	return
}

Briv_Changed:
{
	Gui, Submit, NoHide

	Briv_Lock(0)
	skip := Mod(gBrivSkip, 5)

	zone := (4 - skip)
	Loop, 50
	{
		CheckboxZoneSkip%A_Index% := 0
		GuiControl, MyWindow: , CheckboxZoneSkip%A_Index% , 0
		gZoneSkip[A_Index] := 0
			
		if ((Mod(A_Index, 5) = zone))
		{
			CheckboxZoneSkip%A_Index% := 1
			GuiControl, MyWindow: , CheckboxZoneSkip%A_Index% , 1
			gZoneSkip[A_Index] := 1
		}
		if (not g100PercentBriv and (Mod(A_Index, 5) = zone+1) and not skip = 1)
		{
			CheckboxZoneSkip%A_Index% := 1
			GuiControl, MyWindow: , CheckboxZoneSkip%A_Index% , 1
			gZoneSkip[A_Index] := 1
		}
	}

	Gui, Font
	GuiControl, , BrivWarning ,Selection Updated.
	GuiControl, Font, BrivWarning
	if (gBrivSkip = 5 or (gBrivSkip = 6 and not g100PercentBriv))
	{
		Gui, Font, cRed Bold
		GuiControl, , BrivWarning, Careful! You can land on bosses. 100`% 6 Skip recommended. GL!
		GuiControl, Font, BrivWarning
	}
	if ((gBrivSkip = 1) and not g100PercentBriv)
	{
		Gui, Font, cRed Bold
		GuiControl, , BrivWarning, You need at least 100`% 1 Skip Briv for Jimothy.
		GuiControl, Font, BrivWarning
	}
	Gui, Submit, NoHide

	return
}

Briv_Lock(bLock := 1)
{
	i = 4
	loop, 10
	{
		if (bLock)
			GuiControl, Enable, CheckboxZoneSkip%i%
		Else
			GuiControl, Disable, CheckboxZoneSkip%i%
		i += 5
	}
}

Save_Clicked:
{
	Gui, Submit, NoHide

	loop, 12
	{
		tVal := CheckboxSeat%A_Index%
    	IniWrite, %tVal%, ATSettings.ini, Section1, cbSeat%A_Index%
	}
	loop, 10
	{
		tVal := CheckboxUlt%A_Index%
    	IniWrite, %tVal%, ATSettings.ini, Section1, cbUlt%A_Index%
	}
	IniWrite, %gFKeySpam%, ATSettings.ini, Section1, FKeySpam
	IniWrite, %gUKeySpam%, ATSettings.ini, Section1, UKeySpam
	IniWrite, %gJFKeySpam%, ATSettings.ini, Section1, JFKeySpam
	IniWrite, %gJUKeySpam%, ATSettings.ini, Section1, JUKeySpam
	IniWrite, %gGForce%, ATSettings.ini, Section1, GForce
	IniWrite, %gMaxLevel%, ATSettings.ini, Section1, MaxZone
	IniWrite, %gLevelZone%, ATSettings.ini, Section1, LevelZone
	IniWrite, %gJUseEFormation%, ATSettings.ini, Section1, JUseEFormation
	IniWrite, %gEFormationZone%, ATSettings.ini, Section1, EFormationZone
	IniWrite, %gMinStacks%, ATSettings.ini, Section1, MinStacks
	IniWrite, %gRight%, ATSettings.ini, Section1, Right
	IniWrite, %gSpamQ%, ATSettings.ini, Section1, SpamQ
	IniWrite, %gBrivStackStop%, ATSettings.ini, Section1, BrivStop
	IniWrite, %gClickLeveling%, ATSettings.ini, Section1, ClickDmg
	loop, 50
	{
		tVal := CheckboxZoneSkip%A_Index%
		IniWrite, %tVal%, ATSettings.ini, Section1, SkipZone%A_Index%
		gZoneSkip[A_Index] := tVal
	}
	return
}

Reload_Clicked:
{
	Reload
	return
}

Run_Clicked:
{
	OpenProcess()
	WinSetTitle, ahk_pid %gScriptPID%, ,Adventure Time with LJ. Running: Leveler.
	loop
	{
		if (gGForce)
			ToggleAutoProgress(1)
		if (gClickLeveling)
			DirectedInput("{SC027}")
		if (gFkeySpam)
			LevelUp()
		if (gUkeySpam)
			DirectedInput(gUKeys)
		if (gRight)
			DirectedInput("{Right}")
		if (gSpamQ)
			DirectedInput("q")
		if (gMaxLevelStop AND ReadCurrentZone(1) > gMaxLevel)
		{
			StopProgression()
			Break
		}
	}
	return
}

Azaka_Clicked:
{
	GuiControl, Choose, Tabs, Azaka
	OpenProcess()
	AzakaFarm()
	return
}

FindHew()
{
    loop, 10
    {
        ChampSlot := A_Index - 1
        if (ReadChampIDbySlot(1,, ChampSlot) = 75)
        {
            gHewSlot := ChampSlot
            GuiControl, MyWindow:, HewSlotID, % gHewSlot
            Break
        }
    }
    return
}

Jimothy_Clicked:
{
	GuiControl, Choose, Tabs, Jimothy
    GuiControl, MyWindow:, Jimothy_ClickedID, Yes
	OpenProcess()
	FindHew()
	if (gJUseEFormation)
		DirectedInput("e")
	WinSetTitle, ahk_pid %gScriptPID%, ,Adventure Time with LJ. Running: Jimothy.
	loop
	{
		Jimothy()
		if (gJUseEFormation and ReadCurrentZone(1) < gEFormationZone)
			goto EformationSkip

		if (StackCheck())
			break
        SwapOutBriv()

EFormationSkip:
		if (gJFkeySpam)
			LevelUp()
		if (gJUkeySpam)
			DirectedInput(gUKeys)

		if (ReadCurrentZone(1) > gMaxLevel)
		{
			StopProgression()
			GuiControl, MyWindow:, Jimothy_ClickedID, Max Level reached
			WinSetTitle, ahk_pid %gScriptPID%, ,Adventure Time with LJ. Stopped: Max Zone.
			Break
		}
		ToggleAutoProgress(1)
	}
	return
}

StackCheck()
{
    gStackCountH := ReadHasteStacks(1)
    GuiControl, MyWindow:, ReadBrivStacksID, %gStackCountH%
    if (gStackCountH < gMinStacks)
	{       
        StopProgression()
        GuiControl, MyWindow:, Jimothy_ClickedID, No Stacks
		WinSetTitle, ahk_pid %gScriptPID%, ,Adventure Time with LJ. Stopped: no Briv Stacks.
       return 1
    }
	return 0
}

MyWindowGuiClose() 
{
	ExitApp
	MsgBox 4,, Are you sure you want to `exit?
	IfMsgBox Yes
	ExitApp
    IfMsgBox No
    return True
}

$`::
Pause::
Do_Pause:
{
	WinGetTitle, gLastTitle, ahk_pid %gScriptPID%
	SetTimer, Restore_Title, -5
	WinSetTitle, ahk_pid %gScriptPID%, , Adventure Time with LJ. --- Script Paused ---
	Pause
}

#If (A_IsPaused)
	$`::
	Pause::
	Pause, off	
	return
#If

Restore_Title:
{
	WinSetTitle, ahk_pid %gScriptPID%, , %gLastTitle%
	return
}

DirectedInput(s) 
{
	SafetyCheck()
	ControlFocus,, ahk_exe IdleDragons.exe
	ControlSend,, {Blind}%s%, ahk_exe IdleDragons.exe
	;Sleep, %ScriptSpeed%
}

SafetyCheck() 
{
	return ; TODO This fails for EGS users.. will fix at some point 
    While(Not WinExist("ahk_exe IdleDragons.exe")) 
    {
        Run, "C:\Program Files (x86)\Steam\steamapps\common\IdleChampions\IdleDragons.exe"
	    Sleep gOpenProcess
	    OpenProcess()
	    Sleep gGetAddress
		gPrevRestart := A_TickCount
		gPrevLevelTime := A_TickCount
	    ++ResetCount
    }
}

Jimothy()
{
	if (!ReadHeroAliveBySlot(1,, gHewSlot) OR gMaxMonsters < ReadMonstersSpawned(1))
	{
		DirectedInput("{Left}")
		StartTime := A_TickCount
		ElapsedTime := 0
		GuiControl, MyWindow:, HewAliveID, No
		while (ReadTransitioning(1) AND ElapsedTime < 5000)
		{
			Sleep, 100
			UpdateElapsedTime(StartTime)
		}
		Sleep, 1000
		ToggleAutoProgress(1)
	}
    else
	GuiControl, MyWindow:, HewAliveID, Yes
	Return
}

SwapOutBriv()
{
	i := mod(ReadCurrentZone(1), 50)
	if i = 0
		i := 50

	if (CheckboxZoneSkip%i%)
	{
		DirectedInput("e")
		Return 1
	}
	DirectedInput("q")
	return
}

StopProgression()
{
	StartTime := A_TickCount
	ElapsedTime := 0
	while (ReadTransitioning(1) AND ElapsedTime < 5000)
	{
		Sleep, 100
		UpdateElapsedTime(StartTime)
	}
	DirectedInput("{Left}")
	WinSetTitle, ahk_pid %gScriptPID%, ,Adventure Time with LJ. Stopped.
}

UpdateElapsedTime(StartTime)
{
	ElapsedTime := A_TickCount - StartTime
	GuiControl, MyWindow:, ElapsedTimeID, % ElapsedTime
	return ElapsedTime
}

AzakaFarm() 
{  
	TigerCount := 0
	GuiControl, MyWindow:, TigerCountID, % TigerCount
	WinSetTitle, ahk_pid %gScriptPID%, ,Adventure Time with LJ. Running: Azaka.
	loop 
	{
		numContractsFufilled := idle.read(addressCO, "Int")
		GuiControl, MyWindow:, numContractsFufilledID, % numContractsFufilled
		if (numContractsFufilled > 94)
		{
			DirectedInput("5")
			DirectedInput("9")
			++TigerCount
			GuiControl, MyWindow:, TigerCountID, % TigerCount
			numContractsFufilled := idle.read(addressCO, "Int")
			GuiControl, MyWindow:, numContractsFufilledID, % numContractsFufilled
			while (numContractsFufilled > 94)
			{
				numContractsFufilled := idle.read(addressCO, "Int")
				GuiControl, MyWindow:, numContractsFufilledID, % numContractsFufilled
				Sleep, 100				
			}
		}
		Sleep, 100
    }
	WinSetTitle, ahk_pid %gScriptPID%, ,Adventure Time with LJ. Running: Nothing.
	return
}

LevelUp()
{
    if (ReadCurrentZone(1) < gLevelZone)
		DirectedInput(gFKeys)
	return
}


SpecializeChamp(Choice, Choices)
{
    ScreenCenterX := (ReadScreenWidth(1) / 2)
    ScreenCenterY := (ReadScreenHeight(1) / 2)
    yClick := ScreenCenterY + 225
    ButtonWidth := 70
    ButtonSpacing := 180
    TotalWidth := (ButtonWidth * Choices) + (ButtonSpacing * (Choices - 1))
    xFirstButton := ScreenCenterX - (TotalWidth / 2)
    xClick := xFirstButton + 35 + (250 * (Choice - 1))
    WinActivate, ahk_exe IdleDragons.exe
    MouseClick, Left, xClick, yClick, 1
	return
}

;parameter should be 0 or 1, for off or on
ToggleAutoProgress( toggleOn := 1 )
{
    if ( ReadAutoProgressToggled( 1 ) != toggleOn )
    {
        DirectedInput( "{g}" )
    }
	return
}