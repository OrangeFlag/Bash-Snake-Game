#!/bin/bash

#TODO make debug, new game, highscore table, line parameters

#– | \ / 

PushCommandLineParameters()
{
	for ((i=0; i < 5; i++))
	do
		if [ -z $1 ]
		then
			break
		fi
		
		case "$1" in
		"-l") #level
			SetLevel $2
		;;
		"-c") #countFood
			maxCountFood=$2
		;;
		"-p") #pause
			pause=$2
		;;
		"-n") #N
			n=$2
		;;
		"-h")
			Help
		;;
		*)
			echo "Undefined parameter" $1
			exit
		;;

		esac
		shift 2
	done
}

Help()
{
	#echo help
	exit
}
SetLevel()
{
	#change settings
	sleep 0
}

Init()
{
newGame="false"
lastDirection=">"
direction=">"
turn="–"
score=0
countFood=0
nextStep=0

#customizable
maxCountFood=3
n=8
pause=0.25

PushCommandLineParameters $1 $2 $3 $4 $5 $6 $7 $8 $9
count=$(($n*$n))

zmei=( $( [ $(($count/2)) -gt 0 ] && echo $(($count/2)) ) $( [ $(($count/2-1)) -gt 0 ] && echo $(($count/2-1)) ) $( [ $(($count/2-2)) -gt 0 ] && echo $(($count/2-2)) ) $( [ $(($count/2-3)) -gt 0 ] && echo $(($count/2-3)) ) $( [ $(($count/2-4)) -gt 0 ] && echo $(($count/2-4)) ) )
}

Init

ClearTable()
{
	for (( i=0;i<$count;i++ ))
        do
        	pole[i]="*"
		color[i]="\e[0m"
        done
}


ApplyZmei()
{

	for i in "${zmei[@]}"
	do
		pole[i]="–"
		color[i]="\e[1;32m"
	done
	pole[${zmei[0]}]=$direction
	color[${zmei[0]}]="\e[1;32m"
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
	color[$i]="\e[31m"

}


ClearTable
ApplyZmei

NewGame()
{
	echo "New game?(Enter)"
	read key
	if [[ "$key" = "Y" || "$key" = "y" || "$key" = "" ]]
	then
		Init
		ClearTable
		ApplyZmei
		newGame="true"
	else
		exit
	fi
}

GameOver()
{
echo -ne "\e[1;41m"
echo  """   ____                       ___                 
  / ___| __ _ _ __ ___   ___ / _ \\__   _____ _ __ 
 | |  _ / _\` | '_ \` _ \\ / _ | | | \\ \\ / / _ | '__|
 | |_| | (_| | | | | | |  __| |_| |\\ V |  __| |   
  \\____|\\__,_|_| |_| |_|\\___|\\___/  \\_/ \\___|_|   
                                                  """
echo -ne "\e[0m"
NewGame
}
Victory()
{
clear
echo -en "\e[1;42m"
echo """__     ___      _                   
\ \\   / (_) ___| |_ ___  _ __ _   _ 
 \\ \\ / /| |/ __| __/ _ \\| '__| | | |
  \\ V / | | (__| || (_) | |  | |_| |
   \\_/  |_|\\___|\\__\\___/|_|   \\__, |
                              |___/ 
				    """
echo -ne "\e[0m"
NewGame
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
	echo -ne "${color[$c]}"
	echo -ne "${pole[$c]}"
	echo -ne "\e[0m"
	let "j=($c+1)/$n"
	
	if [ $last_j -ne $j ]
	then
		echo
		last_j=$j
	fi
done
echo -e "Score: \e[1m$score\e[0m"
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

TestStep
if [[ "$newGame" = "true" ]]
then
	newGame="false"
	continue
fi
SnakeTurn

pole[${zmei[0]}]="$turn" #change old head


if [[ "${zmei[$((${#zmei[@]}-1))]}" != 'forDelete' ]]
then
	pole[${zmei[$((${#zmei[@]}-1))]}]="*" #delete old tail
	color[${zmei[$((${#zmei[@]}-1))]}]="\e[0m"
	
fi

TestGameOver

if [[ "$newGame" = "true" ]]
then
	newGame="false"
	continue
fi

zmei[$((${#zmei[@]}-1))]="" #delete old tail

zmei=( "$nextStep"  ${zmei[@]} )
pole[${zmei[0]}]="$direction" #new head
color[${zmei[0]}]="\e[1;32m"
#--------------------------------------------------calculate zmeika ~

done
