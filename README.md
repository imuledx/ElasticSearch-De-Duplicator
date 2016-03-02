# ElasticSearch-De-Duplicator
Sometimes I have data that gets duplicated and I want to delete it. This deletes documents down to one unique version based on a specific field.

This mainly requires that each document have something unique about it that can be compared and searched for in other documents. In my case, each document entry has a specific serial number tied to it that corresponds to the date entry and server information of what's being recorded. This means I can search that unique identifier, find duplicates, and delete those duplicates based on their ElastiCsearch ID. All done though a bash script.
