# Clickhouse Dictionaries For KCG

Once you get the initial setup running, you will find that you have flow records with such things as Layer 4 protocols (UDP, TCP, ICMP) represented as numbers, rather than as familiar names. The goflow2 repo includes a "protocols" dictionary in the compose/kcg/clickhouse directory. 

Dictionaries represent relatively-static reference tables that will make it possible to show items as labels rather than as index numbers. 

Further desirable dictionaries will include:

  ..* EtherTypes
  ..* autonomous system names
  ..* ICMP type/code
  ..* well-known TCP/UDP ports
  ..* perhaps other things
  
Contrasted to dictionaries, there will also be reference tables for such things as network prefixes, etc, derived from flow data. Those metrics will be more dynamic, and more derived from received flow records. 

In this directory, I will put Perl scripts. (You will note that Perl has never been proven to cause cancer in rats, and these simple, text extraction and organizing scripts with no imported modules should be illustrative enough to show you what I did. I can type Perl without looking at instructions, and its strengths are well used here.) 

Reference files from which dictionaries are created and updated will live in your Clickhouse directory structure, canonically at: 

                /var/lib/clickhouse/user_files

at least from the container view, if you are running in Docker. 


The script makeaslist.pl takes the HTML from the page at:  

             [https://bgp.potaroo.net/cidr/autnums.html](https://bgp.potaroo.net/cidr/autnums.html)
             
and parses, reorganizes the list of ASNs into a tab-separated file. It creates 3 columns;

     as_number - the ASN
     as_name   - a free-form string telling something about the AS's use/role/assignment (usually)
     as_cc     - a 2-letter ISO country code associated with the ASN, because it's too potentially-useful to discard. 

makeaslist.pl is intended to be run as a cron job, once a week, to get the potaroo page and funnel the info into the dictionary file.

something like:
    
    0 0 * * 0 wget -O - https://bgp.potaroo.net/cidr/autnums.html 2> /dev/null | ./makeaslist.pl 2> /dev/null > /path/to/chstuff/user_files/aslist.tsv

(the above line inserted into your crontab file)





  
