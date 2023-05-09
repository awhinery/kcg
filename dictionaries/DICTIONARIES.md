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

In my on-going KCG development, I have made 2 more dictionaries, for interfaces and for sampler (router) names-to-IP numbers.

I have found that the addresses contained in flow payloads don't tend to be predictable, even when an effort is made to bind the source address in configuration. So in order to reliably map router names to IP addresses reported in the flows as "sampler" addresses, one needs a complete lists of IPs that appear on a router, and a unique ID to map them to. I chose to use Perl/SNMP to discover the lowest index numbered Loopback interface with a public IP address (if you don't filter, the process will turn up addresses on Loopbacks resembling "127.0.0.x", go figure. 

I am also in the process of working out how to use these dictionaries with dictGet() to populate variables with key/value sets, so that one can have a drop-down list that shows "Ethernet21" instead of the SNMP index "49". For Grafana variable stuff, go to the Grafana README.

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

Example dictionary source files in this directory: 

* aslist.tsv - the above-mentioned as name/country-code mapping dictionary from information fetched in April 2023.
* etype.tsv  - a list of EtherTypes in order to display names instead of EType numbers. Flow data fills the EType field with numbers that are not IANA-listed ETypes, which I have to do more work to understand. 
* iso-3166.tsv - for mapping ISO 2-letter country codes from autnums.tsv to country names. 
* protocols.csv - taken directly from [GoFlow2 repo](https://github.com/netsampler/goflow2/tree/main/compose/kcg/clickhouse). Maps L4 protocols to names.
* 

Dummy examples that have been sanitized to avoid putting a list of my router interfaces and IP addresses on GitHub. 
* exporter_ip.infotable - a list of IP addresses found on exporters, filled by Perl scripts which query the routers by SNMP.
* interfaces.infotable - a list of interfaces on exporters, filled by Perl scripts which query the routers by SNMP. This dict is used with the Clickhouse flows_raw columns "InIf" and "OutIf" which hold the SNMP interfaces Index numbers of those respective interfaces. 







  
