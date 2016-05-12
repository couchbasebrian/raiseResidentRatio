# raiseResidentRatio
A script to raise the resident ratio

How to use:

    sudo yum install git
    git clone https://github.com/couchbasebrian/raiseResidentRatio.git
    cd raiseResidentRatio
    vi raiseResidentRatio.sh // edit the name of the bucket, by default it is "default"
    sudo ./raiseResidentRatio.sh

Sample output

    $ sudo ./raiseResidentRatio.sh 
    This is ./raiseResidentRatio.sh running at Wed Apr 27 19:07:43 UTC 2016 on node1-cb303-centos6.vagrants
    Checking dbdump...     ok
    Checking cbc...        ok
    Checking temp dir...   ok
    Checking data dir...   ok
    Checking bucket dir... ok
    Working on vbucket 0.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/0.couch.1.  Temp file: /tmp/foo/default.0.couch.1.raw.txt
    Working on vbucket 1000.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/1000.couch.1.  Temp file: /tmp/foo/default.1000.couch.1.raw.txt
    Working on vbucket 1001.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/1001.couch.1.  Temp file: /tmp/foo/default.1001.couch.1.raw.txt
    Working on vbucket 1002.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/1002.couch.1.  Temp file: /tmp/foo/default.1002.couch.1.raw.txt
    Working on vbucket 1003.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/1003.couch.1.  Temp file: /tmp/foo/default.1003.couch.1.raw.txt
    ...
    Working on vbucket 996.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/996.couch.1.  Temp file: /tmp/foo/default.996.couch.1.raw.txt
    Working on vbucket 997.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/997.couch.1.  Temp file: /tmp/foo/default.997.couch.1.raw.txt
    Working on vbucket 998.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/998.couch.1.  Temp file: /tmp/foo/default.998.couch.1.raw.txt
    Working on vbucket 999.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/999.couch.1.  Temp file: /tmp/foo/default.999.couch.1.raw.txt
    Working on vbucket 99.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/99.couch.1.  Temp file: /tmp/foo/default.99.couch.1.raw.txt
    Working on vbucket 9.couch.1 aka /opt/couchbase/var/lib/couchbase/data/default/9.couch.1.  Temp file: /tmp/foo/default.9.couch.1.raw.txt
    I looked at 1024 vbucket files in /opt/couchbase/var/lib/couchbase/data/default, with 0 errors
    Grep went okay, the raw ids count is 41
    Trimming a list of 41 ids with sed
    There are 41 trimmed ids
    I attempted 41 gets and there were 0 errors.
    Done.  Error log can be found in /tmp/foo/rrr-errors.log
