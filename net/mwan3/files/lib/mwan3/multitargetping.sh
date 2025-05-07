#!/bin/bash
debugging=false

#80.81.194.152 amazon@de-cix https://www.peeringdb.com/ix/31 80.81.195.168 akamai
#Todo use actual track_ips set by user in config
targets=( '212.83.44.10' '80.81.194.152' '80.81.195.168' '208.67.222.222' '52.113.194.132' '9.9.9.9' '8.8.8.8' '1.1.1.1' )
if [ $# != 1 ] 
then
echo "Usages: $0 <intf>"
	if $debugging
	then
	echo "Aborted due to missing arguments $1" >> /var/log/pinglog
	fi
exit 1
fi
intf=$1

        if $debugging
        then
        echo "$intf	$(date +'%F %T.%03N') Checking Interface $intf" >> /var/log/pinglog
        fi

for host in "${targets[@]}" 
do
        if $debugging
        then
        echo "$intf	$(date +'%F %T.%03N') pingging host $host"... >> /var/log/pinglog
	start_time=$(date +%s%N)
	fi

        if $debugging
        then
/lib/mwan3/timeout.sh /bin/ping -n -c 1 -W 1 -w1 -I $intf $host >> /var/log/pinglog
        else
/lib/mwan3/timeout.sh /bin/ping -n -c 1 -W 1 -w1 -I $intf $host 	
        fi

if [ $? == 0 ] 
	then
			if $debugging
			then
				# End time in nanoseconds
				end_time=$(date +%s%N)
				# Calculate duration in nanoseconds
				duration_ns=$((end_time - start_time))
				# Convert duration to milliseconds
				duration_ms=$((duration_ns / 1000000))
			echo "$intf	$(date +'%F %T.%03N') Succes pingging host $host for interface $intf took $duration_ms ms" >> /var/log/pinglog
			fi
	exit 0
fi
if $debugging
	then
		# End time in nanoseconds
		end_time=$(date +%s%N)
		# Calculate duration in nanoseconds
		duration_ns=$((end_time - start_time))
		# Convert duration to milliseconds
		duration_ms=$((duration_ns / 1000000))
	echo "$intf	$(date +'%F %T.%03N') !FAILURE! pingging host $host for interface $intf after $duration_ms ms .... trying next if any " >> /var/log/pinglog
fi
done
        if $debugging
        then
        echo "$intf	$(date +'%F %T.%03N') !!! FATAL FAILURE! pingging all hosts for interface $intf failed.... OFFLINE end " >> /var/log/pinglog
        fi


exit 1

