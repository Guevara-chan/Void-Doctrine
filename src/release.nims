mode = ScriptMode.Verbose
exec """nim compile --d:release --cpu:ia64 -t:-m64 -l:-m64 --out:"../Void°Doctrine.exe" main.nim"""
exec """nim compile --d:release --opt:size --cpu:i386 -t:-m32 -l:-m32 --out:"../Void°Doctrine•x86.exe" main.nim"""
#exec """nim compile --d:release --opt:size --out:"../Void°Doctrine.elf" --os:linux main.nim"""
if existsFile "../test.exe": rmFile "../test.exe"
