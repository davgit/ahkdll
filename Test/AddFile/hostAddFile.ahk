start:
ahkdll := DllCall("LoadLibrary", "str", "AutoHotkey.dll")
sleep, 500
threadH := DllCall("AutoHotkey.dll\ahkdll", "str", "dllAddFile.ahk", "str"
, "", "str", "parameter1 parameter2", "Cdecl Int") 
return

!r::
Reload

!q::
ExitApp
