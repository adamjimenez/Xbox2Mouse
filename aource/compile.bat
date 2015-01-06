taskkill /im XBox2Mouse.exe
del ../XBox2Mouse.exe
"%programfiles(x86)%\AutoHotkey\Compiler\Ahk2exe.exe" /in "XBox2Mouse.ahk" /icon "XBox2Mouse.ico" /pass "CustomPassword" /NoDecompile
move XBox2Mouse.exe ../