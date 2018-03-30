#!/bin/bash --
#==============================================================================
#
#	FILE:  		fusig.sh
#
#       USAGE:  	fusig.sh [-u [branch] -B -f -c -e -h]
#
#	DESCRIPTION:  	Updates Friendica installation.
#			Copy script to suitable location and make it executable.
#			Adjust the configurations below accordingly.
#			Call script manually or automatically via a cron job.
#			E.g. 00 04 * * * /usr/local/bin/fusig.sh
#
# 	REQUIREMENTS: 	git and working Friendica installation via github
#
#==============================================================================
#
#	CONFIGURE SETTINGS

branch=develop # Set your branch, e.g. master or develop
FPATH=/var/www/friendica # Set path to your Friendica installation. Ensure no trailing slash.
CUSER=www-data # Set user that has permissions for the folder called "vendor".
FLOG=/var/www/friendica/logs/friendica.log
LOCKFILE=/tmp/fusig.lock # Alter this if you don't have permission for "/tmp".

#	END OF CONFIGURATION
#==============================================================================

if  [[ $1 = "-h" || $1 = "--help" ]]; then #help
  echo "Usage:	fusig.sh [argument]"
  echo "Options:"
  echo
  echo "	-u [branch]	override branch setting"
  echo
  echo "	-B		update database structure"
  echo "	-f 		display Friendica versions"
  echo "	-c		display script configuration"
  echo "	-e		configure script"
  echo "	-h 		display this help and exit"
  echo
  echo "Examples: 'fusig.sh ' or 'fusig.sh -u master"
  exit 0
fi

if  [[ $1 = "-c" ]]; then # display configure
  echo "Script configurations"
  echo
  echo "	Branch:		$branch"
  echo "	Friendica path:	$FPATH"
  echo "	Composer user:	$CUSER"
  echo "	Lockfile:	$LOCKFILE"
  exit 0
fi

if  [[ $1 = "-e" ]]; then #configure
  /bin/sh -c "${EDITOR:-vi} $0"
  exit 0
fi

if  [[ $1 = "-f" ]]; then # Friendica version
  cd $FPATH
  echo "You're currently on Friendica branch..."
  echo "$(git branch)"
  echo "	Version number:  ${bold}$(cat VERSION) ${normal}($(git log --oneline -n1 |cut -c 1-9))."
  echo
  echo "Checking available versions on github repository..."
  echo
  if command -v curl >/dev/null 2>&1 ; then
    echo "Friendica branch 'master': $(curl -# https://raw.githubusercontent.com/friendica/friendica/master/VERSION)"
    echo
    echo "Friendica branch 'develop': $(curl -# https://raw.githubusercontent.com/friendica/friendica/develop/VERSION)"

  else
    if command -v wget >/dev/null 2>&1 ; then
      echo "Friendica branch 'master':	$(wget -O - -o /dev/null http://raw.githubusercontent.com/friendica/friendica/master/VERSION --show-progress)"
      echo
      echo "Friendica branch 'develop':	$(wget -O - -o /dev/null http://raw.githubusercontent.com/friendica/friendica/develop/VERSION --show-progress)"
    else
      echo "[Error] 'curl' or 'wget' not found on your system."
    fi
  fi
  exit 0
fi

if [[ $1 = "-u" ]]; then
  if  [[ $1 = "-u" && $2 = "-"* ]]; then # Check before override configuration
    echo  "Try 'fusig.sh  --help' for more information."
    exit 0
  else
    branch="$2"
  fi
fi

(
  flock -e 200 #Set lock

  cd $FPATH

  if  [[ $1 = "-B" ]]; then # update db structure
    echo "Updating database. This may take some time..."
    if  [[ $branch = "master" ]]; then
      /bin/sh -c "scripts/dbstructure.php update"
    else
      /bin/sh -c "bin/console dbstructure update"
    fi
    exit 0
  fi

  echo "Switching core to branch '$branch'..."
  git checkout $branch | print
  echo "Updating Friendica core..."
  git pull
  cd $FPATH/addon
  echo "Switching addons to branch '$branch'..."
  git checkout $branch | print
  echo "Updating Friendica addons..."
  git pull
  cd ..
  echo "Installing with composer..."
  if  [[ $branch = "master" ]]; then
    su $CUSER -s /bin/sh -c "util/composer.phar install"
    echo "Git pull and util/composer.phar install successful at $(date)." >>$FLOG 2>&1
  else
    su $CUSER -s /bin/sh -c "bin/composer.phar install"
    echo "Git pull and bin/composer.phar install successful at $(date)." >>$FLOG 2>&1
  fi

  echo "You're on Friendica ${bold}$(cat VERSION) ${normal}($(git log --oneline -n1 |cut -c 1-9))." >>$FLOG 2>&1

) 200>${LOCKFILE}

exit 0
