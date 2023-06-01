#!/bin/bash

print_message() {
  local color=$1
  local message=$2
  echo -en "${color}${message}${NC}"
}

print_error() {
  local message=$1
  print_message "${RED}" "Error: ${message}\n"
  exit 1
}

execute_step() {
  local step_description=$1
  local command=$2

  current_step=$((current_step + 1))
  print_message $NC "Step "
  print_message $DEEP_BLUE "$current_step/$total_steps"
  print_message $NC ": $step_description\n"
  if [ -z "$verbose_flag" ]; then
    eval "$command" >/dev/null 2>&1
  else
    eval "$command"
  fi
  exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    print_message $GREEN "Step completed successfully.\n"
  else
    print_message $RED "Step failed with exit code $exit_code.\n"
  fi
}

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
DEEP_BLUE='\033[0;34m'

total_steps=10
current_step=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      verbose_flag=1
      shift
      ;;
    *)
      print_message $RED "Invalid argument: $1\n"
      exit 1
      ;;
  esac
done

echo "

██╗░░░██╗██████╗░██████╗░░█████╗░████████╗███████╗  ██╗███╗░░██╗
██║░░░██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝  ██║████╗░██║
██║░░░██║██████╔╝██║░░██║███████║░░░██║░░░█████╗░░  ██║██╔██╗██║
██║░░░██║██╔═══╝░██║░░██║██╔══██║░░░██║░░░██╔══╝░░  ██║██║╚████║
╚██████╔╝██║░░░░░██████╔╝██║░░██║░░░██║░░░███████╗  ██║██║░╚███║
░╚═════╝░╚═╝░░░░░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝  ╚═╝╚═╝░░╚══╝

██████╗░██████╗░░█████╗░░██████╗░██████╗░███████╗░██████╗░██████╗
██╔══██╗██╔══██╗██╔══██╗██╔════╝░██╔══██╗██╔════╝██╔════╝██╔════╝
██████╔╝██████╔╝██║░░██║██║░░██╗░██████╔╝█████╗░░╚█████╗░╚█████╗░
██╔═══╝░██╔══██╗██║░░██║██║░░╚██╗██╔══██╗██╔══╝░░░╚═══██╗░╚═══██╗
██║░░░░░██║░░██║╚█████╔╝╚██████╔╝██║░░██║███████╗██████╔╝██████╔╝
╚═╝░░░░░╚═╝░░╚═╝░╚════╝░░╚═════╝░╚═╝░░╚═╝╚══════╝╚═════╝░╚═════╝░

"

execute_step "Removing locks" "sudo rm -f /var/lib/dpkg/lock-frontend && sudo rm -f /var/lib/dpkg/lock"

execute_step "Updating package lists" "sudo apt-get update"
execute_step "Upgrading packages" "sudo apt-get upgrade -y"
execute_step "Performing distribution upgrade" "sudo apt-get dist-upgrade -y"
execute_step "Cleaning package cache" "sudo apt-get autoclean -y"
execute_step "Checking for broken packages" "sudo apt-get check"

read -p "Press 's' to skip the vulnerability scan or any other key to continue: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
  execute_step "Scanning for vulnerabilities" "sudo apt-get install -y clamav && sudo freshclam && sudo clamscan -ri --bell /"
else
  print_message $GREEN "Skipping vulnerability scan.\n"
fi

execute_step "Verifying system file integrity" "sudo apt-get install -y debsums && sudo debsums -c"

print_message $GREEN "Update, upgrade, and security check complete!\n"

