#!/usr/bin/env bash
#
# alf-chan
# version 1.1
#
# / i get the gist of where i am going, but not the particulars. /
#
# set -x

USAGE="$0. Make sure you ran .oraenv.\n"

while getopts 'h' OPTION
do
  case $OPTION in
  h) HELP=1
     ;;
  *) printf "Usage: ${USAGE}\n" >&2
     exit 1
     ;;
  esac
done
shift $(($OPTIND - 1))

# print help
if [[ ${HELP} = 1 ]]; then
  printf "Usage: ${USAGE}" >&2
  exit 0
fi

# env check
if [[ ${#ORACLE_BASE} == 0 ]]; then
  printf "ORACLE_BASE is not set! Manually set it via export command.\n"
  exit 1
elif [[ ${#ORACLE_SID} == 0 ]]; then
  printf "ORACLE_SID is not set! Run .oraenv.\n"
  exit 1
fi

# how many
howmany () { echo $#; }

# alert log location
if [[ -d $ORACLE_BASE/diag/rdbms ]]; then
  DIAGHOME=$(printf "
    show homes
    exit
  " | adrci | grep ${ORACLE_SID}$)
  FOUND=$(howmany ${DIAGHOME})
  if [[ ${FOUND} > 1 ]]; then
    # literally guessing at this point
    LIST=($DIAGHOME)
    CNTR=0
    NEWEST="$ORACLE_BASE/$(echo ${LIST[$CNTR]})/trace/alert_${ORACLE_SID}.log"
    CNTR=$(($CNTR + 1))
    while [ $CNTR -lt ${FOUND} ]; do
      TOCHECK="$ORACLE_BASE/$(echo ${LIST[$CNTR]})/trace/alert_${ORACLE_SID}.log"
      if [[ "$TOCHECK" -nt $NEWEST ]]; then
        NEWEST=$TOCHECK
      fi
      CNTR=$(($CNTR + 1))
    done
    FILE=$NEWEST
  else
    FILE="$ORACLE_BASE/$DIAGHOME/trace/alert_${ORACLE_SID}.log"
  fi
  if [[ -f ${FILE} ]]; then
    less ${FILE}
  elif [[ -f $ORACLE_BASE/admin/$ORACLE_SID/bdump/alert_$ORACLE_SID.log ]]; then
    less $ORACLE_BASE/admin/$ORACLE_SID/bdump/alert_$ORACLE_SID.log
  else
    printf "Cannot find alert log file! Exiting.\n"
    exit 1
  fi
elif [[ -d $ORACLE_BASE/admin ]]; then
  if [[ -f $ORACLE_BASE/admin/$ORACLE_SID/bdump/alert_$ORACLE_SID.log ]]; then
    less $ORACLE_BASE/admin/$ORACLE_SID/bdump/alert_$ORACLE_SID.log
  else
    printf "Cannot find alert log file! Exiting.\n"
    exit 1
  fi
else
  printf "Cannot find directory containing alert log! Exit.\n"
  exit 1
fi

# exit
exit 0
