ORA_SID=`grep "^[+]" /etc/oratab |  awk -F ":" {'print $1'}`
ORA_HOME=`grep "^[+]" /etc/oratab |  awk -F ":" {'print $2'}`
export ORACLE_SID=$ORA_SID
export ORACLE_HOME=$ORA_HOME
export PATH=$PATH:$ORACLE_HOME/bin

if [ -z "${ORACLE_SID}" ]
then
   printf "     !!!ORACLE_SID env not set!!!\n"
else

FILE1=/tmp/nodelist.txt
>$FILE1
FILE2=/tmp/nodeinslist.txt
>$FILE2

scriptdir=$1
[[ -d ${scriptdir} ]] || mkdir ${scriptdir};
for dbms in `srvctl config database`;
do
srvctl status database -d $dbms|cut -d ' ' -f 7 > $FILE1
   for instclistNode in `cat $FILE1`
   do
   >${scriptdir}/inst_svc_${instclistNode}.wil.csc.local.sh
   >${scriptdir}/svc_reloc_verify_${instclistNode}.wil.csc.local_prepatch.sh
   >${scriptdir}/svc_reloc_verify_${instclistNode}.wil.csc.local_postpatch.sh
   done
done

for dbms in `srvctl config database`;
do
srvctl status database -d $dbms > $FILE2

while read -r INSTLIST;
do
INSTNAME=`echo $INSTLIST  | awk -F " "  '{print $2}'`
INSTHOSTNAME=`echo $INSTLIST | awk -F " "  '{print $7}'`

echo "srvctl status instance -db ${dbms} -instance ${INSTNAME} -verbose" >> ${scriptdir}/inst_svc_${INSTHOSTNAME}.wil.csc.local.sh
echo "srvctl status service -db ${dbms} | grep not" >> ${scriptdir}/svc_reloc_verify_${INSTHOSTNAME}.wil.csc.local_prepatch.sh
echo "srvctl status service -db ${dbms} | grep ${INSTNAME}" >> ${scriptdir}/svc_reloc_verify_${INSTHOSTNAME}.wil.csc.local_prepatch.sh
echo "srvctl status service -db ${dbms} | grep not" >> ${scriptdir}/svc_reloc_verify_${INSTHOSTNAME}.wil.csc.local_postpatch.sh
done < $FILE2
done
fi

rm $FILE1
rm $FILE2

