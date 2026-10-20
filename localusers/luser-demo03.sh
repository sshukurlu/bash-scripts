#!/bin/bash

# Display the UID and username of the user executing this script.
# Display if the user is the vagrant user or not


# Display the UID.
echo "Your UID is ${UID}"

# Only display if the UID doesn't match 1000.
UID_TO_TEST_FOR='1000'
if [[ "${UID}" -ne "${UID_TO_TEST_FOR}" ]]
then
	echo "Your UID doesn't match ${UID_TO_TEST_FOR}"
        exit 1

fi	

# Display the username.
USER_NAME=$(id -un)

# Test if the command succeded.
# {?} holds the exit status of the most recently executed command
if [[ "${?}" -ne 0  ]]
    then
      echo 'The id command did not execute succesfully'
      exit 1      
fi	
echo "Your username is ${USER_NAME}"

# you can use a string test conditional
# -eq / -ne is for number types and = / == is for strings. 
USER_NAME_TO_TEST_FOR='ec2-user'
if [[ "${USER_NAME}" = "$USER_NAME_TO_TEST_FOR" ]]
then
	echo "Your username matches ${USER_NAME_TO_TEST_FOR}."
fi


# test for != (not equal) for the string 
if [[ "${USER_NAME}" != "${USER_NAME_TO_TEST_FOR}" ]]
then
	echo "Your username doesn't match ${USER_NAME_TO_TEST_FOR}"
	exit 1
fi

exit 0  

