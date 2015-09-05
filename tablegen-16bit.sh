#!/bin/bash

a=1.059463094359

echo "Note Table Generator"
echo -n "Input base value: "
read bv

if [ $bv -ne 0 -o $bv -eq 0 2>/dev/null ]
then
j=1
for i in {0..59}
do
	((j--))
	if [ $j -eq 0 ]
	then
		j=12
		printf "\n\t.dw "
	else
		printf ","
	fi

	hexv="$(awk "BEGIN{printf ($bv * $a ** $i)+0.5}")"
	hexval=${hexv/.*}
	printf "$"
	printf "%X" $hexval
	
done > notetab.inc

else

    echo "Supply an integer, please."
fi
