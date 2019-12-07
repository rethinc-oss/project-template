#!/usr/bin/env bash
set -e

LIBRARIAN_PUPPET_CMD='/opt/puppetlabs/puppet/bin/librarian-puppet'
PUPPET_ENV_DIR='/vagrant/.devsupport/puppet/environments/localdev'


if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi 

if ! [ -x "$(command -v git)" ]; then
    echo "Installing git..."
    DEBIAN_FRONTEND=noninteractive apt -q update > /dev/null 2>&1
    DEBIAN_FRONTEND=noninteractive apt -q -y install git > /dev/null 2>&1
fi

if [ "$(/opt/puppetlabs/puppet/bin/gem search -i librarian-puppet)" = "false" ]; then
    echo "Installing librarian-puppet.."
    /opt/puppetlabs/puppet/bin/gem install --no-ri --no-rdoc librarian-puppet > /dev/null 2>&1
fi

echo "Preparing environment..."

if [ -f "${PUPPET_ENV_DIR}/Puppetfile.lock" ]; then
    echo "Updating modules..."
    echo "TODO: enable again..."
#    ( cd ${PUPPET_ENV_DIR} && $LIBRARIAN_PUPPET_CMD update )
else
    echo "Installing modules..."  
    ( cd ${PUPPET_ENV_DIR} && $LIBRARIAN_PUPPET_CMD install )
fi
