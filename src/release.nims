mode = ScriptMode.Verbose
exec """nim compile --d:release --x:on --opt:size --out:"../Void°Doctrine.exe" main.nim"""
#exec """nim compile --d:release --x:on --opt:size --out:"../Void°Doctrine.elf" --os:linux main.nim"""
if existsFile "../test.exe": rmFile "../test.exe"