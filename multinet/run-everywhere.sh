#!/bin/bash

# This scripts executes a given command on multiple servers.

# A list of servers, one per line.
SERVER_LIST='/home/ec2-user/shellclass/multinet/servers'

# Set basic ssh command options.
SSH_OPTIONS='-o ConnectTimeout=2'

usage() {
  echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" 
  echo '  -f FILE Use file for the list of servers on every server. Default ${SERVER_LIST}'
  echo '  -n      Dry run mode.'
  echo '  -s      Use sudo on the remote server.'
  echo '  -v      Increase verbosity.'
  echo 'Specify the COMMAND that should be executed on every server.'
  exit 1
} >&2

# Parse the options.
while getopts f:nsv OPTION
do
  case ${OPTION} in
    f) SERVER_LIST="${OPTARG}" ;;
    n) DRY_RUN='true' ;; 
    s) SUDO='sudo' ;;
    v) VERBOSE='true' ;;
    ?) usage ;;
  esac
done

# Make sure the script is not being executed with superuser privileges.
if [[ "${UID}" -eq 0 ]]
then
  echo "Please execute without superuser privileges. Use the -s option instead." >&2
  usage
fi

# Remove the options while leaving the remaining args.
shift "$(( OPTIND - 1 ))"

# Check if a command is specified.
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Anything that remains on the command line is to be treated as a single command.
COMMAND="${@}"

# Make sure the SERVER_LIST file exists.
if [[ ! -e "${SERVER_LIST}" ]]
then 
  echo "Cannot open server list file ${SERVER_LIST}." >&2
  exit 1
fi

# Expect the best, prepare for the worst.
EXIT_STATUS='0'

# Loop through the SERVER_LIST.
for SERVER in $(cat ${SERVER_LIST})
do
  if [[ "${VERBOSE}" == 'true' ]]
  then
    echo "${SERVER}"
  fi
  
  SSH_COMMAND="ssh ${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"
  # If it's a dry run, don't execute anything, just echo it.
  if [[ "${DRY_RUN}" == 'true' ]]
  then
    echo "DRY RUN: ${SSH_COMMAND}"
  else
    ${SSH_COMMAND}
    SSH_EXIT_STATUS="${?}"
      
    # Capture any non-zero exit status from the SSH_COMMAND and report to the user.
     if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
     then
       EXIT_STATUS="${SSH_EXIT_STATUS}"
       echo "Execution on ${SERVER} failed" >&2
     fi
  fi
done

exit ${EXIT_STATUS}
