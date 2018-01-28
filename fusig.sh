#!/bin/bash --
#==============================================================================
#
#	FILE:  		fusig.sh
#
#       USAGE:  	fusig.sh [-u -l master develop -B -f -c -C -h]
#
#	DESCRIPTION:  	Updates Friendica installation.
#			Copy script to suitable location and make it executable.
#			Adjust the configurations below as needed.
#
# 	REQUIREMENTS: 	git and working Friendica installation via github
#
#==============================================================================
#
#	CONFIGURE SETTINGS

branch=develop # Set your branch, e.g. master or develop
friendica=/var/www/friendica/ # Set path to your Friendica installtion.
addon=/var/www/friendica/addon/ # Set path to folder called "addon".
user=www-data # Set user that has permissions for the folder called "vendor".
logfile=/var/log/fusig.log # Set log path and name.

#	END OF CONFIGURATION
#==============================================================================

if  [[ $1 = "-h" || $1 = "--help" ]]; then #help
  echo "FUSIG - 1.0 (2018)"
  echo "Usage:	fusig.sh [argument]"
  echo "Options:"
  echo
  echo "	-u		update Friendica"
  echo "	-l		update Friendica and log progress"
  echo
  echo "	Parameter, override branch setting:"
  echo
  echo "		master"
  echo "		develop"
  echo
  echo "	-B		update database structure"
  echo "	-f 		display your Friendica version"
  echo "	-c		display script configuration"
  echo "	-e		configure script"
  echo "	-h 		display this help and exit"
  echo
  echo "Examples: 'fusig.sh -u' or 'fusig.sh -u master -B'"
  exit 0
fi

if  [[ $1 = "-c" ]]; then # display configure
  echo "Script configurations"
  echo
  echo "	Branch:		$branch"
  echo "	Friendica path:	$friendica"
  echo "	Addon path:	$addon"
  echo "	Composer user:	$user"
  echo "	Logfile:	$logfile"
  echo "	Editor:		$editor"
  exit 0
fi

if  [[ $1 = "-e" ]]; then #configure
  /bin/sh -c "${EDITOR:-vi} $0"
  exit 0
fi

if  [[ $2 = "master" || $3 = "master" ]]; then # override configuration
  branch=master
fi

if  [[ $2 = "develop" || $3 = "develop" ]]; then
  branch=develop
fi

if  [[ $1 = "-B" ]]; then #update db
  cd $friendica
  echo "Updating database. This may take some time..."
  if  [[ $branch = "master" ]]; then
    /bin/sh -c "php util/db_update.php"
  else
    /bin/sh -c "scripts/dbstructure.php update"
  fi
  echo "All done."
  exit 0
fi

if  [[ $1 = "-f" ]]; then # Friendica version
  cd $friendica
  echo "You're on Friendica ${bold}$(cat VERSION) ${normal}($(git log --oneline -n1 |cut -c 1-9))."
  exit 0
fi

exec 3>&1 4>&2	# setting verbose
if  [[ $1 = "-u" ]]; then
  exec 2>&1
fi

if  [[ $1 = "-l" || $1 = "-u" && $2 = "-l" ]]; then # loging
  exec 1>>$logfile 2>&1
fi

if  ! [[ $1 = "-u" || $1 = "-l" ]]; then # neither
  echo  "Try 'fusig.sh  --help' for more information."
  exit 0
fi

cd $friendica # update via git
echo "[$(date "+%a %d %b %T")] Switching core to branch '$branch'..."
git checkout $branch | print
echo "[$(date "+%a %d %b %T")] Updating Friendica core..."
git pull
cd $addon
echo "[$(date "+%a %d %b %T")] Switching addons to branch '$branch'..."
git checkout $branch | print
echo "[$(date "+%a %d %b %T")] Updating Friendica addons..."
git pull
cd ..
echo "[$(date "+%a %d %b %T")] Installing with composer..."
su $user -s /bin/sh -c "util/composer.phar install"


if  [[ $2 = "-B" ]]; then # update db structure
  echo "[$(date "+%a %d %b %T")] Updating database. This may take some time..."
  if  [[ $branch = "master" ]]; then
    /bin/sh -c "php util/db_update.php"
  else
    /bin/sh -c "scripts/dbstructure.php update"
  fi
fi

echo "[$(date "+%a %d %b %T")] All done."
echo "You're on Friendica ${bold}$(cat VERSION) ${normal}($(git log --oneline -n1 |cut -c 1-9))."

exit 0
