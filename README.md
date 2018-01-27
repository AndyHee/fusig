Friendica Update Script for Installations via Github
=====================================================

A bash script for administrators of Friendica Communications Servers to update an existing installation via github. The script also allows to effortlessly switch branches, check version number, and update the server’s database structure.

###Installation

Copy script to system (e.g. /usr/local/bin/) and make it executable with [code]chmod +x fusig.sh[/code].

###Configuration

Run [code]fusig.sh -c[/code] to see current configuration and [code]fusig.sh -e[/code] to alter it accordingly.

####Usage

  fusig.sh [argument]"
  Options:"
      -u		update Friendica"
      -l		update Friendica and log progress"
  
          Parameter, override branch setting:"
            master
            develop
  
      -B		update database structure"
      -f 		display your Friendica version"
      -c		display script configuration"
      -e		configure script"
      -h 		display this help and exit"
  
  Examples: 'fusig.sh -u' or 'fusig.sh -u master -B'