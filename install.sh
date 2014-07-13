#!/bin/bash
# anotify installation script
# @author Cedric Haase

REQUIRED_BINARIES="cron msmtp"

CACHE_DIR='/var/cache/anotify'
CONFIG_DIR='/etc/anotify'

LOGFILE='/var/log/anotify.log'
SUBSCRIPTION_LIST="${CONFIG_DIR}/anotify.conf"
SENT_LINKS="${CACHE_DIR}/sent"
SENT_RAW_LINKS="${CACHE_DIR}/sentraw"

# backup configuration dir
BACKUP_DIR=""

binary_missing () {
  binary=${1}

  cat "/etc/os-release" | grep -i debian && apt-get install ${binary} ||
  { echo "${binary} is not installed on your system. Please install it manually."; exit 1; }
}

install_backup () {
  find "${BACKUP_DIR}/anotify.conf" && cp -v "${BACKUP_DIR}/anotify.conf" "${CONFIG_DIR}/"

  return $?
}

# make sure we are root
test ${UID} -eq 0 || { echo "Must be run as root."; exit 1; }

# check for required binaries
for binary in ${REQUIRED_BINARIES}; do
  which ${binary} || binary_missing ${binary}
done

# create directories and files
mkdir -p "${CACHE_DIR}"
mkdir -p "${CONFIG_DIR}"
for file in ${LOGFILE} ${SUBSCRIPTION_LIST} ${SENT_LINKS} ${SENT_RAW_LINKS}; do
  touch ${file}
done

# copy script
cp anotify.sh /usr/bin/anotify
chmod +x /usr/bin/anotify

# copy backed up configuration if path specified
test -n "${BACKUP_DIR}" && install_backup

echo -ne "Setting up cron job..."
echo "17 *  * * * root    /usr/bin/anotify" >> /etc/crontab
echo -ne "done"

# restart crond automatically on debian, else prompt the user to restart crond manually
cat "/etc/os-release" | grep -i debian && service cron restart || echo "Please restart crond manually."
