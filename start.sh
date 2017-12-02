#!/bin/bash

#TODO gameover

direction=">"
score=0
maxCountFood=3
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


newFood()
{
	i=$((RANDOM % $count))
	while [ "${pole[$i]}" != "*" ]
	do
		i=$((RANDOM % $count))
	done
	pole[$i]="0"

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
countFood=0



while [ true ]
do
clear

if [ $countFood -lt $maxCountFood ]
then
	let countFood=$countFood+1
	newFood
fi


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



read_keyboard

isFood="false"

#--------------------------------------------------calculate zmeika
case $direction in 
	">")
		pole[${zmei[0]}]="#"
		next_step=$(((zmei[0] + 1 - ((zmei[0]+1)/$m - zmei[0]/$m)*$m)%count ))
		if [ "${pole[$next_step]}" = "0" ]
		then
			isFood="true"
		fi
		declare -a zmei=( "$next_step " ${zmei[@]} $( [ $isFood == "true" ] && echo "delete" || echo ""))
		pole[${zmei[$((${#zmei[*]}-1))]}]="*"
		zmei[$((${#zmei[*]}-1))]=""
	;;
	"<")
		pole[${zmei[0]}]="#"
		next_step=$(( (zmei[0] - 1 + (zmei[0]/$m - (zmei[0]-1)/$m)*$m ) % count))
		if [ "${pole[$next_step]}" = "0" ]
		then
			isFood="true"
		fi
		declare -a zmei=( "$next_step " ${zmei[@]} $( [ $isFood == "true" ] && echo "delete" || echo ""))
		pole[${zmei[$((${#zmei[*]}-1))]}]="*"
		zmei[$((${#zmei[*]}-1))]=""
	;;
	"^")
		pole[${zmei[0]}]="#"
		next_step=$(( (zmei[0] - $m) % count))
		if [ "${pole[$next_step]}" = "0" ]
		then
			isFood="true"
		fi

		declare -a zmei=( "$next_step " ${zmei[@]} $( [ $isFood == "true" ] && echo "delete" || echo ""))
		pole[${zmei[$((${#zmei[*]}-1))]}]="*"
		zmei[$((${#zmei[*]}-1))]=""
	;;
	"⌄")
		pole[${zmei[0]}]="#"
		next_step=$(( (zmei[0] + $m) % count))
		if [ "${pole[$next_step]}" = "0" ]
		then
			isFood="true"
		fi

		declare -a zmei=( "$next_step " ${zmei[@]}  $( [ $isFood == "true" ] && echo "delete" || echo "") )
		pole[${zmei[$((${#zmei[*]}-1))]}]="*"
		zmei[$((${#zmei[*]}-1))]=""
	;;
esac

if [ $isFood = "true" ]
then
	let score=$score+10
	let countFood=$countFood-1
fi 
pole[${zmei[0]}]=$direction
#--------------------------------------------------calculate zmeika~

done
