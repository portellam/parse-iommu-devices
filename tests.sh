#!/bin/bash

# tests

#
# TODO:
# - check IOMMU groups output against expected.
#
#

#
# NOTES:
#
# parse-iommu-devices --verbose --pcie --ignore-groups 1, --ignore-groups 2
# inclusive selection: get all pcie, remove group 1 and 2
# works as intended
#
# parse-iommu-devices --verbose --pcie --ignore-groups 1, --ignore-groups 2 --vendors nvidia
# does not work
# should be: inclusive selection: gets all pcie, first removes group 1 and 2, and adds back group 1.

#
# parameters
#
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

  declare -a MATCHED_IOMMU_GROUPS_LIST=()
  declare -a UNMATCHED_IOMMU_GROUPS_LIST=()

#
# logic
#
  function main
  {
    parse_inputs
    show_output
  }

  function initialize_iommu_group_match_flag
  {
    case "${input^^}" in
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

    return 0
  }

  function parse_devices
  {
    for bus_id in ${this_bus_id_list[@]}; do
      bus_id="${bus_id:5}"
      # driver=""
      # hardware_id=""
      name=""
      type=""
      vendor=""

      set_device_properties

      local -a input_list=$( \
        echo \
          "${input_delim}" \
        | tr \
          , \
          "\n" \
      )

      set_match_flag_by_iommu_group

      for this_input in ${input_list[@]}; do
        set_match_flag_by_device
      done
    done

    set_unmatch_flag
  }

  function parse_inputs
  {
    local -a previous_match_list=()
    local -ir minimum_key=0

    for key in ${!IOMMU_GROUP_ID_LIST[@]}; do
      previous_match_list+=( false )
    done

    for key in ${!INPUT_LIST[@]}; do
      local input=${INPUT_LIST["${key}"]}
      local input_delim=${INPUT_DICT["${input}"]}

      local match_iommu_group=false
      local match_name=false
      local match_type=false
      local match_vendor=false

      local previous_input=""
      local -i last_key=$(( ${key} - 1 ))

      initialize_iommu_group_match_flag
      parse_iommu_groups
    done
  }

  function parse_iommu_groups
  {
    for iommu_group_id in ${IOMMU_GROUP_ID_LIST[@]}; do
      local has_match=false
      local previous_has_match=false

      this_bus_id_list="$( \
        ls \
          "/sys/kernel/iommu_groups/${iommu_group_id}/devices/" \
        | sort \
          --version-sort
      )"

      parse_devices

      if [[ "${last_key}" -lt "${minimum_key}" ]]; then
        previous_input=""
        previous_match_list["${iommu_group_id}"]="${has_match}"

      else
        previous_input=${INPUT_LIST["${last_key}"]}
        previous_has_match=${previous_match_list["${iommu_group_id}"]}
      fi

      MATCH_IOMMU_GROUP_ID_LIST["${iommu_group_id}"]="${has_match}"
      previous_has_match=${previous_match_list["${iommu_group_id}"]}
      previous_input=${INPUT_LIST["${last_key}"]}

      if [[ "${previous_input}" =~ "UNMATCH" ]] \
        && [[ "${input_delim}" =~ "UNMATCH" ]]; then
        if ! "${previous_has_match}"; then
          has_match="${previous_has_match}"
        fi

      elif [[ "${previous_input}" =~ "MATCH" ]] \
        && ! [[ "${previous_input}" =~ "UNMATCH" ]] \
        && [[ "${input_delim}" =~ "MATCH" ]] \
        && ! [[ "${input_delim}" =~ "UNMATCH" ]]; then
        has_match="${previous_has_match}"

      else
        if ! "${previous_has_match}"; then
          has_match="${previous_has_match}"
        fi
      fi

      MATCH_IOMMU_GROUP_ID_LIST["${iommu_group_id}"]="${has_match}"
      previous_input=${INPUT_LIST["${last_key}"]}
      previous_match_list["${last_key}"]="${has_match}"
    done
  }

  function set_device_properties
  {
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

    return 0
  }

  function set_match_flag_by_device
  {
    # echo -e "\${has_match}\t\t== ${has_match}"
    # echo -e "\${input_delim}\t\t== ${input_delim}"
    # echo -e "\${name}\t\t\t== ${name}"
    # echo -e "\${type}\t\t\t== ${type}"
    # echo -e "\${vendor}\t\t== ${vendor}"
    # echo

    if "${match_name}" \
      && [[ "${name^^}" =~ "${this_input^^}" ]]; then
      has_match=true
    fi

    if "${match_type}" \
      && [[ "${type^^}" =~ "${this_input^^}" ]]; then
      has_match=true
    fi

    if "${match_vendor}" \
      && [[ "${vendor^^}" =~ "${this_input^^}" ]]; then
      has_match=true
    fi

    # echo -e "\${has_match}\t\t== ${has_match}"
    return 0
  }

  function set_match_flag_by_iommu_group
  {
    if ! "${match_iommu_group}" \
      || ! [[ ",${input_delim}," =~ ",${iommu_group_id}," ]]; then
      return 0
    fi

    has_match=true
    return 0
  }

  function set_unmatch_flag
  {
    if [[ "${input}" =~ "UNMATCH" ]]; then
      if "${has_match}"; then
        has_match=false
      else
        has_match=true
      fi
    fi

    return 0
  }

  function show_output
  {
    for input in ${INPUT_LIST[@]}; do
      echo -e "$\{INPUT_DICT[\"${input}\"]}\t== ${INPUT_DICT[${input}]}"
    done


    for key in "${!MATCH_IOMMU_GROUP_ID_LIST[@]}"; do
      value=${MATCH_IOMMU_GROUP_ID_LIST["${key}"]}
      echo -e "\${key},\t\${value}\t== ${key},\t${value}"
    done

    echo
  }

  function test1
  {
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

    INPUT_LIST=(
      "MATCH_GROUPS_LIST"
      "UNMATCH_GROUPS_LIST"
    )
  }

  function test2
  {
    INPUT_DICT["MATCH_GROUPS_LIST"]="0,2,3,4,5,6,7,8,9,10"
    INPUT_DICT["UNMATCH_GROUPS_LIST"]="1,9,10"


    INPUT_LIST=(
      "MATCH_GROUPS_LIST"
      "UNMATCH_GROUPS_LIST"
    )
  }

  function test3
  {
    INPUT_DICT["MATCH_TYPES_LIST"]="vga"

    INPUT_LIST=(
      "MATCH_TYPES_LIST"
    )
  }

  function test4
  {
    INPUT_DICT["UNMATCH_TYPES_LIST"]="vga,usb"

    INPUT_LIST=(
      "UNMATCH_TYPES_LIST"
    )
  }

#
# main
#
  test1
  main

  test2
  main

  test3
  main

  test4
  main

#
# NOTES
# - matches   are inclusive
# - unmatches are exclusive
#
#