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
sqlplus /nolog <<EOF
      conn / as sysdba
      set feedback off
      SET SERVEROUTPUT ON SIZE 5000;
      SET LINESIZE 200;
      set pagesize 2000;
      col version for a15
      col action_time for a30
      col action for a10
      col status for a15
      col bundle_series for a10
      col description for a65
      select instance_name,host_name from v\$instance;
      select con_id,patch_id,source_version,target_version,status,action,action_time,target_build_description,description from cdb_registry_sqlpatch where action_time >=trunc(sysdate) - 5 order by con_id,action_time;
EOF

echo "========================================================"

done < /tmp/orasid

rm /tmp/orasid
rm /tmp/orasid1