#!/usr/bin/env zsh
# ----
# For basic csv file implementation
#
# data.zsh file_name frame [--max a<,b,c>] [--min a<,b,c>] [--skip|-s number]
#   frame : 1,3,4,5;3:5  means : row 1,row 3,row 4,row 5, col 3~5
#     notice row 1 is second line which skip the header
#   a: col a; b: bth max/min, default 1; c: around c lines, default 5
#   note: row/col 1  is first line/col
#
# Exit:
#   0 successful
#   1 argument key errors
#   2 argument value errors
# ----
emulate -L zsh
zmodload zsh/mathfunc
setopt errexit pipefail nounset extended_glob NULL_GLOB

typeset -g SCRIPT_PATH=${0:A}
typeset -g START_LINE
# (1 0 3) means 1:3; (1 3 0) means 1,3
typeset -ga FRAME_ROW
typeset -ga FRAME_COL
typeset -ga MAX
typeset -ga MIN

# local functions
usage() {
	# delete first two characters
	sed -n "3,14{s/^.//;s/^.//;p;}" "$SCRIPT_PATH"
	exit 0
}

csv_shape() {
	print -P -- "%F{cyan}Content%f"
	tail -n +${START_LINE:-1} $1 |
		awk 'BEGIN{FS=OFS=","}
       NR==1{split($0,header,",")}
       NR==2{split($0,firstLine,",")}
       {last=$0}
       END{
       split(last,lastLine,",")
       printf "\033[33m  Header\033[0m"
       for(i=1;i<=length(header);i++)printf " %s: %s;",i,header[i]
       print ""
       printf "\033[33m  FitrstLine\033[0m"
       for(i=1;i<=length(firstLine);i++)printf " %s: %s;",header[i],firstLine[i]
       print ""
       printf "\033[33m  LastLine\033[0m"
       for(i=1;i<=length(lastLine);i++)printf " %s: %s;",header[i],lastLine[i]
       print ""
       printf "\033[36mShape\033[0m\n  %sx%s\n",NR,NF
     } '
	print -P -- "%F{cyan}Encoding%f"
	print -- "  $(nkf --guess $1)"
}

# eg 10,13;1:5 => row: (10 13 0) col: (1 0 5)
# eg 10,12,14,15
regex_frame() {
	# if [[ $1 =~ '(^[0-9]+)((,([0-9]+))|(:([0-9]*)))?(;([0-9]*)((,([0-9]+))|(:([0-9]*)))?)?$' ]]; then
	if [[ $1 =~ '(^-?[0-9]+)(((,[0-9]+)*)|(:(-?[0-9]*)))?(;(-?[0-9]*)(((,[0-9]+)*)|(:(-?[0-9]*)))?)?$' ]]; then
		FRAME_ROW+=("${match[1]}${match[3]:-}" ${match[6]:-NaN})
		# FRAME_ROW+=(${match[1]} ${match[4]:-0} ${match[6]:-0})
		FRAME_COL+=(${match[8]}${match[10]:-} ${match[13]:-NaN})
		if [[ ${FRAME_ROW[2]} == "NaN" ]] && [[ ${match[5]} == ":" ]]; then
			FRAME_ROW[2]="-1"
		fi
		if [[ ${FRAME_COL[2]} == "NaN" ]] && [[ ${match[12]} == ":" ]]; then
			FRAME_COL[2]="-1"
		fi
		# if ((${FRAME_ROW[1]}>=${FRAME_ROW[2]} || ${F}))
	else
		print -u2 "Error: Invalid Frame"
		exit 2
	fi
}

regex_maxmin() {
	if [[ $1 =~ '(^[0-9]+)(,([0-9]+))?(,([0-9]*))?$' ]]; then
		[[ $2 == 'max' ]] && MAX+=(${match[1]} ${match[3]:-1} ${match[5]:-5})
		[[ $2 == 'min' ]] && MIN+=(${match[1]} ${match[3]:-1} ${match[5]:-5})
	else
		print -u2 "Error: Invalid max/min value"
		exit 2
	fi
}

[[ $# -eq 0 || ${1:l} == -h || ${1:l} == --help ]] && usage

# argv[2]=abcd
# argv[3]=def
# print -l $@
# print -l $#
#
# print -l -- "argv: $@" "argc: $#"
for ((count = 1; count <= $#; count++)); do
	if [[ ${argv[count]} == "--skip" || ${argv[count]} == "-s" ]]; then
		# input_data=$(tail -n "+${argv[count+1]}" -- $1)
		# START_LINE=$((${argv[count+1]}))
		START_LINE=$((++argv[count+1]))
		argv[count,count+1]=()
		break
	fi
done

# get the basic shape for file
if [[ $# -eq 1 ]]; then
	if [[ ! -f $1 ]]; then
		print -u2 "Error: the csv file doesn't exist"
		exit 2
	fi
	csv_shape $1
	exit 0
fi

while (($# > 1)); do
	case $2 in
	*\;* | <->)
		regex_frame $2
		argv[2]=()
		;;
	"--max")
		if ((${#MIN} != 0)); then
			print -u2 -- "Error: Already using min"
			exit 1
		fi
		regex_maxmin ${3:-"non"} "max"
		argv[2,3]=()
		;;
	"--min")
		if ((${#MAX} != 0)); then
			print -u2 -- "Error: Already using max"
			exit 1
		fi
		regex_maxmin ${3:-"non"} "min"
		argv[2,3]=()
		;;
	*)
		print -u2 "Error: unknown argument/key"
		exit 1
		;;
	esac
done

# main output
row_lines=$(wc -l <$1 | tr -d '\t ')
if [[ ${FRAME_ROW[2]} == "NaN" ]]; then
	if [[ ${FRAME_COL[2]} == "NaN" ]]; then
		FRAME_ROW[2]=()
		FRAME_COL[2]=()
		# row (,) col (,)
		dir="r1c1"
	else
		# row (,) col (:)
		dir="r1c2"
	fi
else
	if [[ ${FRAME_COL[2]} == "NaN" ]]; then
		FRAME_COL[2]=()
		# row (:) col (,)
		dir="r2c1"
	else
		# row (:) col (:)
		dir="r2c2"
	fi
fi
#
# --- test
# print -- "FRAME_ROW: ${FRAME_ROW[@]}"
# print -- "FRAME_COL: ${FRAME_COL[@]}"
# print -- "max: ${MAX[@]}, counts: ${#MAX}"
# print -- "min: ${MIN[@]}, counts: ${#MIN}"
# print -- "lines: $row_lines"
# print -- "file: $1"
# print -- "dir: $dir"
# --- test

tail -n +${START_LINE:-1} $1 |
	awk -v frame_rows=${(j:,:)FRAME_ROW[@]} \
		-v frame_cols=${(j:,:)FRAME_COL[@]} \
		-v max=${(j:,:)MAX[@]} \
		-v min=${(j:,:)MIN[@]} \
		-v row_lines=${row_lines} \
		-v dir=$dir \
		-f ${ZDOTDIR}/hkscripts/csv_data/rncn.awk

# awk -v rows=${(j:|:)FRAME_ROW[@]} \
# 	-v cols=${(j:|:)FRAME_COL[@]} 'BEGIN{FS=OFS=",";split()}NR==1{print rows; print cols}' $1
# awk -v rows="${(j:,:)FRAME_ROW[@]}" 'BEGIN{FS=OFS=","}NR==1{print rows}' $1
