#!/bin/bash
# Zip bulk files to individual archives
# author: Raymond Colebaugh

directory="$1"
cd $directory
function strip_ext() {
	echo $* | sed 's/^\(.*\)\..*$/\1/g'
	}
count=$(ls | wc -l)

echo "[*] Starting batch zip with $count files..."
for file in ./*
do
	base=$(strip_ext $file)
	zip "$base" "$file"
done
echo "[*] Finished zipping $count files."
