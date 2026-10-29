#!/bin/bash

# This script allows for a local Linux account to be disabled, deleted and optionally archived

# Make sure the script is running with sudo or root privileges.

# Function that provides a usage statement if the user does not supply an account name on the command line.

usage() {
  echo "Usage: ${0} [-dra] USER_NAME [USER_NAME...]"
  echo "  -d Deletes account(s) instead of disabling."
  echo "  -r Removes the home directory associated with the account(s)."
  echo "  -a Creates an archive of the home directory associated with the account(s)."
  echo "Specify account(s) that should be disabled."
  exit 1
} >&2

archive_directory() {
  # This function creates a backup of a directory. Returns non-zero status on error.
  
  # Check if backup directory already exists.
  if [[ ! -d "/archives" ]]
  then
    mkdir -p "/archives" 
  fi

  # Make sure the account directory exists.
  local ACCOUNT_NAME=${1}
  local ACCOUNT_DIRECTORY="/home/${ACCOUNT_NAME}"
  if [[ -d "${ACCOUNT_DIRECTORY}" ]]
  then
    tar -zcf /archives/${ACCOUNT_NAME}.tgz -C /home "${ACCOUNT_NAME}" || return 1
  else
    # The directory doesn't exist, so inform the user and return a non-zero status.
    echo "Account directory does not exist, so it can not be archived." >&2
    return 1
  fi
}

# Check if root privileges are used.
if [[ "${UID}" -ne 0 ]]
then
  echo "Please run with sudo or as root." >&2
  exit 1
fi

while getopts dra OPTION
do
  case ${OPTION} in
    d)
      ACCOUNT_DELETION='true'
      ;;
    r)
      REMOVE_HOME_DIRECTORY='true'
      ;;
    a)
      ARCHIVE_HOME_DIRECTORY='true'
      ;;
    ?)
      usage
      ;;
  esac
done

# Remove the options while leaving the remaining args.
shift "$(( OPTIND - 1 ))"

# Check if the user provided at least one account name.
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Loop through all the usernames.
for USERNAME in "${@}"
do
  if ! id -u "${USERNAME}" &> /dev/null
  then
    echo "User ${USERNAME} does not exist." >&2
    continue
  fi
  # Check if UID is at least 1000.
  if [[ $(id -u "$USERNAME") -lt 1000 ]] 
  then
    echo "The ID of $USERNAME is less than 1000. This account will not be disabled or deleted." >&2
    continue
  fi
  echo "Processing the user: ${USERNAME}."
  # Create an archive if requested.
  if [[ "${ARCHIVE_HOME_DIRECTORY}" == 'true' ]]
  then
    if archive_directory "${USERNAME}"
    then
      echo "An archive was created for ${USERNAME} home directory."
    else
      echo "Could not create an archive for ${USERNAME}." >&2
    fi
  fi
  


  # Delete the user if requested.
  if [[ "${ACCOUNT_DELETION}" == 'true' ]]
  then
    userdel "${USERNAME}"
    # Make sure the user got deleted.
    if [[ "${?}" -ne 0 ]]
    then
      echo "The account ${USERNAME} was NOT deleted." >&2
    else
      echo "The account ${USERNAME} was deleted."
    fi
  else
    # Disable the account.
    chage -E 0 "${USERNAME}"
    # Make sure the user got disabled.
    if [[ "${?}" -ne 0 ]]
    then
      echo "The account ${USERNAME} was NOT disabled." >&2
    else
      echo "The account ${USERNAME} was disabled."
    fi
  fi
  
  # Delete the home directory if requested.
  if [[ "${REMOVE_HOME_DIRECTORY}" == 'true' ]]
  then
    rm -rf "/home/${USERNAME}"
    # Make sure the user got deleted.
    if [[ "${?}" -ne 0 ]]
    then
      echo "Home directory of ${USERNAME} was NOT deleted." >&2
    else
      echo "Home directory of ${USERNAME} was deleted."
    fi
  fi

done
