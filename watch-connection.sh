#!/usr/bin/env bash

LOGPATH=/home/matlab/.vnc/*.log
NCONN=0
FIRST=1

killme() {
	if [[ $1 -le 0 ]]; then
		if [[ $2 -eq 1 ]]; then
			echo 0
		else
			# since vnc server is the direct descendant of init,
			# killing it will cause init to die
			pkill --parent 1 bash
		fi
	fi
}

tail -f -n +1 $LOGPATH | \
while read -r line; do
	if [[ "$line" == *"Connections: accepted"* ]]; then
		NCONN=$(expr "$NCONN" + 1)
		FIRST=$(killme $NCONN $FIRST)
	elif [[ "$line" == *"Connections: closed"* ]]; then
		NCONN=$(expr "$NCONN" - 1)
		FIRST=$(killme $NCONN $FIRST)
	fi
done
