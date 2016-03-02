#! /bin/bash
# elasticsearch de-duplicator

# Manual or todays date
if [[ -n $1 ]]
then
index=$1
else
index=$(date +%Y.%m.%d)
fi


# Loop through deleting duplicates and stay in the loop
while true
do
	# This lists 50 unique serials by count. The serial.raw text is the field it's looking in. (this is the unique identifier per document)
	curl -silent -XGET 'http://10.60.0.82:9200/logstash-stats-'$index'/_search' -d '{"facets": {"terms": {"terms": {"field": "serial.raw","size": 10,"order": "count","exclude": []}}}}'|grep -o "\"term\":\"[A-Z_:\.a-z0-9-]\+\",\"count\":\([^1]\|[1-9][0-9]\)"|sed 's/\"term\":\"\([A-Z_:\.a-z0-9-]\+\)\",\"count\":\([0-9]\+\)/\1/' > /tmp/permadedupe.serials
	
	# If no serials over 1 count were found, sleep
	serialdupes=$(wc -l /tmp/permadedupe.serials|awk '{print $1}')
	if [[ $serialdupes -eq 0 ]]
	then
		echo "`date`__________No duplicate serials found in $index" |tee -a /home/logstash/dedupe.log
		todayu=$(date '+%a %b %d')
		yesterdayu=$(date --date="1 day ago" '+%a %b %d')
		sed -i 's/[ ]\+/ /g' /home/logstash/dedupe.log
		sed -i '/'"$todayu"'\|'"$yesterdayu"'/!d' /home/logstash/dedupe.log	

		sleep 900 # Runs the check for duplicates every 15 minutes
		
		# The index has to be respecified in case it rolls in to another day
		index=$(date +%Y.%m.%d)
		if [[ -n $1 ]]
		then
			index=$1
		fi
		
	else
		# For serials greater than 1 count, delete duplicates, but leave 1
		for serial in `cat /tmp/permadedupe.serials`
		do
			# Get the id's of all the duplicated serials
			curl -silent -XGET 'http://10.60.0.82:9200/logstash-stats-'$index'/_search?q=serial.raw:'$serial''|grep -o "\",\"_id\":\"[A-Za-z0-9\.:_-]\+\""|awk -F\" '{print $5}' > /tmp/permadedupelist
			# Delete the top line since you want to keep 1 copy
			sed -i '1d' /tmp/permadedupelist
			# The curl command doesn't like a hyphen unless it is escaped
			sed -i 's/^-/\\-/' /tmp/permadedupelist
			# If duplicates do exist delete them
			for line in `cat /tmp/permadedupelist`
			do
				curl -silent -XDELETE 'http://10.60.0.82:9200/logstash-stats-'$index'/_query?q=_id:'$line'' &> /dev/null
				echo "`date`__________ID:$line serial:$serial index:$index" |tee -a /home/logstash/dedupe.log
			done
		done
	fi
done