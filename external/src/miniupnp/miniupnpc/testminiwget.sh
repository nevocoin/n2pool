#!/bin/sh
# $Id: testminiwget.sh,v 1.18 2020/05/29 21:14:22 nanard Exp $
# vim: tabstop=4 shiftwidth=4 noexpandtab
# project miniupnp : http://miniupnp.free.fr/
#                    or https://miniupnp.tuxfamily.org/
# (c) 2011-2022 Thomas Bernard
#
# test program for miniwget.c
# is usually invoked by "make check"
#
# This test program :
#  1 - launches a local HTTP server (minihttptestserver)
#  2 - uses testminiwget to retrieve data from this server
#  3 - compares served and received data
#  4 - kills the local HTTP server and exits
#
# The script was tested and works with ksh, bash
# it should now also run with dash

TMPD=`mktemp -d -t miniwgetXXXXXXXXXX`
if [ -z "$TESTSERVER" ] ; then
  TESTSERVER=./build/minihttptestserver
fi
if [ -z "$TESTMINIWGET" ] ; then
  TESTMINIWGET=./build/testminiwget
fi
HTTPSERVEROUT="${TMPD}/httpserverout"
EXPECTEDFILE="${TMPD}/expectedfile"
DOWNLOADEDFILE="${TMPD}/downloadedfile"
PORT=
RET=0
IPCONFIG=$(which ifconfig)
IP=$(which ip)
if [ "$IP" ] ; then
	if ! $IP addr | grep inet6 ; then
		HAVE_IPV6=no
	fi
else
	if [ -z "$IPCONFIG" ] ; then
		IPCONFIG="/sbin/ifconfig"
	fi

	if ! $IPCONFIG -a | grep inet6 ; then
		HAVE_IPV6=no
	fi
fi

case "$HAVE_IPV6" in
    n|no|0)
        ADDR=localhost
        SERVERARGS=""
        ;;
    *)
        ADDR="[::1]"
        SERVERARGS="-6"
        ;;

esac

if [ ! -x "$TESTSERVER" ] || [ ! -x "$TESTMINIWGET" ] ; then
	echo "Please build $TESTSERVER and $TESTMINIWGET"
	#make minihttptestserver
	#make testminiwget
	exit 1
fi

# launching the test HTTP server
$TESTSERVER $SERVERARGS -e $EXPECTEDFILE > $HTTPSERVEROUT &
SERVERPID=$!
while [ -z "$PORT" ]; do
	sleep 1
	PORT=`cat $HTTPSERVEROUT | sed 's/Listening on port \([0-9]*\)/\1/' `
done
if [ "$PORT" = "*** ERROR ***" ]; then
	echo "HTTP test server error"
	echo "Network config :"
	$IPCONFIG -a
	exit 2
fi
echo "Test HTTP server is listening on $PORT"

URL1="http://$ADDR:$PORT/index.html"
URL2="http://$ADDR:$PORT/chunked"
URL3="http://$ADDR:$PORT/addcrap"
URL4="http://$ADDR:$PORT/malformed"

echo "standard test ..."
$TESTMINIWGET $URL1 "${DOWNLOADEDFILE}.1"
if cmp $EXPECTEDFILE "${DOWNLOADEDFILE}.1" ; then
	echo "ok"
else
	echo "standard test FAILED"
	RET=1
fi

echo "chunked transfert encoding test ..."
$TESTMINIWGET $URL2 "${DOWNLOADEDFILE}.2"
if cmp $EXPECTEDFILE "${DOWNLOADEDFILE}.2" ; then
	echo "ok"
else
	echo "chunked transfert encoding test FAILED"
	RET=1
fi

echo "response too long test ..."
$TESTMINIWGET $URL3 "${DOWNLOADEDFILE}.3"
if cmp $EXPECTEDFILE "${DOWNLOADEDFILE}.3" ; then
	echo "ok"
else
	echo "response too long test FAILED"
	RET=1
fi

echo "malformed response test ..."
$TESTMINIWGET $URL4 "${DOWNLOADEDFILE}.4"

# kill the test HTTP server
kill $SERVERPID
wait $SERVERPID

# remove temporary files (for success cases)
if [ $RET -eq 0 ]; then
	rm -f "${DOWNLOADEDFILE}.1"
	rm -f "${DOWNLOADEDFILE}.2"
	rm -f "${DOWNLOADEDFILE}.3"
	rm -f $EXPECTEDFILE $HTTPSERVEROUT
	rmdir ${TMPD}
else
	echo "at least one of the test FAILED"
	echo "directory ${TMPD} is left intact"
fi
exit $RET

