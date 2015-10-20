#!bin/sh

total_request=1000
concurrency=100
times=1

cmd_idx=1
param_count=$#		#参数个数
while [ $cmd_idx -lt $param_count ]
do
	cmd=$1
	shift 1			#删除参数 1
	case $cmd in
		-n)
			total_request=$1
			shift 1;;
		-c)
			concurrency=$1
			shift 1;;
		-t)
			times=$1
			shift 1;;
		*)
			echo "$cmd, support parameter: -n, -c, -t"
			;;
	esac
	cmd_idx=`expr $cmd_idx + 2`
done

url=$1
if [ $url = '' ]; then
	echo "the test url must be provided..."
	exit 2
fi

echo "Total Request: $total_request, Concurrency: $concurrency, URL: $url, Times: $times"

ab_dir=/usr/local/apache2/bin
ab_cmd="$ab_dir/ab -n $total_request -c $concurrency $url"

echo $ab_cmd
idx=1
rps_sum=0
max=-1
min=99999999
while [ $idx -le $times ]
do
	echo "start loop $idx"
	result=`$ab_cmd | grep 'Requests per second:'`
	# ex. result="Requests per second:    8782.41 [#/sec] (mean)"

	result=`echo $result | awk -F ' ' '{ print $4 }' | awk -F '.' '{ print $1 }'`
	# awk -F ' ' '{ print $4 }' => -F指定域分隔符为空格，$4表示第四个域 "8782.41"，$0表示所有域
	# awk -F '.' '{ print $1 }' => -F指定域分隔符为'.'，输出 "8782"

	rps_sum=`expr $result + $rps_sum`
	if [ $result -gt $max ]; then
		max=$result
	fi
	if [ $result -lt $min ]; then
		min=$result
	fi
	idx=`expr $idx + 1`
done

echo "avg rps: "`expr $rps_sum / $times`
echo "min rps: $min"
echo "max rps: $max"
	
