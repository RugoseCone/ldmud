#! /bin/sh

echo >&2
echo "Running test for signal handling:" >&2
echo "---------------------------------" >&2

set -e
ulimit -c 0
OPTIONS=""

rm -f ${TEST_LOGFILE}.fail ${TEST_OUTPUTFILE}

for s in HUP INT USR1 USR2 TERM; do
    for action in DCS_DEFAULT DCS_SHUTDOWN; do
        ( ${DRIVER} ${DRIVER_DEFAULTS} -m. -Mgeneric/signal -DSIGNAL=SIG$s -DSIGNAL_CONF=DC_SIGACTION_SIG$s -DSIGNAL_ACTION=$action ${PORT}\
            --debug-file ${TEST_LOGFILE} --pidfile ${TEST_LOGFILE}.pid || touch  ${TEST_LOGFILE}.fail ) | while read line; do
        echo "Testing SIG$s with $action" >&2
                echo $line >> "${TEST_OUTPUTFILE}"

                if [ -z "${line##*LDMud ready*}" ]; then
                    kill -s $s `cat ${TEST_LOGFILE}.pid`
                fi
        done
        if [ -e ${TEST_LOGFILE}.fail ]; then exit 1; fi
    done
done

echo "Success." >&2
