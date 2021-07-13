#!/bin/bash
  
HOST=http://sleposbuilder.suse.cz
BUILD_ID=$1
BUILD_VER=$2
PARAMS=params-run-installation-$BUILD_VER.json

STARTED_JOBS=`openqa-client --host $HOST --json-output --params $PARAMS isos post BUILD="-suma-installation-$BUILD_VER-$BUILD_ID" | jq .ids`
ID_JOB_1=`echo $STARTED_JOBS | jq '.[0]'`
ID_JOB_2=`echo $STARTED_JOBS | jq '.[1]'`

echo "################################################################################"
echo
echo "SUMA installation jobs are in progress: $ID_JOB_1 and $ID_JOB_2"
echo "See progress at: http://sleposbuilder.suse.cz/tests/$ID_JOB_1"
echo "See progress at: http://sleposbuilder.suse.cz/tests/$ID_JOB_2"
echo

job_status_1="empty"
job_status_2="empty"

while [[ "$job_status_1" != "running" ]] || [[ "$job_status_2" != "running" ]]
do
        job_status_1=`openqa-client --host $HOST --json-output jobs/$ID_JOB_1 | jq .job.state | sed -e 's/^"//' -e 's/"$//'`
        job_status_2=`openqa-client --host $HOST --json-output jobs/$ID_JOB_2 | jq .job.state | sed -e 's/^"//' -e 's/"$//'`
        echo "SUMA installation jobs are about to be started yet: $ID_JOB_1 is $job_status_1 and $ID_JOB_2 is $job_status_2..."
        sleep 5
done

while [[ "$job_status_1" = "running" ]] || [[ "$job_status_2" = "running" ]]
do
        job_status_1=`openqa-client --host $HOST --json-output jobs/$ID_JOB_1 | jq .job.state | sed -e 's/^"//' -e 's/"$//'`
        job_status_2=`openqa-client --host $HOST --json-output jobs/$ID_JOB_2 | jq .job.state | sed -e 's/^"//' -e 's/"$//'`
        echo "SUMA installation jobs are running: $ID_JOB_1 is $job_status_1 and $ID_JOB_2 is $job_status_2..."
        sleep 60
done
echo "SUMA installation jobs finished with statuses: $ID_JOB_1 is $job_status_1 and $ID_JOB_2 is $job_status_2"
echo

result_job_1=`openqa-client --host $HOST --json-output jobs/$ID_JOB_1 | jq .job.result | sed -e 's/^"//' -e 's/"$//'`
result_job_2=`openqa-client --host $HOST --json-output jobs/$ID_JOB_2 | jq .job.result | sed -e 's/^"//' -e 's/"$//'`

if [[ "$result_job_2" = "passed" ]] || [[ "$result_job_2" = "softfailed" ]]
then
        echo "SUMA installation was finished **OK** with result: $result_job_2."
        echo "Please check results at: http://sleposbuilder.suse.cz/tests/$ID_JOB_2."
        exit_code=0
else
        echo "SUMA installation **FAILED** with result: $result_job_2."
        echo "Support server test finished with result: $result_job_1."
        echo "Please check results at: http://sleposbuilder.suse.cz/tests/$ID_JOB_2."
        echo "Please check results at: http://sleposbuilder.suse.cz/tests/$ID_JOB_1."
        exit_code=1
fi

echo
echo "################################################################################"
exit $exit_code

