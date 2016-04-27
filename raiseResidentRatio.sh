#!/bin/bash
#
# Script to raise the resident ratio
# Brian Williams
# April 27, 2016
#
# This script, which needs to be run on each Couchbase node, will
# go through the data directory, dump each vBucket file, get a list of
# keys, and then do a get on each one.
#
# Location of executables
CBEXE=/opt/couchbase/bin
#
# Executable for dumping the data files
DBDUMP=$CBEXE/couch_dbdump
#
# Couchbase client location
CBC=/usr/bin/cbc
#
# Location of data
DATADIR=/opt/couchbase/var/lib/couchbase/data
#
# Name of the bucket you are interested in
BUCKETNAME=default
#
# Bucket's directory
BUCKETDIR=$DATADIR/$BUCKETNAME
#
# Temporary directory
TEMPDIR=/tmp/foo
ERRORLOG=$TEMPDIR/rrr-errors.log
#
# Announce myself
echo "This is $0 running at `date` on `hostname`"
#
# Check to see if the executables exist
if [[ -x "$DBDUMP" ]]
then
  echo "Checking dbdump...     ok"
else
  echo "Problem with dbdump: $DBDUMP"
fi
#
if [[ -x "$CBC" ]]
then
  echo "Checking cbc...        ok"
else
  echo "Problem with cbc: $CBC"
  exit 1
fi
#
# Check to see if temp dir exists and is writable
if [[ -w "$TEMPDIR" ]]
then
  echo "Checking temp dir...   ok"
else
  echo "Problem with temp dir: $TEMPDIR"
  exit 1
fi
#
# Check to see if the data dir exists and is readable
if [[ -r "$DATADIR" ]]
then
  echo "Checking data dir...   ok"
else
  echo "Problem with data dir: $DATADIR"
  exit 1
fi
#
# Check to see if the bucket dir exists and is readable
if [[ -r "$BUCKETDIR" ]]
then
  echo "Checking bucket dir... ok"
else
  echo "Problem with bucket dir: $BUCKETDIR"
  exit 1
fi
#
# --- All prerequisites met - proceed ---
#
# Step 1.  Make a list of the keys
VBCOUNTER=0
ERRCOUNTER=0
for eachVbucket in `ls $BUCKETDIR/[0-9]*.couch.*`
do
  BASENAME=`basename $eachVbucket`
  TMPDBD=$TEMPDIR/$BUCKETNAME.$BASENAME.raw.txt
  echo "Working on vbucket $BASENAME aka $eachVbucket.  Temp file: $TMPDBD"
  VBCOUNTER=$((VBCOUNTER+1))
  # Variable contains the full path to the vbucket
  $DBDUMP $eachVbucket > $TMPDBD 2>>$ERRORLOG
  DBDRESULT=$?
  if [ $DBDRESULT -eq 0 ]
  then
    echo "It went okay" >> $ERRORLOG
  else
    ERRCOUNTER=$((ERRCOUNTER+1))
  fi 
done
echo "I looked at $VBCOUNTER vbucket files in $BUCKETDIR, with $ERRCOUNTER errors"
# From the raw files, get a list of IDs
#
grep -h ^"     id" $TEMPDIR/*.raw.txt > $TEMPDIR/all-ids.txt
GREPRESULT=$?
if [ $DBDRESULT -eq 0 ]
then
  RAWCOUNT=`wc -l $TEMPDIR/all-ids.txt | cut -f1 -d' '`
  echo "Grep went okay, the raw ids count is $RAWCOUNT"
  # Get just the ids
  cut -f2 -d":" $TEMPDIR/all-ids.txt > $TEMPDIR/only-ids.txt
  CUTRESULT=$?
  if [[ -r $TEMPDIR/only-ids.txt ]]
  then
    IDCOUNT=`wc -l $TEMPDIR/only-ids.txt | cut -f1 -d' '`
    echo "Trimming a list of $IDCOUNT ids with sed"
    sed 's/^ *//g' < $TEMPDIR/only-ids.txt > $TEMPDIR/trimmed-ids.txt 
    TRMIDCOUNT=`wc -l $TEMPDIR/trimmed-ids.txt | cut -f1 -d' '`
    echo "There are $TRMIDCOUNT trimmed ids"
    # cat $TEMPDIR/trimmed-ids.txt
  else
    echo "There was a problem.  Exiting."
    exit 1
  fi
else
  echo "Problem with the grep"
  exit 1
fi 
#
# Step 2.  Get each key
GETCOUNTER=0
GETERRCOUNTER=0
if [ -r $TEMPDIR/trimmed-ids.txt ]
then
  for eachKey in `cat $TEMPDIR/trimmed-ids.txt` 
  do
    $CBC get -U "couchbase://localhost/$BUCKETNAME" $eachKey >> $ERRORLOG 2>&1
    CBCRESULT=$?
    if [ $CBCRESULT -eq 0 ]
    then
      echo "Get of $eachKey went okay" >> $ERRORLOG
    else
      echo "Get of $eachKey resulted in error code $CBCRESULT from $CBC" >> $ERRORLOG
      GETERRCOUNTER=$((ERRCOUNTER+1))
    fi 
    GETCOUNTER=$((GETCOUNTER+1))
  done
  echo "I attempted $GETCOUNTER gets and there were $GETERRCOUNTER errors."
else
  echo "Problem with the trimmed id list $TEMPDIR/trimmed-ids.txt"
  ls -l $TEMPDIR/trimmed-ids.txt
fi
#
# Final Step:  Report results
echo "Done.  Error log can be found in $ERRORLOG"
#
# EOF 
