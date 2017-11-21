#!/bin/bash

#TODO gameover, food, score

direction=">"
score=0
n=8
m=8
let "count=n*m"
pause=$1
if [ -z $pause ]
then
pause=0.4
fi


declare -a zmei=( $(($count/2)) $(($count/2-1)) $(($count/2-2))  $(($count/2-3)) $(($count/2-4)) $(($count/2-5)) )

delta="1"

clear_table()
{
	for (( i=0;i<$count;i++ ))
        do
        pole[i]="*"
        done
}


apply_zmei()
{

	for i in "${zmei[@]}"
	do
		pole[i]="#"
	done
	pole[${zmei[0]}]=$direction
}


read_keyboard()
{
#echo !
read -s -n 3 -t $pause key
case $(echo $key | cat -v) in
        '^[[A')
                direction='^'
        ;;
        '^[[B')
                direction='⌄'
        ;;
        '^[[C')
                direction='>'
        ;;
        '^[[D')
                direction='<'
        ;;
esac

}



clear_table
apply_zmei









#********
#********
#********
#********
#>*******
#********
#********
#********

#parallel --bg --spreadstdin ::: read_keyboard

while [ true ]
do
clear

#--------------------------------------------------print table and score
last_j=0
for (( c=0;c<$count;c++ ))
do
	echo -n "${pole[$c]}"
	let "j=($c+1)/$n"
	
	if [ $last_j -ne $j ]
	then
		echo
		last_j=$j
	fi
done
echo Score: $score
#--------------------------------------------------print table~

#--------------------------------------------------read keyboard
read_keyboard
#--------------------------------------------------read keyboard~


#--------------------------------------------------calculate zmeika
case $direction in 
	">")
		pole[${zmei[0]}]="#"
		declare -a zmei=( "$(( (zmei[0] + 1 - ((zmei[0]+1)/$m - zmei[0]/$m)*$m ) % count)) " ${zmei[@]} )
		pole[${zmei[$((${#zmei[*]}-1))]}]="*"
		zmei[$((${#zmei[*]}-1))]=""
	;;
	"<")
		pole[${zmei[0]}]="#"
		declare -a zmei=( "$(( (zmei[0] - 1 + (zmei[0]/$m - (zmei[0]-1)/$m)*$m ) % count)) " ${zmei[@]} )
		pole[${zmei[$((${#zmei[*]}-1))]}]="*"
		zmei[$((${#zmei[*]}-1))]=""
	;;
	"^")
		pole[${zmei[0]}]="#"
		declare -a zmei=( "$(( (zmei[0] - $m) % count)) " ${zmei[@]} )
		pole[${zmei[$((${#zmei[*]}-1))]}]="*"
		zmei[$((${#zmei[*]}-1))]=""
	;;
	"⌄")
		pole[${zmei[0]}]="#"
		declare -a zmei=( "$(( (zmei[0] + $m) % count)) " ${zmei[@]} )
		pole[${zmei[$((${#zmei[*]}-1))]}]="*"
		zmei[$((${#zmei[*]}-1))]=""
	;;
esac
pole[${zmei[0]}]=$direction
#--------------------------------------------------calculate zmeika~
#clear_table
#apply_zmei

#sleep 1
done
