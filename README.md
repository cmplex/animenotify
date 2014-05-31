animenotify
===========

script that sends notifications about new anime streaming video releases via e-mail


## Installation

* Install msmtp:
```# apt-get install msmtp ca-certificates openssl```

* Configure msmtp via ~/.msmtprc :
```
# example msmtprc configuration
account default
host smtp.gmail.com
port 587
from username@gmail.com
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
auth on
user username@gmail.com
password yourpassword
logfile ~/.msmtp
```

* Copy the script to a folder with write permissions for the user you are going to execute it as, preferably on a computer that is connected to the Internet 24/7

* Edit the script's MAILADDR variable to match your mail address:
```
MAILADDR='user@domain.com'
```

* Create a newline-seperated list of series you would like to subscribe to with their titles in all-lower-case and with dashes seperating words instead of spaces in the same folder as the script (default file name: subs.anotify)

```
death-note
folktales-from-japan
tokyo-magnitude-80
```

* Execute the script

* Receive a notification whenever a new episode of your subscribed series are uploaded
