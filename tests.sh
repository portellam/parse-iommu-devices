#!/bin/bash

# tests

# TODO: check IOMMU groups output against expected.

# parse-iommu-devices --verbose --pcie --ignore-groups 1, --ignore-groups 2
# inclusive selection: get all pcie, remove group 1 and 2
# works as intended

# parse-iommu-devices --verbose --pcie --ignore-groups 1, --ignore-groups 2 --vendors nvidia
# does not work
# should be: inclusive selection: gets all pcie, first removes group 1 and 2, and adds back group 1.

declare -gi MAX_IOMMU_GROUP_ID="$( \
  ls \
    /sys/kernel/iommu_groups/ \
  | sort \
    --reverse \
    --version-sort \
  | head \
    --lines \
      1 \
)"

declare -a IOMMU_GROUP_ID_LIST="$( \
  seq \
    0 \
    "${MAX_IOMMU_GROUP_ID}"
)"

declare -A INPUT_DICT=(
  ["MATCH_GROUPS_LIST"]=""
  ["MATCH_MAKES_LIST"]=""
  ["MATCH_NAMES_LIST"]=""
  ["MATCH_TYPES_LIST"]=""
  ["MATCH_VGA_GROUPS_LIST"]=""
  ["UNMATCH_GROUPS_LIST"]=""
  ["UNMATCH_MAKES_LIST"]=""
  ["UNMATCH_NAMES_LIST"]=""
  ["UNMATCH_TYPES_LIST"]=""
  ["UNMATCH_VGA_GROUPS_LIST"]=""
)

# an ordered list of keys for INPUT_DICT.
declare -a INPUT_LIST=(
  ""
)

# set the key value pairs
INPUT_DICT["MATCH_GROUPS_LIST"]="$( \
  echo \
    -e \
      "${IOMMU_GROUP_ID_LIST//\n/\,}" \
  | sort \
    --unique \
    --version-sort \
  | tr \
    '\n' ',' \
  | sed \
    's/,$//'
)"

INPUT_DICT["UNMATCH_GROUPS_LIST"]="0,2,3,4,5,6,7,8,9,10"

# set the ordered list
declare -a INPUT_LIST=(
  "MATCH_GROUPS_LIST"
  "UNMATCH_GROUPS_LIST"
)

for key in ${INPUT_LIST[@]}; do
  value=${INPUT_DICT["${key}"]}
  echo $key
  # echo $value

  for iommu_group_id in ${IOMMU_GROUP_ID_LIST[@]}; do
    if ! [[ ",${value}," =~ ",${iommu_group_id}," ]]; then
      echo false
    else
      echo true
    fi
  done
done

function get_iommu_groups_from_input
{
  echo
}

# for iommu_group_id in ${IOMMU_GROUP_ID_LIST[@]}; do

# done

# echo \
#   -e \
#     "${IOMMU_GROUP_ID_LIST//\n/\,}" \
#   | sort \
#     --unique \
#     --version-sort \
#   | tr \
#     '\n' ',' \
#   | sed \
#     's/,$//'

