#!/bin/bash
# update translation files
# Usage: langtool.sh <diff|replace> [<language>]

if [ "$2" ]
then
	files="translations.$2.lua"
else
	files=$( ls translations.*.lua )
fi

for f in $files
do
	case "$1" in
	diff)
		cp $f $f.generated.lua
		LUA_CPATH="../../webmcp/lib/?.so;;" ../../webmcp/bin/langtool.lua ../ $f.generated.lua
		diff -u $f $f.generated.lua | vim - -R
    rm $f.generated.lua
		;;
	replace)
		cp $f $f.backup
		LUA_CPATH="../../webmcp/lib/?.so;;" ../../webmcp/bin/langtool.lua ../ $f
		;;
	esac
done

