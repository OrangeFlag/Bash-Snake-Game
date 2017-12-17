#!/bin/bash

#TODO make debug, new game, highscore table, line parameters

#– | \ / 

PushCommandLineParameters()
{
	sleep 1
}


lastDirection=">"
direction=">"
turn="–"
score=0
countFood=0
nextStep=0

#customizable
maxCountFood=3
n=8
pause=0.4

PushCommandLineParameters

count=$(($n*$n))

zmei=( $( [ $(($count/2)) -gt 0 ] && echo $(($count/2)) ) $( [ $(($count/2-1)) -gt 0 ] && echo $(($count/2-1)) ) $( [ $(($count/2-2)) -gt 0 ] && echo $(($count/2-2)) ) $( [ $(($count/2-3)) -gt 0 ] && echo $(($count/2-3)) ) $( [ $(($count/2-4)) -gt 0 ] && echo $(($count/2-4)) ) )



ClearTable()
{
	for (( i=0;i<$count;i++ ))
        do
        pole[i]="*"
        done
}


ApplyZmei()
{

	for i in "${zmei[@]}"
	do
		pole[i]="–"
	done
	pole[${zmei[0]}]=$direction
}


ReadKeyboard()
{
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

NewFood()
{
	let countFood=$countFood+1
	i=$((RANDOM % $count))
	while [ "${pole[$i]}" != "*" ]
	do
		i=$((RANDOM % $count))
	done
	pole[$i]="0"

}



ClearTable
ApplyZmei



GameOver()
{

echo """   ____                       ___                 
  / ___| __ _ _ __ ___   ___ / _ \\__   _____ _ __ 
 | |  _ / _\` | '_ \` _ \\ / _ | | | \\ \\ / / _ | '__|
 | |_| | (_| | | | | | |  __| |_| |\\ V |  __| |   
  \\____|\\__,_|_| |_| |_|\\___|\\___/  \\_/ \\___|_|"""
exit
}
Victory()
{
clear
echo """__     ___      _                   
\ \\   / (_) ___| |_ ___  _ __ _   _ 
 \\ \\ / /| |/ __| __/ _ \\| '__| | | |
  \\ V / | | (__| || (_) | |  | |_| |
   \\_/  |_|\\___|\\__\\___/|_|   \\__, |
                              |___/ 
				    """
exit
}

TestStep()
{
	if [ "${pole[$nextStep]}" = "0" ]
	then
		#find food
		if [ ${#zmei[@]} -eq $count ]
		then
			Victory
		fi

		let score=$score+10
		let countFood=$countFood-1
	
		zmei=( "${zmei[@]}" "forDelete" )
	fi
}

TestGameOver()
{
	if [[ "${pole[$nextStep]}" = '|' || "${pole[$nextStep]}" = '/' || "${pole[$nextStep]}" = "\\" || "${pole[$nextStep]}" = "–" ]]
	then
		GameOver
	fi
}


SnakeTurn()
{
	if [[ $direction = '>' && $lastDirection = '⌄' ||  $direction = '⌄' && $lastDirection = '>' ||  $direction = '<' && $lastDirection = '^' ||  $direction = '^' && $lastDirection = '<' ]]
	then
		turn="\\"
	fi
	
	if [[ $direction = '>' && $lastDirection = '^' ||  $direction = '^' && $lastDirection = '>' ||  $direction = '<' && $lastDirection = '⌄' ||  $direction = '⌄' && $lastDirection = '<' ]]
	then
		turn="/"
	fi

	if [[ $direction = '^' && $lastDirection = '^' ||  $direction = '⌄' && $lastDirection = '⌄' ]]
	then
		turn="|"
	fi

	if [[ $direction = '>' && $lastDirection = '>' ||  $direction = '<' && $lastDirection = '<' ]]
	then
		turn="–"
	fi
}


while [ true ]
do
clear

if [ $countFood -lt $maxCountFood ]
then
	NewFood
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
#--------------------------------------------------print table and score ~


lastDirection=$direction
ReadKeyboard

#--------------------------------------------------calculate zmeika
if [[ $direction = '>' && $lastDirection = '<' || $direction = '<' && $lastDirection = '>' || $direction = '^' && $lastDirection = '⌄' || $direction = '⌄' && $lastDirection = '^' ]]
then
	direction=$lastDirection
fi


case $direction in 
	">")
		nextStep=$(( (count + zmei[0] + 1 - ( (zmei[0]+1)/$n - zmei[0]/$n)*$n ) %count ))
	;;
	"<")
		nextStep=$(( (count + zmei[0] - 1 + (zmei[0]/$n - (zmei[0]-1)/$n)*$n) % count ))
	;;
	"^")
		nextStep=$(( (count + zmei[0] - $n) % count))
	;;
	"⌄")
		nextStep=$(( (zmei[0] + $n) % count))
	;;
esac

if [ $nextStep -lt 0 ] || [ $nextStep -gt $count ]
then
echo AAAA
return
fi


TestStep
SnakeTurn

pole[${zmei[0]}]=$turn #change old head

if [[ "${zmei[$((${#zmei[@]}-1))]}" != 'forDelete' ]]
then
	pole[${zmei[$((${#zmei[@]}-1))]}]="*" #delete old tail
fi

TestGameOver
zmei[$((${#zmei[@]}-1))]="" #delete old tail

zmei=( "$nextStep"  ${zmei[@]} )
pole[${zmei[0]}]=$direction #new head
#--------------------------------------------------calculate zmeika ~

done
