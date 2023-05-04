# kcg
Kafka, Clickhouse, GoFlow (name follows convention from directory name in netsampler/goflow2/compose)

This is a continuation of work performed at 
  
  cloudflare/goflow
  and
  netsampler/goflow2
  
  In this first iteration, it will be advice on what was necessary to make the Docker Compose demos work in the above GitHub repos. 
  
  Further, this repo will progress toward making a useful tool from the KCG signal chain described in the upstream repos. 
  
  I chose not to fork because that would result in mixed noise from multiple sources, which would be more confusing, so as of the creation of this repo, I expect you to use resources from those repos to proceed.
  
  The code in this repo will have at least these threads:
       
       0 - why bother getting KCG running
       1 - how to make the KCG models in netsampler/goflow2 and clouflare/goflow work
       2 - how to promote stability in the goflow daemon
       3 - how to work with IP addresses in Clickhouse
       4 - how to change the proto-buffer definitions and the DB create.sh to fit the fields you want. 
       5 - how to create and use Clickhouse dictionaries to show names of ASNs, protocols, ethertypes
       6 - enrichment, or adding useful information to records in the pipeline before they're sent to Clickhouse
       7 - how to import files from nfdump archives (as in those created for NFSen)
       10 - what "flows" (from SFlow/Netflow9/IPFix) are, how they represent traffic, and how flows from different sources differ
       
 As of March 2023, I have 2 instances of the KCG pipeline running. 
 
 ...One at the University of Hawaii, in an entirely test-mode status, which is accepting a mixture of SFlow and NetFlow (v9 and IPFix) exports from Arista, Juniper and Cisco routers. This is running in Docker on a rack server with 32 cores, 128 GB of RAM and 10 Gbit/sec Ethernet connectivity.
 
 ... One at home, accepting flows from my OpenWrt router, running [softflowd](https://github.com/irino/softflowd), on a Zotac ZBox with 4 cores, 8 GB RAM, 120 GB system drive and a 2TB USB drive for data. 
 
It should probably be said that a primary vision for this effort is to emulate the functionality of NFSen (https://nfsen.sourceforge.net/) , with a better backend, better frontend, and better everything else. What NFSen is (was) a really good flow data exploration interface, but it queried a low-performance, un-indexed data layer, which could take a really long time to perform broad inquiries.
