grep "^[a-z,A-Z]" /etc/oratab > /tmp/orasid1
grep -v "agent" /tmp/orasid1 > /tmp/orasid

while read line;
do
SID=`echo $line |  awk -F ":" {'print $1'}`
HOME=`echo $line |  awk -F ":" {'print $2'}`

echo "export ORACLE_SID=$SID" > /tmp/oraenvset.sh
echo "export ORACLE_HOME=$HOME" >> /tmp/oraenvset.sh
echo "export PATH=$HOME/bin:$PATH"  >> /tmp/oraenvset.sh

chmod 700 /tmp/oraenvset.sh
. /tmp/oraenvset.sh

echo "ORACLE_SID is $ORACLE_SID"
echo "ORACLE_HOME is $ORACLE_HOME"

echo "========================================================"
sqlplus /nolog <<EOF
      conn / as sysdba
      startup upgrade
      set feedback off
      SET SERVEROUTPUT ON SIZE 5000;
      SET LINESIZE 200;
      set pagesize 2000;
      set long 500;
      col open_mode for a15
      col name for a25
      select instance_name,host_name from v\$instance;
      alter pluggable database all open upgrade;
      select con_id,name,open_mode from v\$pdbs order by con_id;
EOF

echo "========================================================"

done < /tmp/orasid

rm /tmp/orasid
rm /tmp/orasid1
rm /tmp/oraenvset.sh