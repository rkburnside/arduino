#SingleInstance Force
#Persistent


;--PERSONAL HOTKEYS--
<!f::run http://www.feedly.com/home#latest
<!x::run C:\Users\rburnsid\Documents\Apps\SpeedCrunchPortable\SpeedCrunchPortable.exe
<!n::run C:\Users\rburnsid\Documents\Apps\Notepad++Portable\Notepad++Portable.exe
<!c::run C:\Users\rburnsid\Documents\Apps\ConvertAllPortable\ConvertAllPortable.exe
;<!t::run C:\Users\rburnsid\Documents\Apps\SnapTimerPortable\SnapTimerPortable.exe
#e::run explorer.exe c:\users\rburnsid\desktop
;<!n::run http://www.investors.com
;<!g::run http://www.google.com
;<!v::run http://www.google.com/voice

;--WORK HOTKEYS--
<!i::run \\astdfs.ast.lmco.com\data\SES\IDEAS\IDEAS_Admin\ID15\admin\ideas.cmd
<!g::run https://space-migrate.p.external.lmco.com/sites/GR/IandT/MGSE
<!m::run http://www.mcmaster.com
<!l::run h:\work logs\time logger-txt.vbs
<!o::run h:\work logs\time logger-txt-with timer.vbs
<!p::run firefox.exe https://pdm-ssc.p.external.lmco.com/
;<!p::run https://pdm-ssc.p.external.lmco.com/

;--SOUND HOTKEYS--
;<!d::SoundSet +5 ;Increase master volume by 1%
;<!a::SoundSet -5 ;Decrease master volume by 1%
;<!s::soundset +1,, mute   ;mutes the sound

<!d::send {Volume_Up}
<!a::send {Volume_Down}
<!s::send {Volume_Mute}

<!v::send rburnsid{tab}.U1i2o3p4.{Enter}