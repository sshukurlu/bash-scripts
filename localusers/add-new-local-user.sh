#!/bin/bash

# This script creates a new user on the local system.
# You'll need to supply a username (login) as an argument to the script.
# Optionally, you can also provide a comment for the account as an argument.
# A password will be automatically generated for the account.
# The username, password and host for the account will be displayed.

# Make sure the script is being executed with superuser privileges.
if [[ "$UID" -ne 0  ]]
then
    echo "Please run with sudo or as root."
    exit 1    
fi

# Make sure the user supplied at least one argument.
NUMBER_OF_PARAMETERS="${#}"
if [[ "${NUMBER_OF_PARAMETERS}" -lt 1 ]]
then
  echo "Please run the command with at least one argument (username). For example:"
  echo "'sudo ./add-new-local-user.sh argument1 [optional_argument2]...'"
  exit 1
fi

# Create a variable for the first parameter (login).
USER_NAME="${1}"

# Then using shift create the COMMENT variable.
shift
COMMENT="${@}" 

# Generate a password.
PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c48)

# Create the account.
useradd -c "${COMMENT}" -m ${USER_NAME}

# Check to see if the useradd command succeeded.
# Inform the user if the account was not able to be created for some reason.
if [[ "${?}" -ne 0  ]]
    then
      echo 'The account could not be created.'
      exit 1
fi

# Set the generated earlier password for the account.
echo ${PASSWORD} | passwd --stdin ${USER_NAME}

# Check to see if the passwd command succeeded.
if [[ "${?}" -ne 0  ]]
then
    echo 'The password for the account could not be set.'
    exit 1
fi

# Force password change on first login.
passwd -e ${USER_NAME}

# Display the username, password and the host where the account was created 
echo
echo 'username:'
echo "${USER_NAME}"
echo
echo 'password:'
echo "${PASSWORD}"
echo
echo 'host:'
echo "${HOSTNAME}"

exit 0