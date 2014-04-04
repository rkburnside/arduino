#SingleInstance Force
#Persistent
#InstallMouseHook


;Pro/e Mouse Button Remapping
F10::
Send {Shift down} & {MButton down}
KeyWait F10
Send {Shift up} & {MButton up}
return

F9::
Send {Control down} & {MButton down}
KeyWait F9
Send {Control up} & {MButton up}
return