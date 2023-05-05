# Notes About Flow Archives And The Nature Of NetFlow And SFlow Data

## A Chronicle of Flow Viz Solutions
At the University Of Hawaii, we've always had a mixture of devices which export either Netflow (v9 or IPFIX), or SFlow data. Our initial means of archiving and looking at Netflow data was [flow-tools](https://web.archive.org/web/20140828225935/http://www.splintered.net/sw/flow-tools), which was a dominant solution in the early 2000's. 

For about 10 years starting in 2012, we used [NFSen](https://sourceforge.net/projects/nfsen/), which uses [nfdump's nfcapd/sfcapd](https://github.com/phaag/nfdump) to collect flows into a file system directory tree structure, providing a Perl/PHP web front-end to run nfdump in the background to display various extracts from flow data. Those of us who used the NFSen interface developed an affinity for it as a data exploration interface. Having the ability to answer pretty much any question that came to mind was incredibly useful. It was a satisfying, incomplete, front-end on a very inefficient backend. We are still collecting flows with nfcapd/sfcapd. Although SFlow devices do export information about layer 2 activities, sfcapd essentially discards that information and stores SFlow in a layer-3-centric Netflow-like presentation.

One shortcoming in NFSen was that it wasn't possible to import existing flows into a new install. The backend data access was tailor-made for NFSen, and getting it to do something that it hadn't been designed to do was an up-hill battle. Another missing piece was that although you could display pretty much any list of flows in tabular form, NFSen would not provide graphs based on query results. You had to create a "profile" which updated RRD archives, etc. 

A subsequent flow collection and visualization project, [Elastiflow](https://www.elastiflow.com/), managed to transcend the above-mentioned shortcomings, by collecting flows with LogStash into ElasticSearch, a general purpose data storage and search platform, which bundles with Kibana, a versatile visualization front-end for Elasticsearch. Although Elastiflow has a much more versatile design than NFSen, it is tightly bound to the Elasticsearch EcoSystem. 

## Flows and flows

NetFlow(tm) is a Cisco faeture that appeared around 1996[*](https://en.wikipedia.org/wiki/NetFlow) in Cisco routers. Original NetFlow sampled all packets, followed by Sampled Netflow, which sampled a packet every-so-often, either by periodic or random triggers. 
