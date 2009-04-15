; run script through pipe by lexikos
;; http://www.autohotkey.com/forum/topic25867.html
#NoEnv

start:
ahkdll := DllCall("LoadLibrary", "str", "AutoHotkey.dll")

InputBox, Script, Script, Enter a line of script to execute.,,, 120,,,,, MsgBox :D

; To prevent "collision", pipe_name could be something mostly "unique", like:
;   pipe_name := A_TickCount
pipe_name := "testpipe"
fullpipe_name := "\\.\pipe\" . pipe_name
; Before reading the file, AutoHotkey calls GetFileAttributes(). This causes
; the pipe to close, so we must create a second pipe for the actual file contents.
; Open them both before starting AutoHotkey, or the second attempt to open the
; "file" will be very likely to fail. The first created instance of the pipe
; seems to reliably be "opened" first. Otherwise, WriteFile would fail.
pipe_ga := CreateNamedPipe(pipe_name, 2)
pipe    := CreateNamedPipe(pipe_name, 2)
if (pipe=-1 or pipe_ga=-1) {
    MsgBox CreateNamedPipe failed.
    ExitApp
}


DllCall("AutoHotkey\ahkdll", "str", fullpipe_name, "str"
, "1234567", "Cdecl Int")
sleep, 1000  
; Run, %A_AhkPath% "\\.\pipe\%pipe_name%"
; Wait for AutoHotkey to connect to pipe_ga via GetFileAttributes().
DllCall("ConnectNamedPipe","uint",pipe_ga,"uint",0)
; This pipe is not needed, so close it now. (The pipe instance will not be fully
; destroyed until AutoHotkey also closes its handle.)
DllCall("CloseHandle","uint",pipe_ga)
; Wait for AutoHotkey to connect to open the "file".
DllCall("ConnectNamedPipe","uint",pipe,"uint",0)

; AutoHotkey reads the first 3 bytes to check for the UTF-8 BOM "﻿". If it is
; NOT present, AutoHotkey then attempts to "rewind", thus breaking the pipe.
Script := chr(239) chr(187) chr(191) Script

if !DllCall("WriteFile","uint",pipe,"str",Script,"uint",StrLen(Script)+1,"uint*",0,"uint",0)
    MsgBox WriteFile failed: %ErrorLevel%/%A_LastError%

DllCall("CloseHandle","uint",pipe)


CreateNamedPipe(Name, OpenMode=3, PipeMode=0, MaxInstances=255) {
    return DllCall("CreateNamedPipe","str","\\.\pipe\" Name,"uint",OpenMode
        ,"uint",PipeMode,"uint",MaxInstances,"uint",0,"uint",0,"uint",0,"uint",0)
}



!q::ExitApp
