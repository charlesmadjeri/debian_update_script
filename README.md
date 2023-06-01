# Debian security script

A Debian's OS bash script to simplify update, upgrade and system security check

## How does it work?

This simple script uses apt-get commands to update and upgrade cleanly your OS:

* update
* upgrade
* dist-upgrade
* autoclean
* check

[optionnal] This script can use the clamav security tool to fully check your full OS's files:

* freshclam
* clamscan

This script also checks your file system's integrity with debsums.

## Getting Started

### Installation

Just copy the content of the script or clone the repository.

### Quickstart

Review the script's code before executing it.

You need previously to install configure and use:

* apt-get as package manager.
* clamav as security tool.
* debsums

### Usage

```bash update-os.sh```
