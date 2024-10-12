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

declare -a MATCH_IOMMU_GROUP_ID_LIST=()

for iommu_group_id in ${IOMMU_GROUP_ID_LIST[@]}; do
  MATCH_IOMMU_GROUP_ID_LIST["${iommu_group_id}"]=false
done

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

# set the key input_delim pairs
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
  input_delim=${INPUT_DICT["${key}"]}
  echo $key
  # echo $input_delim

  has_match=false
  match_iommu_group=false
  match_name=false
  match_type=false
  match_vendor=false
  previous_parse_has_match=false

  case "${key}" in
    *"GROUP"* )
      match_iommu_group=true
      ;;

    *"NAME"* )
      match_name=true
      ;;

    *"TYPE"* )
      match_type=true
      ;;

    *"VENDOR"* )
      match_vendor=true
      ;;
  esac

  for iommu_group_id in ${IOMMU_GROUP_ID_LIST[@]}; do
    echo $iommu_group_id

    this_bus_id_list="$( \
      ls \
        "/sys/kernel/iommu_groups/${iommu_group_id}/devices/" \
      | sort \
        --version-sort
    )"

    this_bus_id_delim=""

    for bus_id in ${this_bus_id_list[@]}; do
      bus_id="${bus_id:5}"
      # echo $bus_id

      if "${match_iommu_group}" \
        && [[ ",${input_delim}," =~ ",${iommu_group_id}," ]]; then
        has_match=true
      fi

      name="$( \
        lspci \
          -m \
          -s \
            "${bus_id}" \
        | cut \
          --delimiter \
            '"' \
          --fields \
            6 \
      )"

      type="$( \
        lspci \
          -m \
          -s \
            "${bus_id}" \
        | cut \
          --delimiter \
            '"' \
          --fields \
            2 \
      )"

      vendor="$( \
        lspci \
          -m \
          -s \
            "${bus_id}" \
        | cut \
          --delimiter \
            '"' \
          --fields \
            4 \
      )"

      if "${match_name}" \
        && [[ ",${input_delim}," =~ ",${name}," ]]; then
        has_match=true
      fi

      if "${match_type}" \
        && [[ ",${input_delim}," =~ ",${type}," ]]; then
        has_match=true
      fi

      if "${match_vendor}" \
        && [[ ",${input_delim}," =~ ",${vendor}," ]]; then
        has_match=true
      fi

    # driver="$( \
    #   lspci \
    #     -k \
    #     -n \
    #     -s \
    #       "${bus_id}" \
    #   | grep \
    #     driver \
    #   | awk \
    #     'END {print $5}'
    # )"

    # hardware_id="$( \
    #   lspci \
    #     -n \
    #     -s \
    #       "${bus_id}" \
    #   | awk \
    #     'END {print $3}' \
    # )"

      if [[ "${key}" =~ "UNMATCH" ]]; then
        if "${has_match}"; then
          has_match=false
        else
          has_match=true
        fi
      fi

      (( key-- ))
      previous_parse_has_match=${INPUT_LIST["$key"]}

      if ! "${has_match}"; then
        INPUT_LIST["${key}"]="${has_match}"
      fi

      if ! "${previous_parse_has_match}"; then
        has_match=false
      fi
  done
    done

    echo $has_match
    echo



  echo
done

for key in "${!MATCH_IOMMU_GROUP_ID_LIST[@]}"; do
  value=${MATCH_IOMMU_GROUP_ID_LIST["${key}"]}

  echo $key $value
done