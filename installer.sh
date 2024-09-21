#!/bin/bash

#
# Filename:       installer.sh
# Version:        1.0.0
# Description:    Install executable and source files.
# Author(s):      Alex Portell <github.com/portellam>
# Maintainer(s):  Alex Portell <github.com/portellam>
#

function is_user_root
  {
    if [[ $( whoami ) != "root" ]]; then
      echo "User is not root."
      return 1
    fi

    return 0
  }

function install
{
  local -r relative_path="bin"
  local -r script_file="parse-iommu-devices"
  local -r parent_path="/usr/local/bin/"
  local -r binary_path="${parent_path}/${script_file}.d/"

  if ! mkdir --parents "${binary_path}" &> /dev/null; then
    echo "Error: Cannot create script directory '${binary_path}'."
    return 1
  fi

  if ! install_this "${script_file}" "${parent_path}" \
    || ! install_this "datatype_src" "${binary_path}" \
    || ! install_this "file_src" "${binary_path}" \
    || ! install_this "input_src" "${binary_path}" \
    || ! install_this "parse_src" "${binary_path}" \
    || ! install_this "print_src" "${binary_path}" \
    || ! install_this "query_src" "${binary_path}" \
    || ! install_this "xml_src" "${binary_path}"; then
    return 1
  fi

  return 0
}

function install_this
{
  if [[ ! -e "${relative_path}/${1}" ]]; then
    echo "Error: Cannot locate script file '${1}'."
    return 1
  fi

  if ! cp --force --recursive "${relative_path}/${1}" \
    "${2}${1}" &> /dev/null; then
    echo "Error: Cannot copy script file '${1}'."
    return 1
  fi

  if ! chmod u+x "${2}${1}" \
    &> /dev/null; then
    echo "Error: Cannot set script file '${1}' as executable."
    return 1
  fi

  return 0
}

function main
{
  if ! is_user_root \
    || ! install; then
    echo "Install failed."
    return 1
  fi

  echo "Install successful."
  return 0
}

main
exit "${?}"