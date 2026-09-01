#Requires AutoHotkey v2.0

; HotString
::ooo::いつもお世話になっております。
::ddd::どうぞよろしくお願いいたします。
::hhh::白皓東

; Remap Ctrl:
~LControl up::{
    if (A_PriorKey = "LControl") {
          Send "{Esc}"
    }
}

; Remap Alt:
; ~LAlt up::{
;     if (A_PriorKey = "LAlt") {
;       Send "!{sc029}"
;     }
; }

; Remap Shift For change IME mode:
#HotIf !WinActive("ahk_exe mstsc.exe")
~LShift up::{
   if (A_PriorKey = "LShift") {
     Send "!{sc029}"
   }
}
#HotIf


; lock screen
^!q::DllCall("LockWorkStation")
; open task view
^!l::Send "#{Tab}"

!+s::{
    Send "{PrintScreen}"
}

#+s::{
    Send "#{PrintScreen}"
}

GroupAdd "CtrlGroup", "ahk_class org.wezfurlong.wezterm"
GroupAdd "CtrlGroup", "ahk_class CabinetWClass"
GroupAdd "CtrlGroup", "ahk_class CASCADIA_HOSTING_WINDOW_CLASS"
GroupAdd "CtrlGroup", "ahk_exe devenv.exe" 
GroupAdd "CtrlGroup", "ahk_exe Code.exe"
GroupAdd "CtrlGroup", "ahk_exe qgis-ltr-bin.exe" 
GroupAdd "CtrlGroup", "ahk_exe qgis-bin.exe" 
GroupAdd "CtrlGroup", "ahk_exe qutebrowser.exe" 
GroupAdd "CtrlGroup", "ahk_exe mintty.exe" 
GroupAdd "CtrlGroup", "ahk_exe blender.exe"
; remote desktop client
GroupAdd "CtrlGroup", "ahk_exe mstsc.exe"

#HotIf WinActive("ahk_exe mstsc.exe")
; *F1::MsgBox "Local F1 detected"
^q::^+q
; *F1::Run "ShareX.exe -RectangleRegion"
; F2::Run "ShareX.exe -LastRegion"
*F1::Run '"' ProcessGetPath("ShareX.exe") '" -RectangleRegion'
*F2::Run '"' ProcessGetPath("ShareX.exe") '" -LastRegion'
#HotIf

#HotIf WinActive("ahk_exe POWERPNT.EXE")
XButton1::Send "^z"
XButton2::Send "^y"
#HotIf

#HotIf WinActive("ahk_exe blender.exe")
XButton1::Send "^z"
XButton2::Send "^+z"
#HotIf

#HotIf WinActive("ahk_exe paraview.exe")
XButton1::Send "!7"    ; button4 -> Alt+7
XButton2::Send "!8"   ; button5 -> Alt+8
~LAlt::Send "{Blind}{sc0E9}"
~RAlt::Send "{Blind}{sc0E9}"
!e::Send "^!e"   ; Alt+E -> Ctrl+Alt+E (bind custom action to Ctrl+Alt+E in ParaView)
!s::Send "^!s"
!f::Send "^!f"
!v::Send "^!v"
!x::Send "^!x"
!c::Send "^!c"
#HotIf
#HotIf !WinActive("ahk_group CtrlGroup")
;^a::MsgBox "You are currently using Notepad"
!a::^a
!w::^w
^h::Backspace
; ^d::Delete
; ^k::^Delete
^a::Home
^e::End
^p::Up
^n::Down
^b::Left
^f::Right
^p::Up
^n::Down
;Qgis
#HotIf WinActive("ahk_exe qgis-ltr-bin.exe")
!s::!1 ; open properties
!w::!2 ; close windows
!d::!3 ; open data_source_manager
!j::!4 ; toggle python console
^a::Home
^e::End
#HotIf
#HotIf WinActive("ahk_exe qgis-bin.exe")
!s::!1 ; open properties
!w::!2 ; close windows
!d::!3 ; open data_source_manager
!j::!4 ; toggle python console
^a::Home
^e::End
^h::Backspace
#HotIf
#HotIf WinActive("ahk_exe devenv.exe") || WinActive("ahk_exe Code.exe")
^a::Home
^e::End
^b::Left
; ^f::Right
^h::Backspace
#HotIf
#HotIf WinActive("ahk_exe wezterm-gui.exe")
^p::Up
^n::Down
;^+x::Send "^+x"
#HotIf
#HotIf  WinActive("ahk_exe qutebrowser.exe")
^p::Up
^n::Down
^e::{
    if WinExist("ahk_class CabinetWClass ahk_exe explorer.exe")
        WinActivate
    else
        Run "explorer.exe"
}
#HotIf
; ParaView: stop a bare Alt tap from activating the menu bar, so Alt stays
; free as a modifier for custom shortcuts. Injects a phantom keystroke
; (sc0E9, unassigned) between Alt down/up so ParaView never sees a clean tap.
#HotIf WinActive("ahk_class CabinetWClass")
; Hotkeys only work in Explorer
!n::#e
;tail folder
!,::#Left
!.::#Right
^a::Home
^e::End
^h::Backspace
^+x::Send "{Delete}"
^r::Send "^+{n}"
^s::Send "!{Left}"
^d::{
    KeyWait "LControl"
        KeyWait "RControl"
    Send "!{Up}"
}
^f::Send "!{Right}"
#HotIf

#HotIf WinActive("ahk_exe chrome.exe")
!e::SendText "^"
!1::Send "^1"
!2::Send "^2"
!3::Send "^3"
!4::Send "^4"
!5::Send "^5"
#HotIf

; shortcut to open app
; wezterm
^q::{
    global GetCurrentDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    if (current = 2){
      Send "^+5"
      return
    }
    if (current != 1){
      GoToDesktopNumber(1)
    if WinExist("ahk_exe wezterm-gui.exe")
        WinActivate
    }else{
    ; if WinActive("ahk_exe wezterm-gui.exe")
    ;     WinMinimize "A"
    ; else if WinExist("ahk_exe wezterm-gui.exe")
    ;     WinActivate
    if WinExist("ahk_exe wezterm-gui.exe")
        WinActivate
    }
}
; qutebrowser
$^w::{
    global GetCurrentDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    if (current = 2){
      Send "^+6"
      return
    }
    DetectHiddenWindows True
    if WinExist("ahk_exe qutebrowser.exe")
        WinActivate
    else
        Run "qutebrowser.exe"
    DetectHiddenWindows False
}
; thunderbird
!^s::{
    DetectHiddenWindows True
    Run "thunderbird.exe"   ; $ stops Send from triggering this hotkey
    DetectHiddenWindows False
}
; chrome
; ^!p::MsgBox "Ctrl+Shift+W works"
^+q::{
    DetectHiddenWindows True
    if WinExist("ahk_exe chrome.exe")
        WinActivate
    else
        Run "chrome.exe"
    DetectHiddenWindows False
}
; paraview
^!p::{
    ; DetectHiddenWindows True
    ; if WinExist("ahk_exe paraview.exe")
    ;     WinActivate
    ; else
    ;     Run "paraview.exe"
    ; DetectHiddenWindows False
    global GetCurrentDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    if (current != 0){
      GoToDesktopNumber(0)
    if WinExist("ahk_exe paraview.exe")
        WinActivate
    }else{
    if WinExist("ahk_exe paraview.exe")
        WinActivate
    }
}


!m::{
    A_Clipboard := "hakukt@hydrosoken.co.jp"
    Send "^v"
}



SetWorkingDir(A_ScriptDir)

; Path to the DLL, relative to the script
VDA_PATH := "C:\Users\hakukt\bin\VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")

if !hVirtualDesktopAccessor {
    MsgBox "Failed to load DLL:`n" VDA_PATH
    ExitApp
}

GetDesktopCountProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopCount", "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
GetCurrentDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetCurrentDesktopNumber", "Ptr")
IsWindowOnCurrentVirtualDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnCurrentVirtualDesktop", "Ptr")
IsWindowOnDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsWindowOnDesktopNumber", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")
IsPinnedWindowProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "IsPinnedWindow", "Ptr")
GetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GetDesktopName", "Ptr")
SetDesktopNameProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "SetDesktopName", "Ptr")
CreateDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "CreateDesktop", "Ptr")
RemoveDesktopProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RemoveDesktop", "Ptr")

; On change listeners
RegisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "RegisterPostMessageHook", "Ptr")
UnregisterPostMessageHookProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "UnregisterPostMessageHook", "Ptr")

GetDesktopCount() {
    global GetDesktopCountProc
    count := DllCall(GetDesktopCountProc, "Int")
    return count
}

MoveCurrentWindowToDesktop(number) {
    global MoveWindowToDesktopNumberProc, GoToDesktopNumberProc
    activeHwnd := WinGetID("A")
    DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", number, "Int")
    DllCall(GoToDesktopNumberProc, "Int", number, "Int")
}

GoToPrevDesktop() {
    global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is 0, go to last desktop
    if (current = 0) {
        dest := last_desktop
    } else {
        dest := current - 1
    }
    MoveOrGotoDesktopNumber(dest)
    Sleep 100
    FocusTopWindowOnDesktop(dest)
    return
}

GoToNextDesktop() {
    global GetCurrentDesktopNumberProc, GoToDesktopNumberProc
    current := DllCall(GetCurrentDesktopNumberProc, "Int")
    last_desktop := GetDesktopCount() - 1
    ; If current desktop is last, go to first desktop
    if (current = last_desktop) {
        dest := 0
    } else {
        dest := current + 1
    }
    MoveOrGotoDesktopNumber(dest)
    Sleep 100
    FocusTopWindowOnDesktop(dest)
    return
}

GoToDesktopNumber(num) {
    global GoToDesktopNumberProc
    DllCall(GoToDesktopNumberProc, "Int", num, "Int")
    return
}
GoToDesktopAndFocusTopWindow(num) {
    GoToDesktopNumber(num)
    Sleep 100
    FocusTopWindowOnDesktop(num)
}

FocusTopWindowOnDesktop(num) {
    global IsWindowOnDesktopNumberProc, IsPinnedWindowProc

    for hwnd in WinGetList() {
        if !DllCall("IsWindowVisible", "Ptr", hwnd, "Int")
            continue
        if WinGetMinMax("ahk_id " hwnd) = -1
            continue
        if DllCall(IsPinnedWindowProc, "Ptr", hwnd, "Int")
            continue
        if !DllCall(IsWindowOnDesktopNumberProc, "Ptr", hwnd, "UInt", num, "Int")
            continue

        try {
            WinActivate("ahk_id " hwnd)
            WinWaitActive("ahk_id " hwnd, , 0.5)
            FocusRemoteDesktopClient(hwnd)
        }
        break
    }
}

FocusRemoteDesktopClient(hwnd) {
    try exe := WinGetProcessName("ahk_id " hwnd)
    catch
        return

    if (exe != "mstsc.exe")
        return

    try ControlFocus("ahk_class TscShellContainerClass", "ahk_id " hwnd)
    try ControlFocus("ahk_class IHWindowClass", "ahk_id " hwnd)

    ; mstsc needs a real mouse click to start capturing keyboard input in the
    ; remote session. Warp the cursor into the client area and click there —
    ; a real click happens at the cursor's actual position so RDP sees a plain
    ; click instead of the synthetic-click drag from ControlClick.
    try {
        WinGetClientPos(&cx, &cy, &cw, &ch, "ahk_id " hwnd)
        MouseMove cx + cw // 2, cy + ch // 2, 0
        Click
    }
}

MoveOrGotoDesktopNumber(num) {
    ; If user is holding down Mouse left button, move the current window also
    if (GetKeyState("LButton")) {
        MoveCurrentWindowToDesktop(num)
    } else {
        GoToDesktopNumber(num)
    }
    return
}
GetDesktopName(num) {
    global GetDesktopNameProc
    utf8_buffer := Buffer(1024, 0)
    ran := DllCall(GetDesktopNameProc, "Int", num, "Ptr", utf8_buffer, "Ptr", utf8_buffer.Size, "Int")
    name := StrGet(utf8_buffer, 1024, "UTF-8")
    return name
}
SetDesktopName(num, name) {
    global SetDesktopNameProc
    OutputDebug(name)
    name_utf8 := Buffer(1024, 0)
    StrPut(name, name_utf8, "UTF-8")
    ran := DllCall(SetDesktopNameProc, "Int", num, "Ptr", name_utf8, "Int")
    return ran
}
CreateDesktop() {
    global CreateDesktopProc
    ran := DllCall(CreateDesktopProc, "Int")
    return ran
}
RemoveDesktop(remove_desktop_number, fallback_desktop_number) {
    global RemoveDesktopProc
    ran := DllCall(RemoveDesktopProc, "Int", remove_desktop_number, "Int", fallback_desktop_number, "Int")
    return ran
}

; SetDesktopName(0, "It works! 🐱")

DllCall(RegisterPostMessageHookProc, "Ptr", A_ScriptHwnd, "Int", 0x1400 + 30, "Int")
OnMessage(0x1400 + 30, OnChangeDesktop)
OnChangeDesktop(wParam, lParam, msg, hwnd) {
    Critical(1)
    OldDesktop := wParam + 1
    NewDesktop := lParam + 1
    Name := GetDesktopName(NewDesktop - 1)

    ; Use Dbgview.exe to checkout the output debug logs
    OutputDebug("Desktop changed to " Name " from " OldDesktop " to " NewDesktop)
    ; TraySetIcon(".\Icons\icon" NewDesktop ".ico")
}

; --- Keep AutoHotkey's keyboard hook above the RDP client's hook ---
; mstsc.exe installs its OWN low-level keyboard hook every time its window is
; activated (to forward keys into the remote session). Windows calls the
; most-recently-installed hook first, so mstsc's hook sits above AHK's and
; swallows the FIRST Ctrl+<n> after you click into the session -- which is why
; the switcher seems to need a double-press. Re-installing AHK's hook right
; after mstsc grabs focus puts AHK back on top, so the first press works.
DllCall("RegisterShellHookWindow", "Ptr", A_ScriptHwnd)
ShellHookMsg := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(ShellHookMsg, OnShellMessage)
OnShellMessage(wParam, lParam, msg, hwnd) {
    static HSHELL_WINDOWACTIVATED := 4, HSHELL_RUDEAPPACTIVATED := 0x8004
    if (wParam != HSHELL_WINDOWACTIVATED && wParam != HSHELL_RUDEAPPACTIVATED)
        return
    try {
        if (WinGetProcessName("ahk_id " lParam) = "mstsc.exe") {
            ; Toggling Suspend forces AHK to re-install its keyboard hook.
            Suspend true
            Suspend false
        }
    }
}

SwitchDesktopHotkey(num, numberKey) {
    if WinActive("ahk_exe mstsc.exe") {
        ; RDP can keep Ctrl/number captured during the hotkey. Switch after
        ; release so the local desktop change and RDP focus click happen cleanly.
        KeyWait numberKey
        KeyWait "LControl"
        KeyWait "RControl"
        Sleep 30
    }
    GoToDesktopAndFocusTopWindow(num)
}

$^1::SwitchDesktopHotkey(0, "1")
$^2::SwitchDesktopHotkey(1, "2")
$^3::SwitchDesktopHotkey(2, "3")
$^4::SwitchDesktopHotkey(3, "4")
$^5::SwitchDesktopHotkey(4, "5")

$!+1::MoveCurrentWindowToDesktop(0)
$!+2::MoveCurrentWindowToDesktop(1)
$!+3::MoveCurrentWindowToDesktop(2)
$!+4::MoveCurrentWindowToDesktop(3)
$!+5::MoveCurrentWindowToDesktop(4)


; --- Change Desktops (Fixed) ---
*!^k::{
    GoToNextDesktop()

}

*!^j::{
   GoToPrevDesktop()

}


;KeyHistory
