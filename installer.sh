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

  if [[ ! -e "${relative_path}/${script_file}" ]]; then
    echo "Error: Cannot locate script file."
    return 1
  fi

  local -r destination_path="/usr/local/bin"

  if ! cp --force --recursive "${relative_path}/${script_file}" \
    "${destination_path}/${script_file}" &> /dev/null; then
    echo "Error: Cannot copy script file."
    return 1
  fi

  if ! chmod u+x "${destination_path}/${script_file}" \
    &> /dev/null; then
    echo "Error: Cannot set script file as executable."
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