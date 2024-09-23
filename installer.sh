#!/bin/bash

#
# Filename:       installer.sh
# Version:        1.0.0
# Description:    Install executable and source files.
# Author(s):      Alex Portell <github.com/portellam>
# Maintainer(s):  Alex Portell <github.com/portellam>
#

#
# params
#
  SCRIPT_NAME="parse-iommu-devices"

  DO_INSTALL=true
  DO_UNINSTALL=false

  DESTINATION_PATH="/usr/local/bin/"
  DESTINATION_BINARY_PATH="${DESTINATION_PATH}${SCRIPT_NAME}.d/"
  SOURCE_PATH="$( pwd )/"
  SOURCE_BINARY_PATH="${SOURCE_PATH}bin/"

#
# logic
#
  function install_many
  {
    if [[ ! -d "${DESTINATION_BINARY_PATH}" ]] \
      && ! mkdir --parents "${DESTINATION_BINARY_PATH}" &> /dev/null; then
      echo "Error: Cannot create script directory '${DESTINATION_BINARY_PATH}'."
      return 1
    fi

    for binary in $( ls "${SOURCE_BINARY_PATH}" ); do
      if [[ "${binary}" =~ "${SCRIPT_NAME}" ]]; then
        if ! install_this \
          "${SOURCE_BINARY_PATH}" "${DESTINATION_PATH}" "${binary}"; then
          return 1
        fi
      fi

      if ! install_this \
        "${SOURCE_BINARY_PATH}" "${DESTINATION_BINARY_PATH}" "${binary}"; then
        return 1
      fi
    done

    echo "Install successful."
    return 0
  }

  function install_this
  {
    if [[ ! -e "${1}${3}" ]]; then
      echo "Error: Cannot locate script file '${3}'."
      return 1
    fi

    if ! cp --force --recursive "${1}${3}" \
      "${2}${3}" &> /dev/null; then
      echo "Error: Cannot copy script file '${3}'."
      return 1
    fi

    if ! chmod u+x "${2}${3}" \
      &> /dev/null; then
      echo "Error: Cannot set script file '${3}' as executable."
      return 1
    fi

    return 0
  }

  function is_user_root
  {
    if [[ $( whoami ) != "root" ]]; then
      echo "User is not root."
      return 1
    fi

    return 0
  }

  function print_invalid_argument
  {
    print_and_log_output "Error: Invalid argument(s) specified."
    print_usage
    exit 1
  }

  function print_invalid_option
  {
    print_and_log_output "Error: Invalid option specified."
    print_usage
    exit 1
  }

  function parse_many_arguments
  {
    if [[ "${1}" == "-"* ]] \
      && [[ "${1}" != "--"* ]]; then
      for char in $( \
        echo "${1:1}" \
          | sed -e 's/\(.\)/\1\n/g'
      ); do
        argument="-${char}"

        if [[ -z "${argument}" ]]; then
          break
        fi

        parse_this_argument "${argument}"
      done

      shift
    fi

    parse_this_argument "${@}"
  }

  function parse_this_argument
  {
    while [[ ! -z "${1}" ]]; do
      case "${1}" in
        "-i" | "--install" )
          DO_INSTALL=true
          DO_UNINSTALL=false
          ;;

        "-u" | "--uninstall" )
          DO_UNINSTALL=true
          DO_INSTALL=false
          ;;

        "" )
          return 0
          ;;

        "-h" | "--help" )
          print_usage
          exit 2
          ;;

        * )
          print_invalid_argument
          ;;

      esac

      shift
    done

    return 0
  }

  function print_usage
  {
    echo -e \
      "Installer for ${SCRIPT_NAME}." \
      "\n" \
      "\n  -h, --help       Print this help and exit." \
      "\n  -i, --install    Install ${SCRIPT_NAME}." \
      "\n  -u, --uninstall  Uninstall ${SCRIPT_NAME}."
  }

  function uninstall_many
  {
    if [[ -e "${DESTINATION_PATH}${SCRIPT_NAME}" ]] \
      && ! rm --force "${DESTINATION_PATH}${SCRIPT_NAME}" &> /dev/null; then
      echo "Error: Cannot remove script file '${SCRIPT_NAME}'."
      return 1
    fi

    if [[ -d "${DESTINATION_BINARY_PATH}" ]] \
      && ! rm --force --recursive "${DESTINATION_BINARY_PATH}" &> /dev/null; then
      echo "Error: Cannot remove binary directory '${DESTINATION_BINARY_PATH}'."
      return 1
    fi

    echo "Uninstall successful."
    return 0
  }

  function main
  {
    if ! is_user_root; then
      return 1
    fi

    if ! parse_many_arguments "$@"; then
      return 1
    fi

    if "${DO_INSTALL}" \
      && ! install_many; then
      echo "Install failed."
      return 1
    fi

    if "${DO_UNINSTALL}" \
      && ! uninstall_many; then
      echo "Uninstall failed."
      return 1
    fi

    return 0
  }

main "$@"
exit "${?}"