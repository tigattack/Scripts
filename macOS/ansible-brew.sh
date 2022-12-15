#!/bin/bash

# Define Infrastructure repo path. Used for pip requirements.
infraRepoPath="$HOME/Documents/Development/Infrastructure"

if [ $(brew info ansible | grep 'Not installed' >/dev/null) ]; then
	echo 'Ansible not installed.'
	exit 1
fi

# Determine Ansible install path
ansiblePath=$(brew info ansible | grep Cellar | sed 's/\(.*\) (.*/\1/')
# Define Ansible's Python binary path
ansiblePyPath="$ansiblePath/libexec/bin/python"

# Upgrade pip
$ansiblePyPath -m pip install --upgrade pip

# Install dependencies if Infrastructure repo exists
if [ -d "$infraRepoPath" ]; then
	$ansiblePyPath -m pip install -r "$infraRepoPath/ansible/requirements.txt"
else
	echo "Infrastructure repo not found at: $infraRepoPath"
	echo 'pip requirements will not be installed.'
	echo "To install manually later, please run: $ansiblePyPath -m pip install -r \"$infraRepoPath/ansible/requirements.txt\""
fi

# Install and activate Python argument completion
pip3 install argcomplete
sudo activate-global-python-argcomplete
