ORA_SID=`grep "^[+]" /etc/oratab |  awk -F ":" {'print $1'}`
ORA_HOME=`grep "^[+]" /etc/oratab |  awk -F ":" {'print $2'}`
export ORACLE_SID=$ORA_SID
export ORACLE_HOME=$ORA_HOME
export PATH=$PATH:$ORACLE_HOME/bin

if [ -z "${ORACLE_SID}" ]
then
   printf "     !!!ORACLE_SID env not set!!!\n"
else

INSTHOSTNAME=`echo $HOSTNAME`

scriptdir=$1
for dbms in `srvctl config database`;
do
   >${scriptdir}/db_stop_${INSTHOSTNAME}_prepatch.sh
   >${scriptdir}/db_start_${INSTHOSTNAME}_postpatch.sh
   >${scriptdir}/db_svc_status_${INSTHOSTNAME}.sh
done

for dbms in `srvctl config database`;
do
echo "srvctl stop database -db ${dbms}" >> ${scriptdir}/db_stop_${INSTHOSTNAME}_prepatch.sh
echo "srvctl start database -db ${dbms}" >> ${scriptdir}/db_start_${INSTHOSTNAME}_postpatch.sh
echo "srvctl status service -db ${dbms}" >> ${scriptdir}/db_svc_status_${INSTHOSTNAME}.sh
done
fi