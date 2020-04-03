#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force
#Persistent
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On
SetTitleMatchMode, 2 ; regex

;****************************
; CALL DLL
;****************************
DllCall("LoadLibrary", Str, "Kismet Player Files\MediaInfo.dll")


;****************************
; PRIMARY VARIABLES
;****************************
Dir = %A_ScriptDir%
KismetDir = %Dir%\Kismet Player Files\
SongPath = %KismetDir%\Songs\
ArraySongList := []
ContLoop := true
Filename = 
ShortName_array =
Duration_array =
TotalMilliseconds =
LongPath =
ElapsedTime := 0


;****************************
; SETUP FILES AND FOLDERS
;****************************
gosub ProgramSetup


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
		Gosub ShortenFilename
		LV_Add("", ShortName_array[1])
		ArraySongList.Push( ShortName_array[1])
}
;****************************
; Top Image
;****************************
Gui, Add, Picture, x0 y32, %KismetDir%/a_top.png
;****************************
; Title Bar Buttons
;****************************
Gui, Add, Picture, x0 y0 gUImove, %KismetDir%/t_title.png
Gui, Add, Picture, x345 y0  gMin, %KismetDir%/t_mini.png
Gui, Add, Picture, x384 y0, %KismetDir%/t_max.png
Gui, Add, Picture, x424 y0  gClose, %KismetDir%/t_exit.png
;****************************
; SongPlay Buttons
;****************************
Gui, Add, Picture, x420 y150  gPlayAll, %KismetDir%/s_play.png
Gui, Add, Picture, x420 y200  gStop, %KismetDir%/s_stop.png
Gui, Add, Picture, x420 y250  gNext, %KismetDir%/s_next.png
Gui, Add, Picture, x420 y300  gPrevious, %KismetDir%/s_back.png
Gui, Add, Picture, x420 y350  gRepeat, %KismetDir%/s_loop.png
;****************************
; Volume Buttons
;****************************
Gui, Add, Picture, x10 y210 gMute, %KismetDir%/v_mute.png
Gui, Add, Picture, x10 y310  gVdown, %KismetDir%/v_volume down.png
Gui, Add, Picture, x10 y260  gVup, %KismetDir%/v_volume up.png
;****************************
; Now Playing :
;****************************
Gui, Font, Normal s7  cDA4F49, Verdana 
Gui, Add, Text, x60 y385 w340 h40 vSongName, Now Playing: %SongName%
Gui, Show, xCenter yCenter w475 h425	
return


;****************************
;
; SUBROUTINES
;
;****************************

;****************************
; Play All
;****************************
PlayAll:
ElapsedTime := 0
SongCount := 0
ContLoop := true

	Loop, %SongPath%*.mp3 
	{
		while (ContLoop)
		{
		
		SongCount++
			
			Filename = %A_LoopFileName%
			gosub ShortenFilename
			
			Filename = % ShortName_array[1]
			gosub GetDuration
		
		GuiControl,, SongName, Now Playing :`r%Filename%
		SetTimer ElapsedTimer, 1
		SoundPlay, %A_LoopFileShortPath%,Wait
		}

	} return

;****************************
; Play One
;****************************
PlayOne:
ContLoop := false
ElapsedTime := 0

If (A_GuiEvent = "DoubleClick")
{
	gosub Stop												; Stop loops and waits if needed
	LV_GetText(Filename, A_EventInfo, 1)
	SongCount = %A_EventInfo%
	gosub GetDuration
	
	
	GuiControl,, SongName, Now Playing :`r%Filename%		; Filename without .mp3
	Soundplay, %SongPath%%Filename%.mp3
	SetTimer, ElapsedTimer, 1	
	SetTimer, CheckTime, 1
	

} return

;****************************
; Elapsed Time
; Track Elapsed Time of Song
;****************************
ElapsedTimer:
ElapsedTime := ElapsedTime + 16

CheckTime:
IfGreaterorEqual, %ElapsedTime%,  %TotalMilliseconds% 		
	{
		MsgBox ForceStop
		SetTimer ElapsedTimer, Off
		ElapsedTime := 0
	}	
return

;****************************
; Shorten Filename
;****************************
ShortenFilename:
ShortName_array := StrSplit(Filename , ".mp3") 
return

;****************************
; Repeat
;****************************
Repeat:
GuiControl,, SongName, Now Repeating :`r%Filename%	
gosub GetDuration
SetTimer, RepeatQue, -%TotalMilliseconds%
return

;****************************
; Repeat Que
;****************************
RepeatQue:
GuiControl,, SongName, Now Repeating :`r%Filename%	
SetTimer, ElapsedTimer, OFF
Contloop := true
while (Contloop)	
{	
	Soundplay, %SongPath%%Filename%.mp3,wait
}
return

;****************************
; Move the UI
;****************************
UIMove:
PostMessage, 0xA1, 2,,, A
return

;****************************
; Stop Play
;****************************
Stop:
SetTimer, ElapsedTimer, Off

LV_Modify(SongCount, "-Select")
ContLoop := false
GuiControl,Text, SongName, Now Playing :
Soundplay, nothing.mp3
return

;****************************
; Next Song
;****************************
Next:
 LV_Modify(SongCount, "-Select")
 LV_Modify(SongCount+1, "Select")
gosub Stop
Filename := ArraySongList[SongCount+1]
gosub GetDuration
GuiControl,Text, SongName, Now Playing : `r%Filename%
SongCount++
Soundplay,%SongPath%%Filename%.mp3
return

;****************************
; Previous Song
;****************************
Previous:
 LV_Modify(SongCount, "-Select")
 LV_Modify(SongCount-1, "Select")
gosub Stop
Filename := ArraySongList[SongCount-1]
gosub GetDuration
GuiControl,Text, SongName, Now Playing : `r%Filename%
SongCount--
Soundplay,%SongPath%%Filename%.mp3
return

;****************************
; Mute
;****************************
Mute:
Send {Volume_Mute} 
return

;****************************
; Volume Down
;****************************
VDown:
Send {Volume_Down 3}
return

;****************************
; Volume Up
;****************************
VUp:
Send {Volume_Up}
return

;****************************
; Minimize Window
;****************************
Min:
WinMinimize
return

;****************************
; Close App
;****************************
Close:
ExitApp


;****************************
; Get Duration of Song 
;****************************
GetDuration:
LongPath = %SongPath%%Filename%.mp3
SongMetaData := MediaInfo_DumpInfo(LongPath)
SetTimer, ElapsedTimer, Off

Loop, parse, SongMetaData, `n,
         {
         If A_LoopField contains Duration
            {
			DurationLine = %A_LoopField%
			Duration_Array := StrSplit( DurationLine," ","Duration                                 :")
			MinutesDuration := Duration_Array [35]
			SecondsDuration := Duration_Array [37]
			MinutesTotal := % MinutesDuration * 60000
			SecondsTotal := % SecondsDuration * 1000
			TotalMilliseconds := MinutesTotal + SecondsTotal - ElapsedTime
			Break
            }
         }
		Return

MediaInfo_DumpInfo(MediaFile := "") {
   Static A := A_IsUnicode ? "" : "A"
   Static New := "MediaInfo.dll\MediaInfo" . A . "_New"
   Static Open := "MediaInfo.dll\MediaInfo" . A . "_Open"
   Static Inform := "MediaInfo.dll\MediaInfo" . A . "_Inform"
   Static Delete := "MediaInfo.dll\MediaInfo" . A . "_Delete"
   hnd := DllCall(New)
   DllCall(Open, "UInt", hnd, "Str", MediaFile)
   Info := DllCall(Inform, "UInt", hnd, "UInt", 0, "Str")
   DllCall(Delete, "UInt", hnd)
   Return Info
}
;****************************
; INSTALLATION FILES
;****************************
ProgramSetup:
FileCreateDir, Kismet Player Files
FileCreateDir, Kismet Player Files\Songs\

FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\a_exit.png,Kismet Player Files\a_exit.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\a_play.jpg,Kismet Player Files\a_play.jpg, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\a_title.png,Kismet Player Files\a_title.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\a_top.png,Kismet Player Files\a_top.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\s_back.png,Kismet Player Files\s_back.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\s_loop.png,Kismet Player Files\s_loop.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\s_next.png,Kismet Player Files\s_next.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\s_next.png,Kismet Player Files\s_next.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\s_play.png,Kismet Player Files\s_play.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\s_stop.png,Kismet Player Files\s_stop.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\t_exit.png,Kismet Player Files\t_exit.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\t_max.png,Kismet Player Files\t_max.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\t_mini.png,Kismet Player Files\t_mini.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\t_title.png,Kismet Player Files\t_title.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\v_mute.png,Kismet Player Files\v_mute.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\v_volume down.png,Kismet Player Files\v_volume down.png, Overwrite
FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\v_volume up.png,Kismet Player Files\v_volume up.png, Overwrite

FileInstall,D:\PROJECTS\SOFTWARE DEV PROJECTS\AutoHotKey\MusicPlayer\Kismet Player Files\MediaInfo.dll,Kismet Player Files\MediaInfo.dll, Overwrite
return

; new line character = `r
