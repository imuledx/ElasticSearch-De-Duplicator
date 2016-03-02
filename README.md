# ElasticSearch-De-Duplicator
Sometimes I have data that gets duplicated and I want to delete it. This deletes documents down to one unique version based on a specific field.

This mainly requires that each document have something unique about it that can be compared and searched for in other documents. In my case, each document entry has a specific serial number tied to it that corresponds to the date entry and server information of what's being recorded. This means I can search that unique identifier, find duplicates, and delete those duplicates based on their ElastiCsearch ID. All done though a bash script.

-You can run this as a single instance and it will just use the current days format for the index name (I use logstash with date names).

-You can run this as a single instance and specify the date for the index to check.

-You can run this as a job in the background and it will occasionally recheck your indexes for duplicates.



This was done kind of on the fly. It works, but it isn't pretty. Maybe I'll make it better one day but for now it does what I need it to. If you need to use it, you'll need to change some paths and likely names as well. This is just to give an idea of a way to de-duplicate.
