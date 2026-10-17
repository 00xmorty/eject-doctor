Output "assets/demo.gif"
Set Shell "zsh"
Set FontFamily "Menlo"
Set FontSize 17
Set Width 1500
Set Height 850
Set TypingSpeed 20ms
Set Framerate 12
Hide
Type "exec zsh -f" Enter
Sleep 300ms
Type "source demo/setup.zsh; clear" Enter
Sleep 500ms
Show
Type "# Illustrative demo data (not a real machine)" Enter
Type "./eject-doctor.zsh --version" Enter
Sleep 2s
Type "./eject-doctor.zsh sample" Enter
Sleep 2s
Sleep 5s
