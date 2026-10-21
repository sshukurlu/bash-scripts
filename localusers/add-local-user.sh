#!/bin/bash

# This script adds users to the same Linux system as the script is executed on

# check if user is a superuser or uses a sudo command
if [[ "$UID" -ne 0  ]]
then
    echo "This script should be executed with root privileges"
    exit 1    
fi

# ask for the username 
read -p 'Enter the username: ' USER_NAME

# ask for the real name
read -p 'Enter the name of the person this account is for: ' COMMENT 
# ask for the password
read -p 'Enter the password: ' PASSWORD

# Create the user
useradd -c "${COMMENT}" -m ${USER_NAME}

# inform the user if the account was not able to be created for some reason
if [[ "${?}" -ne 0  ]]
    then
      echo 'The useradd command didnt execute succesfully'
      exit 1
fi

# Set the password for the user
echo ${PASSWORD} | passwd --stdin ${USER_NAME}

# Force password change on first login
passwd -e ${USER_NAME}

# Display the username, password and host where the account was created 

echo "The username is ${USER_NAME}, the password is ${PASSWORD}, the host is ${HOSTNAME}"

exit 0