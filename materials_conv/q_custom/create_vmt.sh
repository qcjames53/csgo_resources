#!/bin/bash

for file in *.vtf; do
	filepath=$(echo $file | rev | cut -c5- | rev)
	material=$"concrete"
	if [[ $filepath =~ "brick" ]]; then
		material=$"brick"
	fi
	if [[ $filepath =~ "tile" ]]; then
		material=$"tile"
	fi
	if [[ $filepath =~ "wood" ]]; then
		material=$"wood"
	fi

	output=$"\"LightmappedGeneric\"\n{\n	\"\$basetexture\" \"de_patrica/"

	if [[ "$filepath" == *_n ]]; then
		filepath_albedo=$(echo $filepath | rev | cut -c3- | rev)
		output=$"${output}${filepath_albedo}\"\n	\"\$bumpmap\" \"de_patrica/${filepath}\"\n	\"\$surfaceprop\" \"${material}\"\n}"
		printf "$output" > $filepath_albedo.vmt;
	else
		output=$"${output}${filepath}\"\n	\"\$surfaceprop\" \"${material}\"\n}"
		printf "$output" > $filepath.vmt;
	fi
done;
