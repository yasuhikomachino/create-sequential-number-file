#!/bin/sh

#
# Create a sequential number file.
#
# Example:
#   $ ./src/create.sh
#   [SUCCESS] Create dist/2020-10-10-001.md
#

set -e

readonly PREFIX=$(date "+%Y-%m-%d")
readonly DESTINATION='dist/'
readonly EXTENSION='.md'
readonly SEPARATOR='-'
readonly NUMBER_FORMAT='%03d'

message() {
  local color_name color
  readonly color_name="$1"
  shift
  case $color_name in
  red)
    color=31
    ;;
  green)
    color=32
    ;;
  yellow)
    color=33
    ;;
  blue)
    color=34
    ;;
  cyan)
    color=36
    ;;
  *)
    error_exit "An undefined color was specified."
    ;;
  esac
  printf "\033[${color}m%b\033[m\n" "$*"
}

error_exit() {
  {
    message red "[ERROR] $*"
  } 1>&2
  exit 1
}

get_targets() {
  set +e
  local files=$(find $DESTINATION*$EXTENSION -type f -maxdepth 0 -name $PREFIX$SEPARATOR* 2>/dev/null)
  set -e

  echo "$files"
}

get_new_number() {
  local prefix_len=$((${#PREFIX} + ${#SEPARATOR}))
  local max=0

  if [ "$1" != "" ]; then
    for filepath in $1; do
      filename=$(basename $filepath $EXTENSION)
      num_str=${filename:$prefix_len}
      num=$(expr $num_str)

      if [ $max -lt $num ]; then
        max=$num
      fi
    done
  fi

  new_id=$(($max + 1))
  new_num=$(printf $NUMBER_FORMAT $new_id)

  echo $new_num
}

build_filepath() {
  echo $DESTINATION$PREFIX$SEPARATOR$1$EXTENSION
}

main() {
  local targets=$(get_targets)
  local num=$(get_new_number "$targets")
  local filepath=$(build_filepath $num)

  mkdir -p $(dirname $filepath)
  touch $filepath
  message green "[SUCCESS] Create $filepath"

  exit 0
}

main
