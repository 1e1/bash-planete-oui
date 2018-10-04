#!/bin/bash


# config ##########################
EMAIL="email-client@site.com"
PASSWORD="mot-de-passe-planete-oui"
###################################


AMOUNT=$1

if [[ ! "$1" =~ ^[0-9]+$ ]]
then 
  echo "usage: ./planete-oui.sh <valeur compteur>"
  exit 1
fi


# authenticate
PHPSESSID=`curl 'https://www.planete-oui.fr/Espace-Client/Connexion' \
  --header 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  --data-urlencode "email=$EMAIL" \
  --data-urlencode "password=$PASSWORD" \
  --data-urlencode "from_ajax=1" \
  --include --silent \
  | awk '/^Set-Cookie:/ { print $2 }' \
  | sed 's/PHPSESSID=\([^;]*\);/\1/'`


# fix Mac OS date
CMD='gdate'
if [ ! `command -v $CMD` ]
then
    CMD='date'
fi

DATE=`$CMD +%d/%m/%Y`


# summary
echo "cookie: $PHPSESSID"
echo "email:  $EMAIL"
echo "date:   $DATE"
echo "kwh:    $AMOUNT"
echo


# confirmation
read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi


# update
STATUS=`curl 'https://www.planete-oui.fr/Espace-Client/Mes-Releves' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --header "Cookie: PHPSESSID=$PHPSESSID" \
  --data-urlencode "date_releve=$DATE" \
  --data-urlencode "kwh_releve_hp=$AMOUNT" \
  --include --silent \
  | head -1`

echo $STATUS
echo "done"
