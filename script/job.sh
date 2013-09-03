#!/bin/bash
#如果在开发环境执行如下命令
#RAILS_ENV=development ./job.sh stop
RAILS_ENV=${RAILS_ENV:-"production"}
if [ $# -ne 1 ]  
then
	echo "$0 [start|stop|status]"
	exit 0
fi

#如下每个命令都支持 status start 和 stop
export RAILS_ENV
echo $RAILS_ENV
./taxi_request_timeout_check.rb $1
../bin/delayed_job $1

echo "status..........................."


./taxi_request_timeout_check.rb status
../bin/delayed_job status