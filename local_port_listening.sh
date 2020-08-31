netstat -plna | grep -i listen | awk '{print $4}' | cut -d ':' -f2 | grep [0-9] | sort -n
