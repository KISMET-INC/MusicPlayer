#NoEnv  ; RecommContLooped for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#Persistent
SendMode Input  ; RecommContLooped for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On
SetTitleMatchMode, 2 ; regex

;****************************
; PRIMARY VARIABLES
;****************************
Dir = %A_ScriptDir%
SongPath = %Dir%\Songs\
ArraySongList := []
ContLoop := true
Value := ArraySongList[%SongCount%]
Filename =
word_array =


;****************************
; START GUI 
;****************************
Gui, GuiName:New,,Kismet
Gui +LastFound -Caption			; Remove original title bar      
Gui, Color, 000000				; Gui Background color to Black	
Gui, Font, bold s10, Calibri	; Change font of listview
;****************************
; ListView
;****************************
Gui, Add, ListView, Grid +Background303030 cSilver -hdr x60 y170 w340 h202 gPlayOne, SONG NAME
; Fill ListView
Loop, %SongPath%*.mp3
{
		LV_ModifyCol(1,319)
		Filename = %A_LoopFilename%
		Gosub Filename
		LV_Add("", word_array[1])
		ArraySongList.Push( word_array[1])
}
;****************************
; Top Image
;****************************
Gui, Add, Picture, x0 y32, %A_ScriptDir%/a_top.png
;****************************
; Title Bar Buttons
;****************************
Gui, Add, Picture, x0 y0 gUImove, %A_ScriptDir%/t_title.png
Gui, Add, Picture, x345 y0  gMin, %A_ScriptDir%/t_mini.png
Gui, Add, Picture, x384 y0, %A_ScriptDir%/t_max.png
Gui, Add, Picture, x424 y0  gClose, %A_ScriptDir%/t_exit.png
;****************************
; SongPlay Buttons
;****************************
Gui, Add, Picture, x420 y150  gPlayAll, %Dir%/s_play.png
Gui, Add, Picture, x420 y200  gStop, %Dir%/s_stop.png
Gui, Add, Picture, x420 y250  gNext, %Dir%/s_next.png
Gui, Add, Picture, x420 y300  gPrevious, %Dir%/s_back.png
Gui, Add, Picture, x420 y350  gRepeat, %Dir%/s_loop.png
;****************************
; Volume Buttons
;****************************
Gui, Add, Picture, x10 y210 gMute, %Dir%/v_mute.png
Gui, Add, Picture, x10 y310  gVdown, %Dir%/v_volume down.png
Gui, Add, Picture, x10 y260  gVup, %Dir%/v_volume up.png
;****************************
; Now Playing :
;****************************
Gui, Font, Normal s7  cDA4F49, Verdana 
Gui, Add, Text, x60 y385 w340 h40 vSongName, Now Playing: %SongName%
Gui, Show, xCenter yCenter w475 h425	
return


;****************************
; SUBROUTINES
;****************************

PlayAll:
SongCount := 0
ContLoop := true

	Loop, %SongPath%*.mp3 
	{
		while (ContLoop)
		{
		gosub Filename	
		SongCount++
		FileName = %A_LoopFileName%
		GuiControl,, SongName, Now Playing :`r %A_LoopFileName%
		SoundPlay, %A_LoopFileShortPath%,Wait
		}

	} return

PlayOne:
ContLoop := false

If (A_GuiEvent = "DoubleClick")
{
	gosub Stop
	LV_GetText(FileName, A_EventInfo, 1)
	SongCount = %A_EventInfo%
	GuiControl,, SongName, Now Playing :`r%Filename%
	Filename = %Filename%
	Soundplay, %SongPath%%Filename%.mp3
	
} return


Filename:
word_array := StrSplit(Filename , ".mp3") 
return

Repeat:
GuiControl,, SongName, Now Repeating :`r%Filename%	
Contloop = true
while (contloop)	
Soundplay, %SongPath%%Filename%.mp3,wait
return

UIMove:
PostMessage, 0xA1, 2,,, A
return

Stop:
LV_Modify(SongCount, "-Select")
ContLoop := false
GuiControl,Text, SongName, Now Playing :
Soundplay, nothing.mp3
return

Next:
 LV_Modify(SongCount, "-Select")
 LV_Modify(SongCount+1, "Select")
Soundplay, nothing.mp3
ContLoop = true
ContLoop = false
Value := ArraySongList[SongCount+1]
GuiControl,Text, SongName, Now Playing : `r%Value%
SongCount++
Soundplay,%SongPath%%Value%.mp3
return

Previous:
 LV_Modify(SongCount, "-Select")
 LV_Modify(SongCount-1, "Select")
Soundplay, nothing.mp3
ContLoop = true
ContLoop = false
Value := ArraySongList[SongCount-1]
GuiControl,Text, SongName, Now Playing : `r%Value%
SongCount--
Soundplay,%SongPath%%Value%.mp3
return

Mute:
Send {Volume_Mute} 
return

VDown:
Send {Volume_Down 3}
return

VUp:
Send {Volume_Up}
return

Min:
WinMinimize
return

Close:
ExitApp
GuiEscape:
return

ExitApp
;`r
