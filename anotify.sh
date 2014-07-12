#!/bin/bash
# anotify.sh
# @author Cedric Haase

LOGFILE='anotify.log'
SUBSCRIPTION_LIST='subs.anotify'
SENT_LINKS='sent.anotify'
SENT_RAW_LINKS='sentraw.anotify'
MAILADDR='user@domain.com'

CLEAN_INTERVAL='3d'
CHECK_INTERVAL='1h'


# send a notification on a recently uploaded series
function send_notification () {

  # define argument variables
  serie=`echo $1 | sed 's:-: :g'`
  link=$2

  episode_header=`curl -s $link | grep -Po '(?<=<h1>)(\w+\s+)+\d+'`

  # check if link is raw
  raw_imgtag=`curl -s $link | grep -P 'raw\d?\.png' | tr -d '\n'`
  # link is raw
  if test -n "$raw_imgtag"; then

    # check if raw link has been sent before
    if test -e "$SENT_RAW_LINKS"; then
      sent_links=`cat "$SENT_RAW_LINKS"`
      for sent_link in $sent_links; do
        if test $sent_link = $link; then
          echo `date`': found RAW link for '$serie', but link has already been sent' >> $LOGFILE
          return 1
        fi
      done
    fi

    echo `date`': found RAW link for '$serie', sending notification' >> $LOGFILE

    # write mail text into temporary file
    echo 'To: '$MAILADDR'
From:anotify@pi.home
Subject: anotify: '$episode_header' RAW
'$episode_header' RAW has been uploaded!
You will be notified again when a subbed version is available!

Click here to watch it:
'$link'' | msmtp -t

    # remember RAW link has been sent before
    echo $link >> "$SENT_RAW_LINKS"


  # link is not raw
  else
    # check if link has been sent before
    if test -e "$SENT_LINKS"; then
      sent_links=`cat "$SENT_LINKS"`
      for sent_link in $sent_links; do
        if test $sent_link = $link; then
          echo `date`': found link for '$serie', but link has already been sent' >> $LOGFILE
          return 1
        fi
      done
    fi

    echo `date`': found link for '$serie', sending notification' >> $LOGFILE


    # write mail text into temporary file
    echo 'To: '$MAILADDR'
From:anotify@pi.home
Subject: anotify: '$episode_header' English Sub
'$episode_header' has been uploaded!

Click here to watch it:
'$link'' | msmtp -t

    # remember link has been sent before
    echo $link >> "$SENT_LINKS"
  fi

}


function check_subs () {
  episode_list=`curl -s http://www.gogoanime.com | grep Episode`
  subs=`cat ${SUBSCRIPTION_LIST}`


  echo `date`': checking for subs' >> $LOGFILE

  for episode_tag in ${episode_list}; do
    link=`echo ${episode_tag} | grep -Po '(?<=href\=\")\S+(?=\")'`

    for serie in ${subs}; do
      match=`echo ${link} | perl -ne 'print /'${serie}'/g'`
      if test ! -z "$match"; then
        (send_notification "$serie" $link) &
      fi
    done

  done
}


function clean () {
  echo `date`': clearing sent links' >> $LOGFILE
  if test -e "$SENT_LINKS"; then
    rm "$SENT_LINKS"
    rm "$SENT_RAW_LINKS"
  fi
}

function clean_loop () {
  while true; do
    clean
    sleep $CLEAN_INTERVAL
  done
}

function check_loop () {
  while true; do
    check_subs
    sleep $CHECK_INTERVAL
  done
}


function start_in_background () {

  # clear link cache on regular intervals
  ( clean_loop )&

  sleep 1

  # check for new subs on regular intervals
  ( check_loop )&
}


start_in_background
