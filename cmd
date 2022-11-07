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
				md5_short=$(echo ${md5:0:6})
				DATE=$(date "+%Y-%m-%d %H:%M:%S")
				echo -e "$md5 \t $MkdirDir" >>$VanDir/INDEX
				echo "[$DATE] add $md5_short in INDEX" >>$VanDir/CMDLOG
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
						echo $poss_tag >>$VanDir/TAGS
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
mv_parse() {
	if [ $VERROR -ne 0 ]; then
		return 1
	fi

	shift
	if [ $# -eq 2 ]; then
		path1=$(realpath "$1")
		path2=$(realpath "$2")
		vandir1=$(get_VanDir "$path1")
		vandir2=$(get_VanDir "$path2")
		md51=$(echo "$path1" | md5sum | awk '{print $1}')
		md52=$(echo "$path2" | md5sum | awk '{print $1}')
		exist1=$(sed -n "/$md51/p" $VanDir/INDEX | wc -l)
		exist2=$(sed -n "/$md52/p" $VanDir/INDEX | wc -l)
		if [ $exist1 -eq 0 -a -f $path2 ]; then # mv file1 file2 (rename file)
			:
		elif [ $exist1 -eq 1 -a -d $path2 ]; then # mv dir1 dir2 (rename directory)
			if [ "$VanDir" == "$vandir1" ]; then
				md5_short=$(echo ${md51:0:6})
				DATE=$(date "+%Y-%m-%d %H:%M:%S")
				sed -i "/$md51/d" $VanDir/INDEX
				echo "[$DATE] rm $md5_short in INDEX" >>$VanDir/CMDLOG
			fi
			if [ "$VanDir" == "$vandir2" ]; then
				md5_short=$(echo ${md52:0:6})
				DATE=$(date "+%Y-%m-%d %H:%M:%S")
				echo -e "$md52 \t $path2" >>$VanDir/INDEX
				echo "[$DATE] add $md5_short in INDEX" >>$VanDir/CMDLOG
			fi
		fi
	fi

	regenerate_tag # regerenate tags
}

#rm
rm_parse() {

	shift

	until [ $# -eq 0 ]; do
		if [[ ! "$1" =~ -.* ]]; then
			MkdirDir=$(realpath "$1")
			vandir=$(get_VanDir "$MkdirDir")
			if [ "$VanDir" == "$vandir" -a $VERROR -eq 0 ]; then
				md5=$(echo "$MkdirDir" | md5sum | awk '{print $1}')
				md5_short=$(echo ${md5:0:6})
				DATE=$(date "+%Y-%m-%d %H:%M:%S")
				sed -i "/$md5/d" $VanDir/INDEX
				echo "[$DATE] rm $md5_short in INDEX" >>$VanDir/CMDLOG
			fi
		fi
		shift
	done

	regenerate_tag # regerenate tags

}

regenerate_tag() {
	ProDir=$(dirname $VanDir)
	{
		rm -rf $VanDir/temp_tags
		for file in $(awk '{print $2}' $VanDir/INDEX); do
			while [[ "$file" != "$ProDir" ]]; do
				tag=$(basename $file)
				echo $tag
				file=${file%/*}
			done >>$VanDir/temp_tags
		done
		sort $VanDir/temp_tags | uniq >$VanDir/TAGS
		rm -rf $VanDir/temp_tags
	} &
}
