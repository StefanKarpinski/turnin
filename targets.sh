#!/bin/bash
case $1 in
	"")
		echo "usage: $0 <target name>" 1>&2
		;;
	system)
		echo `which turnin`
		;;
	custom)
		echo `pwd`/turnin
		;;
	*)
		echo "Invalid target name: $1" && exit 1
		;;
esac
