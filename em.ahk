;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init
#NoEnv
SendMode Input

#InstallKeybdHook
#UseHook
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; static

; var
c_x := false ; c-x is hit
mark := false ; mark text
EmacsOn := false
SetEmacsMode(false)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; toggle emacs mode: Shift+Capslock
+CapsLock::
SetEmacsMode(!EmacsOn)
return
; func
SetEmacsMode(stat)
{
	local state := stat ? "On" : "Off"
	EmacsOn := stat
	TrayTip, Emacs Mode, Emacs Mode is %state%, 10, 1
	Menu, Tray, Tip, Emacs Mode`nEmacs Mode is %state%
	Send {Shift Up}
}

disableCX(b) ;diable c-x if true
{
	global c_x
	if b
		c_x := false
}

IsTarget() ; determine if active window is target, add your emacs target here
{
	if WinActive("ahk_exe devenv.exe")
	{
		return true
	} else if WinActive("ahk_exe Code.exe")
	{
		return true
	}
	return false
}

IsEmacsOn() ; determine if emacs hot key is enabled
{
	global EmacsOn
	if EmacsOn
	{
		return IsTarget()
	}
	return false
}

SendKeyByEmacsMode(emacsKey, b)
{ ; if emacs on, call emacsKey function, and disable c-x by b value
	if IsEmacsOn()
	{
		%emacsKey%()
		disableCX(b)
		return
	}
	Send, %A_ThisHotkey%
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; emacs keys

emacs_c_x() ; c-x,and show status on tray tip
{
	global c_x
	c_x := !c_x
	state := c_x ? "On" : "Off"
	TrayTip, Emacs Mode, c-x is %state%, 3, 1
}

emacs_file_begin()
{
	global mark
	if mark
	{
		Send +^{Home}
		return
	}
	Send ^{Home}
}

emacs_file_end()
{
	global mark
	if mark
	{
		Send +^{End}
		return
	}
	Send ^{End}
}

emacs_word_left()
{
	global mark
	if mark {
		Send +^{Left}
		return
	}
	Send ^{Left}
}

emacs_left() ; move left
{
	global mark
	if mark
		Send +{Left}
	else
		Send {Left}
}

emacs_word_right()
{
	global mark
	if mark {
		Send +^{Right}
		return
	}
	Send ^{Right}
}

emacs_right() ; move right
{
	global mark
	if mark
		Send +{Right}
	else
		Send {Right}
}

emacs_up() ; move up
{
	global mark
	if mark
	{
		Send +{Up}
	}
	else
		Send {Up}
}

emacs_down() ; move down
{
	global mark
	if mark
		Send +{Down}
	else
		Send {Down}
}

emacs_quit() ; quit, disable c-x and mark, and send escape
{
	global mark, c_x
	mark := false
	c_x := false
	Send {ESC}
}

emacs_c_f() ; c-f if c-x is pressed, send ctrl-o, if not, move right
{
	global c_x
	if c_x
	{		
		Send ^o
	} else
	{
		emacs_right()
	}
}

emacs_c_b() ; c-b
{ 
	emacs_left()
}

emacs_c_n() ; c-n
{
	emacs_down()
}

emacs_c_p() ; c-p
{
	emacs_up()
}

emacs_c_g() ; c-g
{
	emacs_quit()
}

emacs_c_k() ; c-k: kill to line end
{
	global c_x
	if c_x
		return
	Send +{End}
	Sleep 1
	Send ^{x}
}

emacs_k() ; k, if c-x is pressed, send ctrl-f4
{
	global c_x
	if c_x
	{
		Send ^{F4}
		return
	}
	Send {k}
}

emacs_u() ; u, if c-x is pressed, call emacs_undo
{
	global c_x
	if c_x
	{
		emacs_undo()
		return
	}
	Send {u}
}

emacs_m_at() ; meta-shift-2, show mark mode on tray tip
{
	global mark
	mark := !mark
	state := mark ? "On" : "Off"
	TrayTip, Emacs Mode, Mark Mode is %state%, 3, 1
	if !mark
	{
		Send {Esc}
		return
	}
	Send ^{@} ; to disable ime
}

emacs_line_begin() ; move to line begin
{
	global mark
	if mark
	{
		Send +{Home}+{Home}
		return
	}
	Send {Home}{Home}
}

emacs_line_text_begin() ; move to text begin
{
	global mark
	if mark
	{
		Send +{End}+{Home}
		return
	}
	Send {End}{Home}
}

emacs_line_end() ; move to line end
{
	global mark
	if mark
	{
		Send +{End}
		return
	}
	Send {End}
}

emacs_cut() ; c-w
{
	Send ^{x}
	emacs_quit()
}

emacs_copy() ; m-w
{
	Send ^{c}
	emacs_quit()
}

emacs_yank() ; c-y
{
	Send ^{v}
}

emacs_yank_ring() ; m-y
{
	Send ^+{Insert}
}

emacs_undo() ; c-x u
{
	Send ^z
}

m_g := false
emacs_m_g() ; m-g
{
	global m_g
	if m_g
	{
		Send ^g
	}
	m_g := !m_g
}

emacs_page_up()
{
	global mark
	if mark
	{
		Send +{PgUp}
		return
	}
	Send {PgUp}
}

emacs_page_down()
{
	global mark
	if mark
	{
		Send +{PgDn}
		return
	}
	Send {PgDn}
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; keys map
^x:: SendKeyByEmacsMode("emacs_c_x", false)
^f:: SendKeyByEmacsMode("emacs_c_f", true)
^b:: SendKeyByEmacsMode("emacs_c_b", true)
^n:: SendKeyByEmacsMode("emacs_c_n", true)
^p:: SendKeyByEmacsMode("emacs_c_p", true)
^g:: SendKeyByEmacsMode("emacs_c_g", true)
^+2:: SendKeyByEmacsMode("emacs_m_at", true)
^a:: SendKeyByEmacsMode("emacs_line_begin", true)
!m:: SendKeyByEmacsMode("emacs_line_text_begin", true)
^e:: SendKeyByEmacsMode("emacs_line_end", true)
^w:: SendKeyByEmacsMode("emacs_cut", true)
!w:: SendKeyByEmacsMode("emacs_copy", true)
^y:: SendKeyByEmacsMode("emacs_yank", true)
!y:: SendKeyByEmacsMode("emacs_yank_ring", true)
^k:: SendKeyByEmacsMode("emacs_c_k", true)
k:: SendKeyByEmacsMode("emacs_k", true)
u:: SendKeyByEmacsMode("emacs_u", true)
!g:: SendKeyByEmacsMode("emacs_m_g", true)
!f:: SendKeyByEmacsMode("emacs_word_right", true)
!b:: SendKeyByEmacsMode("emacs_word_left", true)
!>:: SendKeyByEmacsMode("emacs_file_end", true)
!<:: SendKeyByEmacsMode("emacs_file_begin", true)
^v:: SendKeyByEmacsMode("emacs_page_down", true)
!v:: SendKeyByEmacsMode("emacs_page_up", true)