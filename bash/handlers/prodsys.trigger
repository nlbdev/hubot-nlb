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
    
elif [[ "$BOOK_ID" = "" ]] && [[ "$STEP_ID" =~ ^(TEST)?[0-9]+$ ]]; then
    BOOK_ID="$STEP_ID"
    STEP_ID="master/EPUB"
    
if [ "$STEP_ID" = "" ]; then
    echo "Skjønner ikke kommandoen." >> $LOG 2>&1
    echo "" >> $LOG 2>&1
    echo "For å starte [boknummer] i [steg]:" >> $LOG 2>&1
    echo "prodsys trigger [steg] [boknummer]" >> $LOG 2>&1
    echo "" >> $LOG 2>&1
    echo "For å starte [boknummer] i alle steg som kommer ut fra [mappe]:" >> $LOG 2>&1
    echo "prodsys trigger [mappe] [boknummer]" >> $LOG 2>&1
    echo "" >> $LOG 2>&1
    echo "For å starte [boknummer] i alle steg som kommer ut fra mappen 'master/EPUB':" >> $LOG 2>&1
    echo "prodsys trigger [boknummer]" >> $LOG 2>&1
    
elif [ "$BOOK_ID" = "" ]; then
    echo "Boknummer må være gitt: 'prodsys $STEP_ID [boknummer]'" >> $LOG 2>&1
    
elif [ -d "$BOOK_ARCHIVE_TRIGGER_DIR/pipelines/$STEP_ID" ]; then
    echo "Trigger boken '$BOOK_ID' for steget '$STEP_ID'..." >> $LOG 2>&1
    touch "$BOOK_ARCHIVE_TRIGGER_DIR/pipelines/$STEP_ID/$BOOK_ID" >> $LOG 2>&1
    echo "Boknummer '$BOOK_ID' for '$STEP_ID' ble trigget." >> $LOG 2>&1
    
elif [ -d "$BOOK_ARCHIVE_TRIGGER_DIR/dirs/$STEP_ID" ]; then
    echo "Trigger boken '$BOOK_ID' for mappen '$STEP_ID'..." >> $LOG 2>&1
    touch "$BOOK_ARCHIVE_TRIGGER_DIR/dirs/$STEP_ID/$BOOK_ID" >> $LOG 2>&1
    echo "Boknummer '$BOOK_ID' for '$STEP_ID' ble trigget." >> $LOG 2>&1
    
else
    echo "Finner ikke et steg eller en mappe med navnet '$STEP_ID'. For å se tilgjengelige steg og mapper, bruk 'prodsys list'" >> $LOG 2>&1
fi

exit 0
