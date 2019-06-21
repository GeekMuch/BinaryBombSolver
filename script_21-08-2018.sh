#!/bin/bash

findprompt='"info functions prompt"'
echo "[+] Running"
echo

OUTPUT=$( gdb binarybomb \
	-ex "set confirm off" \
	-ex "info functions prompt " \
	-ex q )

 	# printf "$OUTPUT"
letterInput="e"
echo $letterInput >  txt.txt

splitIntoStrings(){
	addrList=();
	promptNames=();

	txtRaw=$1

	checkFor="0x"
	cPrompt="prompt"

	# Going through gdb output and find prompt names and addr
	for i in $txtRaw; do

	    if [[ "$i" =~ $checkFor ]]; then
			# printf "$i\n\n"
		addrList+=($i)

		elif [[ "$i" =~ $cPrompt ]]; then
			# printf "$i\n\n"
			promptNames+=($i)

		fi

	done
	promptNames=("${promptNames[@]:1}")

	echo "[+] Defusing Bomb.."
	echo
}

disassemblePromts(){

	disPromptsData=();

	for i in "${promptNames[@]}"; do

		tmpData=$(echo "$(gdb  binarybomb  -batch  \
		-ex "start" \
		-ex "disassemble "$i" ")")
		disPromptsData=("${disPromptsData[@]}" $tmpData)

	done
}

getAnsrAddr(){

    listOfBreakpoints=();

		for((i=0;i<${#disPromptsData[@]};++i)); do

		    if [[ "${disPromptsData[$i]}" =~ "<answer" ]]; then

			addrIndexAnswer=$(( $i + 1))
			addrTobreak="${disPromptsData[addrIndexAnswer]}"
			listOfBreakpoints=("${listOfBreakpoints[@]}" $addrTobreak)
		    fi
		done
}

runBreakpointsGDB(){

	numOfBreakP=$( echo "${#listOfBreakpoints[@]}")
	# echo $numOfBreakP

	changeInput=09807
	count=1

	declare -p listOfBreakpoints

	firstInput=$letterInput

	echo "$firstInput"$'\n'"$changeInput" > txt.txt


	for breakAddr in "${listOfBreakpoints[@]}"; do



		# echo $firstInput
		# echo "$( cat txt.txt)"
		if [ "$count" == 1 ]; then
			getAnswer "${breakAddr}"
			# echo $hodl
			resList="$firstInput"$'\n'"${hodl}"
			echo "$resList" > txt.txt

		elif [[ "$count" == 2 ]]; then
			r42="${resList}"$'\n'"${hodl}"
			echo "$r42" > txt.txt
			getAnswer "${breakAddr}"
			# echo $hodl
			r2="${resList}"$'\n'"${hodl}"
			echo "$r2" > txt.txt


			DefuseBomb

		elif [[ "$count" == 3 ]]; then
			# echo $hodl
			r3="${r2}"$'\n'"${hodl}"
			echo "$r3" > txt.txt

			DefuseBomb
		fi


		((count++))

	done;

}

getAnswer(){

    finalAnswer=();
	gdbOut=$( echo "$( gdb -batch -ex "file binarybomb"\
			-ex "break*"$1""\
			-ex " run <txt.txt" -ex " p/d \$rax"\ )" )

	# gdbOut= gdb -batch -ex "file binarybomb"\
	# 						-ex "break*"$1""\
	# 						-ex " run <txt.txt" -ex " p/d \$rax"


	for i in $gdbOut; do
		finalAnswer+=($i)
		tmptest=$finalAnswer

	done;


	# declare -p finalAnswer
	# echo
	hodl=${finalAnswer[-1]}
	echo "Code: "$hodl
	# printf "${finalAnswer[-1]}"

	echo "$hodl" > txt.txt


	# echo $hodl
}
DefuseBomb(){
echo
endMePlz= gdb -batch -ex "file binarybomb"\
						-ex " run <txt.txt"
echo
echo "[+] Bomb Defused.."
}

# List of functions in order
splitIntoStrings "$OUTPUT"
disassemblePromts
getAnsrAddr
runBreakpointsGDB
