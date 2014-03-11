awk 'BEGIN {
	while("df -hP " | getline) {
		if ( $NF == "/" ) {
			printf "Disk Usage: %d/%dGB (%s)\n", $3,$2,$5
		}
	}
	while( getline  < "/proc/loadavg" ) {
		printf "CPU Load: %.2f\n", $(NF-2)
	}
	
	while( "free -m"| getline) {
		if( $0 ~ /Mem:/) {
		printf "Memory Usage: %s/%sMB (%.2f%)\n", $3,$2,$3*100/$2
		}
	}
}'
