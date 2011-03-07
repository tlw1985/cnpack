#!/bin/sh

case "$1" in 

  start) 
	/usr/bin/cvstrac server 8008 /var/cvshome/cnpack &
	;;

  stop) 
  	killall cvstrac
	;;

  restart) 
  $0 stop 
  $0 start 
  ;;
  
  *) 
  echo "Usage: cvstrac.sh {start|stop|restart}" 
  ;; 
  
esac 

exit 0 
