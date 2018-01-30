#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

LOG="`tempfile`"
function finish {
    LOG2="`tempfile`"
    head -n 1 $LOG >> $LOG2
    echo >> $LOG2
    tail -n +2 $LOG >> $LOG2
    cat $LOG2
    rm $LOG $LOG2
}
trap finish EXIT

. ~/config/set-env.sh

STEP_ID="$1"
BOOK_ID="$2"

if [ "$BOOK_ARCHIVE_TRIGGER_DIR" = "" ]; then
    echo "TRIGGER_DIR for bokarkiv er ikke spesifisert; kan ikke trigge steg." >> $LOG 2>&1
    
elif [ "$STEP_ID" = "" ]; then
    echo "Steg må spesifiseres: 'prodsys [steg] [boknummer]'" >> $LOG 2>&1
    
elif [ ! -d "$BOOK_ARCHIVE_TRIGGER_DIR/$STEP_ID" ]; then
    echo "Steget finnes ikke: '$STEP_ID'. For å se tilgjengelige steg, bruk 'prodsys list'" >> $LOG 2>&1
    
elif [ "$BOOK_ID" = "" ]; then
    echo "Boknummer må være gitt: 'prodsys $STEP_ID [boknummer]'" >> $LOG 2>&1
    
else
    echo "Trigger boknummer '$BOOK_ID' for '$STEP_ID'..." >> $LOG 2>&1
    touch "$BOOK_ARCHIVE_TRIGGER_DIR/$STEP_ID/$BOOK_ID" >> $LOG 2>&1
    echo "Boknummer '$BOOK_ID' for '$STEP_ID' ble trigget." >> $LOG 2>&1
fi

exit 0
