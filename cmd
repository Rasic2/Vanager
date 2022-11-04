#!/usr/bin/bash
# ---------- Command Parse Module --------

source $VanRoot/utils

#mkdir
mkdir_parse() {
	ProDir=$(dirname $VanDir)

	shift

	until [ $# -eq 0 ]; do
		if [[ ! "$1" =~ -.* ]]; then
			MkdirDir=$(realpath "$1")
			vandir=$(get_VanDir "$MkdirDir")
			if [ "$VanDir" == "$vandir" -a $VERROR -eq 0 ]; then
				md5=$(echo "$MkdirDir" | md5sum | awk '{print $1}')
				# echo -e "$md5 \t $MkdirDir" >>$VanDir/INDEX
				tag_dir=$MkdirDir
				while [ $tag_dir != $ProDir ]; do
					old_tags=($(cat $VanDir/TAGS | xargs -n 1))
					poss_tag=$(basename $tag_dir)
					repeat=0
					for t in ${old_tags[*]}; do
						if [ $poss_tag == $t ]; then
							repeat=1
							break
						fi
					done

					if [ $repeat -eq 0 ]; then
						# echo $poss_tag >>$VanDir/TAGS
						:
					fi
					tag_dir=${tag_dir%/*}
				done
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
