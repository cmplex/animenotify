animenotify
===========

script that sends notifications about new anime streaming video releases via e-mail


## Installation

* Edit anotify.sh and change the MAILADDR variable to match your mail address:

```
MAILADDR='user@domain.com'
```

* Run the installation script, preferably on a computer that is connected to the Internet 24/7:

```# ./install.sh```

* Edit the anotify configuration file to contain a newline-seperated list of series you would like to subscribe to with their titles in all-lower-case and with dashes seperating words instead of spaces.

```
default path: /etc/anotify/anotify.conf

death-note
folktales-from-japan
tokyo-magnitude-80
```

* Receive a notification whenever a new episode of your subscribed series are uploaded
