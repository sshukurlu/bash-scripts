#!/bin/bash

# This script displays the number of failed login attempts by IP address and location.

LOG_FILE="${1}"

# Make sure a file was supplied as an argument.
if [[ ! -e "${LOG_FILE}" ]]
then
  echo "Cannot open log file: ${LOG_FILE}." >&2
  exit 1
fi

# Display the CSV header.
echo "Count,IP,Location"

# Filter attempts greater than 10 and loop through the IP addresses.
awk '/Failed password for root from/ {print $11}' "${LOG_FILE}" | sort | uniq -c | sort -nr | awk '$1 > 10' | while read COUNT IP
do
  # Display count, IP and location.
  COUNTRY=$(geoiplookup "${IP}" | awk -F ', ' '{print $2}')
  echo "${COUNT},${IP},${COUNTRY}"
done 
