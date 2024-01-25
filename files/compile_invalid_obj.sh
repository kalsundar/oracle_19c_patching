grep "^[a-z,A-Z]" /etc/oratab > /tmp/orasid1
grep -v "agent" /tmp/orasid1 > /tmp/orasid

while read line;
do
SID=`echo $line |  awk -F ":" {'print $1'}`
HOME=`echo $line |  awk -F ":" {'print $2'}`

echo "export ORACLE_SID=$SID" > /tmp/oraenvset.sh
echo "export ORACLE_HOME=$HOME" >> /tmp/oraenvset.sh
echo "PATH=$HOME/bin:$PATH"  >> /tmp/oraenvset.sh

chmod 700 /tmp/oraenvset.sh
. /tmp/oraenvset.sh

echo "ORACLE_SID is $ORACLE_SID"
echo "ORACLE_HOME is $ORACLE_HOME"

echo "========================================================"

$ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 5 -e -b utlrp -d $ORACLE_HOME/rdbms/admin utlrp.sql

echo "========================================================"

done < /tmp/orasid

rm /tmp/orasid
rm /tmp/orasid1