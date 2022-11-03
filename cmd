#!/usr/bin/bash
# ---------- Command Parse Module --------

source $VanRoot/utils

#mkdir
mkdir_parse(){
	shift

	until [ $# -eq 0 ]
	do
		if [[ ! "$1" =~ -.* ]];then
		  MkdirDir=`realpath $1`
		  vandir=`get_VanDir $MkdirDir`
		  if [ "$VanDir" == "$vandir" ];then
		    echo "Hello mkdir"
		  fi
		fi
		shift
	done
}

#cp
#cp_parse(){
#}

#mv
#mv_parse(){
#}

#rm
#rm_parse(){
#}
