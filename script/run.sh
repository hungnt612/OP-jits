#!/usr/bin/env bash
# This script will installs and configures Cinder,Glance, Horizon,Keystone, Nova, Neutron, and Swift
# THIS SCRIPT MUST BE RUN AS NON ROOT USER
#Print the commands being run 
set -o xtrace

unset LANG
unset LANGUAGE
LC_ALL=en_US.utf8
export LC_ALL

# Not all distros have sbin in PATH for regular users.
PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin

# Keep track of the DevStack directory
TOP_DIR=$(cd $(dirname "$0") && pwd)

# Check for uninitialized variables, a big cause of bugs
NOUNSET=${NOUNSET:-}
if [[ -n "$NOUNSET" ]]; then
    set -o nounset
fi

# Set start of devstack timestamp
START_TIME=$(date +%s)


# Check if run as a non-root user;
if [[ $EUID -eq 0 ]]; then
    set +o xtrace
    echo "This script should be run as a user with sudo permissions, "
    echo "not root."
    echo "A \"openstack\" user configured correctly can be created with:"
    echo " $TOP_DIR/tools/create-user.sh"
    exit 1
fi

# Check for a ``localrc`` section embedded in ``local.conf`` and extract if
# ``localrc`` does not already exist

# Configure sudo
# --------------


# UEC images ``/etc/sudoers`` does not have a ``#includedir``, add one
sudo grep -q "^#includedir.*/etc/sudoers.d" /etc/sudoers ||
    echo "#includedir /etc/sudoers.d" | sudo tee -a /etc/sudoers

# Configure Distro Repositories
# -----------------------------

# For Debian/Ubuntu make apt attempt to retry network ops on it's own
echo 'APT::Acquire::Retries "20";' | sudo tee /etc/apt/apt.conf.d/80retry  >/dev/null

# Configure Target Directories
# ----------------------------

# Destination path for installation ``DEST``
DEST=${DEST:-/opt/openstack}


sudo apt -y install software-properties-common
sudo add-apt-repository --yes cloud-archive:victoria
echo ""
sudo apt update && sudo apt upgrade

