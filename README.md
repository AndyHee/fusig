Friendica Update Script for Installations via Github
=====================================================

A bash script for administrators of Friendica Communications Servers to update an existing installation via github. The script also allows to effortlessly switch branches, check version number, and update the server’s database structure.

### Installation

Copy [script](https://raw.githubusercontent.com/AndyHee/fusig/master/fusig.sh) to system, place in suitable location `mv fusig.sh /usr/local/bin/` and make it executable with `chmod +x fusig.sh`.

### Configuration

Run `fusig.sh -c` to see current configuration and `fusig.sh -e` to alter it if needed.

### Usage

  fusig.sh [argument]
  
    Options:
  
      -u [branch]	override branch setting
  
      -B		update database structure
      -f 		display Friendica versions
      -c		display script configuration
      -e		configure script
      -h 		display this help and exit
  
  Examples: `fusig.sh` or `fusig.sh -u master`
