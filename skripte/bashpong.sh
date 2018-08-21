#!/bin/bash
#
# Autor: vigidr
#
# Das Spiel Pong, spielbar im Bash-Terminal
#

c='='
play=true
pause=1
pc1=33
pc2=32

init()
{
	clear
	pp1=0
	pp2=0
	p=''
	w=$(tput cols)
	((pl=$w/4))
	for i in $(seq 1 $pl)
	do
		p=$p$c
	done
	h=$(tput lines)
	((s=$w/8))
}

draw_ball()
{
	echo -en '\e['$bpy';'$bpx'H\e[31;1m0\e[0m'
}

undraw_ball()
{
	echo -en '\e['$bpy';'$bpx'H '
}

draw_player()
{
	echo -en '\e['$1';'$2'H\e['$3';1m'$p'\e[0m'
}

draw_points()
{
	echo -en '\e[1;1H\e['$pc1';1mPlayer 1:\e[0m '$pp1'\e[1;17H\e['$pc2';1mPlayer 2:\e[0m '$pp2
	if [ $pause -eq 1 ]; then
		echo -en '\e[1;'$(($w-8))'H\e[1mPAUSED'
	fi
}

move_ball()
{
	if [ $pause -eq 0 ]; then
		undraw_ball
		if [ $bpy -ge $(($h-1)) ] && [ $bdy -gt 0 ]; then
			if [ $bpx -ge $p2x ] && [ $bpx -le $(($p2x+$pl)) ]; then
				((bdy=$bdy*-1))
			else
				((pp1=$pp1+1))
				newround
			fi
		elif [ $bpy -le 3 ] && [ $bdy -le 0 ]; then
			if [ $bpx -ge $p1x ] && [ $bpx -le $(($p1x+$pl)) ]; then
				((bdy=$bdy*-1))
			else
				((pp2=$pp2+1))
				newround
			fi
		fi
		if [ $bpx -ge $w ] || [ $bpx -le 1 ]; then
			((bdx=$bdx*-1))
		fi
		((bpx=$bpx+$bdx))
		((bpy=$bpy+$bdy))
	fi
	draw_ball
}

move_p1()
{
	((p1x=$p1x+$1))
	if [ $p1x -lt 1 ]
	then
		p1x=1
	elif [ $p1x -gt $(($w+1-$pl)) ]
	then
		((p1x=$w+1-$pl))
	fi
}

move_p2()
{
	((p2x=$p2x+$1))
	if [ $p2x -lt 0 ]
	then
		p2x=0
	elif [ $p2x -gt $(($w+1-$pl)) ]
	then
		((p2x=$w+1-$pl))
	fi
}

controls()
{
	read -s -t 0.05 -n 1 in
	if [ "$in" = "q" ]; then
		echo -e '\e['$h';'$w'H\n\nQuit.\n'
		play=false;
	elif [ "$in" = "p" ]; then
		if [ $pause -eq 1 ]; then
			pause=0
		else
			pause=1
		fi
	fi
	if [ $pause -eq 0 ]; then
		if [ "$in" = "a" ]; then
			move_p2 -$s
		elif [ "$in" = "s" ]; then
			move_p2 $s
		elif [ "$in" = "k" ]; then
			move_p1 -$s
		elif [ "$in" = "l" ]; then
			move_p1 $s
		fi
	fi
}

newround()
{
	undraw_ball
	((bpx=$w/2))
	((bpy=$h/2))
	((p1x=$bpx-$pl/2))
	((p2x=$bpx-$pl/2))
	draw_ball
	draw_player 2 $p1x $pc1
	draw_player $h $p2x $pc2
	draw_points
}

init
((bdx=$w/20))
((bdy=$h/16))
newround

while $play
do
	if [ $w -ne $(tput cols) ]
	then
		init
	elif [ $h -ne $(tput lines) ]
	then
		init
	fi
	clear
	move_ball
	draw_player 2 $p1x $pc1
	draw_player $h $p2x $pc2
	draw_points
	controls
done
