#!/usr/bin/pwsh
# Shebang to run this through powershell on linux

# Copies all files in materials_conv/q_custom and models_conv/q_custom to CSGO
$csgo = "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\csgo"
Copy-Item -Path "./materials_conv/q_custom" -Destination "$csgo/materials/q_custom" -Recurse
Copy-Item -Path "./models_conv/q_custom" -Destination "$csgo/models/q_custom" -Recurse