#!/usr/bin/pwsh
# Shebang to run this through powershell on linux

# Instructions:
# Put .vtf files in ./materials_inter
# Begin filename with v_ for VertexLitGeneric, will otherwise be LightmappedGeneric
# Append filename with _n for a normal map (must have matching albedo)
# Append filename with _t for translucent texture (will apply vertexalpha if vertexlit)
# End filename with -x- where x is a reflectivity representing 0.x
# The program will guess the material type (see below for guess criteria)

# Clear out all files in the materials_conv/q_custom/ directory for a clean start
Remove-Item "./materials_conv/q_custom/*.vmt"
Remove-Item "./materials_conv/q_custom/*.vtf"

# Loop over all vtf files in the materials_inter/ directory
$filenames = Get-ChildItem "./materials_inter/" -Filter *.vtf
foreach ($file in $filenames) {

    # Get the filename without the extension
    $file = [System.Io.Path]::GetFileNameWithoutExtension($file)

    # Determine the correct material
    $material = "concrete"
    if($file.Contains("brick")) {
        $material = "brick"
    } elseif (($file.Contains("tile")) -or ($file.Contains("sink"))) {
        $material = "tile"
    } elseif (($file.Contains("wood")) -or ($file.Contains("plank"))) {
        $material = "wood"
    } elseif ($file.Contains("sign")) {
        $material = "metalpanel"
    } elseif ($file.Contains("cork")) {
        $material = "rubber"
    } elseif ($file.Contains("plastic")) {
        $material = "plastic"
    } elseif ($file.Contains("poster")) {
        $material = "paper"
    } elseif (($file.Contains("railing")) -or ($file.Contains("metal"))) {
        $material = "metal"
    }

    # Set up the output variables
    $output = ""
    $reflectivity = 0
    $albedo = $file
    $translucent = 0

    # Determine if this is a lightmapped generic or a vertex lit generic
    if($albedo.StartsWith("v_")) {
        $output = "`"VertexLitGeneric`""

        $albedo = $albedo.Substring(2)
    } else {
        $output = "`"LightmappedGeneric`""
    }

    # Determine if the file needs to be reflective. If so, set reflectivity
    if($albedo.EndsWith("-")) {
        $reflectivity = $albedo.Substring($albedo.Length-2, 1)
        $albedo = $albedo.Substring(0, $albedo.Length - 3)
    }

    # Determine if the file is translucent. If so, set translucent value to 1
    if($albedo.EndsWith("_t")) {
        $translucent = 1
        $albedo = $albedo.Substring(0, $albedo.Length - 2)
    }
    
    # Determine if this file is a normal map. If so, set correctly in output
    if($albedo.EndsWith("_n")) {
        # Trim the filename to get the path without the _n
        $normal = $albedo
        $albedo = $albedo.Substring(0, $albedo.Length - 2)

        $output += "`n{`n    `"`$basetexture`" `"q_custom/$albedo`"`n"
        $output += "    `"`$bumpmap`" `"q_custom/$normal`"`n"

        # Copy the normal to the correct location
        Copy-Item "./materials_inter/$file.vtf" "./materials_conv/q_custom/$normal.vtf"

    } else {
        $output += "`n{`n    `"`$basetexture`" `"q_custom/$albedo`"`n"

        # Copy the albedo to the correct location
        Copy-Item "./materials_inter/$file.vtf" "./materials_conv/q_custom/$albedo.vtf"
    }

    # Add the surface sound / property
    $output += "    `"`$surfaceprop`" `"$material`"`n"

    # Add the reflectivity
    if($reflectivity -ne 0) {
        $output += "    `"`$envmap`" `"env_cubemap`"`n"
        $output += "    `"`$envmaptint`" `"[0.$reflectivity 0.$reflectivity 0.$reflectivity]`"`n"
    }

    # Add translucent
    if($translucent -eq 1) {
        $output += "    `"`$translucent`" 1`n"
        if($file.StartsWith("v_")) {
            $output += "    `"`$vertexalpha`" 1`n"
        }
    }

    # Close open brace in output
    $output += "}"

    "$output" | Set-Content -Path "./materials_conv/q_custom/$albedo.vmt"
}
