#!/bin/bash/env bash

#
# Filename:       parse-iommu-devices.sh
# Description:    Parse, sort, and display hardware devices by IOMMU group.
# Author(s):      Alex Portell <github.com/portellam>
# Maintainer(s):  Alex Portell <github.com/portellam>
# Version:        1.0.0
#

shopt -s nullglob

declare -r SCRIPT_VERSION="1.0.0"
declare -r SCRIPT_NAME="$( basename "${0}" )"

declare -A ARGUMENTS=(
  ["GROUPS_TO_READ"]=""
  ["READ_GROUPS"]=false
  ["READ_TYPES"]=false
  ["SHOW_ALL"]=true
  ["SHOW_DRIVERS"]=false
  ["SHOW_EXTERNALS"]=true
  ["SHOW_HW_IDS"]=false
  ["SHOW_INTERNALS"]=true
  ["SHOW_NAMES"]=false
  ["SHOW_VGA_GROUP_INDEX"]=false
  ["TYPES_TO_READ"]=""
  ["VGA_GROUP_INDEX_TO_SHOW"]=""
)

declare -A OUTPUTS=(
  ["SHOWN_GROUPS"]=""
  ["SHOWN_DRIVERS"]=""
  ["SHOWN_HW_IDS"]=""
)

function parse_arguments
{
  while [[ ! -z "${1}" ]]; do
    case "${1,,}" in
      "-d" | "--driver" )
          ARGUMENTS["SHOW_ALL"]=false
          ARGUMENTS["SHOW_DRIVERS"]=true
        ;;

      "-e" | "--external" )
          ARGUMENTS["SHOW_EXTERNALS"]=true
          ARGUMENTS["SHOW_INTERNALS"]=false
        ;;

      "-g" | "--group" )
          ARGUMENTS["READ_GROUPS"]=true
          shift
          ARGUMENTS["GROUPS_TO_READ"]="${1}"
        ;;

      "-h" | "--hardware-id" )
          ARGUMENTS["SHOW_ALL"]=false
          ARGUMENTS["SHOW_HW_IDS"]=true
        ;;

      "-v" | "--vga-index" )
          ARGUMENTS["SHOW_VGA_GROUP_INDEX"]=true
          shift
          ARGUMENTS["VGA_GROUP_INDEX_TO_SHOW"]="${1}"
        ;;

      "-n" | "--name" )
          ARGUMENTS["SHOW_ALL"]=false
          ARGUMENTS["SHOW_NAMES"]=true
        ;;

      "-t" | "--type" )
          ARGUMENTS["READ_TYPES"]=true
          shift
          ARGUMENTS["TYPES_TO_READ"]="${1}"
        ;;

      "" )
        return 0
        ;;

      "-h" | "--help" )
        print_usage
        exit 0
        ;;

      * )
        print_usage
        exit 1
        ;;

    esac

    shift
  done
}

function print_usage
{
  echo -e "Usage:\tbash ${SCRIPT_NAME} [ARGUMENTS]..."
  echo -e "Parse, sort, and display hardware devices by IOMMU group."
  echo -e "Version ${SCRIPT_VERSION}."
  echo
  echo -e "  -h, --help  Print this help and exit."
  echo

  echo -e "  -e, --external [OPTION]     Show only IOMMU groups with external" \
    "devices." \

  echo -e "  -h, --hardware-id [OPTION]  Show hardware IDs."
  echo -e "  -n, --name [OPTION]         Sort by device name keyword."
  echo -e "  -d, --driver [OPTION]       Sort by driver keyword."
  echo -e "  -g, --group [OPTION]        Sort by IOMMU group ID."
  echo -e "  -t, --type  [OPTION]        Sort by device type keyword."
  echo -e "  -v, --vga-index  [OPTION]   Sort by the VGA group indices (not IDs)."
  echo
  echo -e "Examples:"
  echo -e "  bash ${SCRIPT_NAME} -e -v 1  Show only IOMMU groups with external" \
  "devices, and exclude IOMMU groups with VGA device(s) after the first (1) match."
}

function show_groups
{
  vga_group_index=0

  for group in $( \
    find /sys/kernel/iommu_groups/* -maxdepth 0 -type d \
    | sort --version-sort
  ); do
    group_id="${group##*/}"
    echo "IOMMU Group ${group_id}:"

    if "${ARGUMENTS["READ_GROUPS"]}" \
      && ! $( \
        echo ",${ARGUMENTS["GROUPS_TO_READ"]}," \
          | grep --quiet ",${group_id},"
      ); then
      continue
    fi

    group_id_list=""
    driver_list=""
    hardware_id_list=""
    has_type=false
    has_vga=false

    for device in ${group##}/devices/*; do
      name="$( lspci -s ${device##*/} )"
      name="${name:8}"

      bus_id="$( \
        lspci -ns ${device##*/} \
          | awk 'END {print $1}'
      )"

      hardware_id="$( \
        lspci -ns ${device##*/} \
          | awk 'END {print $3}'
      )"

      driver="$( \
        lspci -kns ${device##*/} \
          | grep "driver" \
          | awk 'END {print $5}'
      )"

      if ! "${ARGUMENTS["SHOW_EXTERNALS"]}" \
        && [[ "${bus_id::2}" != "00" ]]; then
        continue
      fi

      if ! "${ARGUMENTS["SHOW_INTERNALS"]}" \
        && [[ "${bus_id::2}" == "00" ]]; then
        continue
      fi

      if ! "${has_type}" \
        && "${ARGUMENTS["READ_TYPES"]}"; then
        for type in $( \
            echo "${ARGUMENTS["TYPES_TO_READ"]}" \
              | sed "s/,/ /g"
        ); do
          if $( \
            echo "${name,,}" \
              | grep --quiet "${type,,}"
          ); then
            has_type=true
            continue
          fi
        done
      fi

      if $( \
        echo "${name,,}" \
          | grep --quiet "vga"
      ); then
        has_vga=true
      fi

      if "${ARGUMENTS["READ_TYPES"]}" \
        && ! "${has_type}"; then
        continue
      fi

      echo -e "\tBus ID:\t${bus_id}"

      if "${ARGUMENTS["SHOW_ALL"]}" \
        || "${ARGUMENTS["SHOW_NAMES"]}"; then
        echo -e "\t\tName:\t\t${name}"
      fi

      if "${ARGUMENTS["SHOW_ALL"]}" \
        || "${ARGUMENTS["SHOW_HW_IDS"]}"; then
        echo -e "\t\tHardware ID:\t${hardware_id}"
      fi

      if "${ARGUMENTS["SHOW_ALL"]}" \
        || "${ARGUMENTS["SHOW_DRIVERS"]}"; then
        echo -e "\t\tDriver:\t\t${driver}"
      fi

      echo

      if [[ ",${group_id_list,,}," != *",${group_id},"* ]]; then
        group_id_list+="${group_id},"
      fi

      if [[ ",${driver_list,,}," != *",${driver},"* ]]; then
        driver_list+="${driver},"
      fi

      if [[ ",${hardware_id_list,,}," != *",${hardware_id},"* ]]; then
        hardware_id_list+="${hardware_id},"
      fi
    done

    if "${has_vga}"; then
      (( vga_group_index++ ))
    fi

    if "${ARGUMENTS["SHOW_VGA_GROUP_INDEX"]}" \
      && "${has_vga}" \
      && [[ ",${ARGUMENTS["VGA_GROUP_INDEX_TO_SHOW"],,}," \
        != *",${vga_group_index},"* ]]; then
      group_id_list=""
      driver_list=""
      hardware_id_list=""
    fi

    OUTPUTS["SHOWN_GROUPS"]+="${group_id_list}"
    OUTPUTS["SHOWN_DRIVERS"]+="${driver_list}"
    OUTPUTS["SHOWN_HW_IDS"]+="${hardware_id_list}"
    echo
  done

  if [[ ! -z "${OUTPUTS["SHOWN_GROUPS"]}" ]]; then
    OUTPUTS["SHOWN_GROUPS"]="${OUTPUTS["SHOWN_GROUPS"]::-1}"
  fi

  if [[ ! -z "${OUTPUTS["SHOWN_DRIVERS"]}" ]]; then
    OUTPUTS["SHOWN_DRIVERS"]="${OUTPUTS["SHOWN_DRIVERS"]::-1}"

    OUTPUTS["SHOWN_DRIVERS"]="$( \
      echo "${OUTPUTS["SHOWN_DRIVERS"]}" \
        | sed --expression $'s/,/\\\n/g' \
        | sort --numeric-sort \
        | tr '\n' ',' \
        | sed 's/.$//' \
        | tr ',' '\n' \
        | sort --unique \
        | xargs \
        | tr ' ' ','
    )"
  fi

  if [[ ! -z "${OUTPUTS["SHOWN_HW_IDS"]}" ]]; then
    OUTPUTS["SHOWN_HW_IDS"]="${OUTPUTS["SHOWN_HW_IDS"]::-1}"

    OUTPUTS["SHOWN_HW_IDS"]="$( \
      echo "${OUTPUTS["SHOWN_HW_IDS"]}" \
        | sed --expression $'s/,/\\\n/g' \
        | sort --numeric-sort \
        | tr '\n' ',' \
        | sed 's/.$//' \
        | tr ',' '\n' \
        | sort --unique \
        | xargs \
        | tr ' ' ','
    )"
  fi

  echo -e "Groups:\t\t${OUTPUTS["SHOWN_GROUPS"]}"
  echo -e "Drivers:\t${OUTPUTS["SHOWN_DRIVERS"]}"
  echo -e "Hardware IDs:\t${OUTPUTS["SHOWN_HW_IDS"]}"
}

function main
{
  parse_arguments "${@}" || return 1
  show_groups
}

main "$@"