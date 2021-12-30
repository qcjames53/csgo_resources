#!/usr/bin/pwsh
# Shebang to run this through powershell on linux

# Delete all vmt files in the materials_conv/q_custom/ directory
Get-ChildItem "./materials_conv/q_custom/" -Filter *.vmt | Remove-Item
