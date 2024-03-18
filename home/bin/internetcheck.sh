OUT=`ping -c 2 -W 5 google.com 2>&1 >/dev/null`
retVal=$?
if [ $retVal -ne 0 ]; then
    echo "`date` Internet is down"
    echo "   $OUT" 
fi

