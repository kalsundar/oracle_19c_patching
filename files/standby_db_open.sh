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
      set long 500;
      col open_mode for a15
      col name for a15
      col database_role for a15
      col host_name for a25
      col instance_name for a15
      select d.name,d.open_mode,d.database_role,i.instance_name,i.host_name from v\$instance i, v\$database d;
      show pdbs;
      alter database recover managed standby database disconnect from session;
      select process,status,sequence# from v\$managed_standby;
EOF

echo "========================================================"

done < /tmp/orasid

rm /tmp/orasid
rm /tmp/oraenvset.sh
rm /tmp/orasid1