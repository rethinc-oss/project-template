#!/usr/bin/env bash
set -e

LIBRARIAN_PUPPET_CMD='/opt/puppetlabs/puppet/bin/librarian-puppet'
PUPPET_ENV_DIR_PROJECT='/vagrant/.devsupport/puppet/environments/localdev/'
PUPPET_ENV_DIR_LOCAL_PARENT='/etc/puppetlabs/code/environments/'
PUPPET_ENV_DIR_LOCAL_NAME='localdev'
PUPPET_ENV_DIR_LOCAL=${PUPPET_ENV_DIR_LOCAL_PARENT}${PUPPET_ENV_DIR_LOCAL_NAME}


if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi 

if ! [ -x "$(command -v git)" ]; then
    echo "Installing git & rsync..."
    DEBIAN_FRONTEND=noninteractive apt -q update > /dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt -q -y install git rsync > /dev/null 2>&1
fi

if [ "$(/opt/puppetlabs/puppet/bin/gem search -i librarian-puppet)" = "false" ]; then
    echo "Installing librarian-puppet.."
    /opt/puppetlabs/puppet/bin/gem install --no-ri --no-rdoc librarian-puppet > /dev/null 2>&1
fi

echo "Preparing environment..."

if [ -f "${PUPPET_ENV_DIR_LOCAL}/Puppetfile.lock" ]; then
    echo "Updating puppet modules..."
    ( cd ${PUPPET_ENV_DIR_LOCAL_PARENT}${PUPPET_ENV_DIR_LOCAL_NAME} && $LIBRARIAN_PUPPET_CMD update )
else
    echo "Installing puppet modules..."
    ( cp -r ${PUPPET_ENV_DIR_PROJECT} ${PUPPET_ENV_DIR_LOCAL_PARENT} )
    ( cd ${PUPPET_ENV_DIR_LOCAL} && $LIBRARIAN_PUPPET_CMD install )
fi

echo "Syncing puppet modules back to host folder..."
rsync -rltgoD ${PUPPET_ENV_DIR_LOCAL}/modules/ ${PUPPET_ENV_DIR_PROJECT}/modules/
