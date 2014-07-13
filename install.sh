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

configure_msmtp () {
  acctype=${1}; mailaddr=${2}

  read -p "Please enter your gmail account password: " mailpass
  echo "account default
host smtp.gmail.com
port 587
from ${mailaddr}
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
auth on
user ${mailaddr}
password ${mailpass}
logfile ~/.msmtp" > ~/.msmtprc

  test ${acctype} == "gmail" && echo "An msmtp configuration was written to /root/.msmtprc. Please check if everything looks fine."

  test ${acctype} != "gmail" && echo "An example configuration was written to /root/.msmtprc. Please modify it to work with your mail account."
}

configure_msmtp_generic () {
  mailaddr=${1}

  read -p "Please enter your mail account password: " mailpass
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

echo "Commencing msmtp configuration. Please note that your password will be stored in plain text."
read -p "Please enter your mail address: " mailaddr
if echo ${mailaddr} | grep -Pi '(gmail)|(googlemail)'; then
  configure_msmtp_gmail "gmail" ${mailaddr}
else
  configure_msmtp_generic "generic" ${mailaddr}
fi

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
