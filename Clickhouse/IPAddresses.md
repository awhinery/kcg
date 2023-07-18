# Referencing And Using IP Addresses in GoFlow/Clickhouse

This doc addresses the essentially non-obvious way that you can work with IP addresses (whether IPv6 or IPv4 addresses) in GoFlow/Clickhouse.
NOTE: I MAY CHANGE THE PART ABOUT CONVERSIONS FROM FIXEDSTRING(16) TO IPv[46] ADDRESSES VERY SOON. (seems like I can simplify the functions I'm using.)

## context

It's perhaps useful to mention that IP addresses are not decimal numbers separated by periods, nor are they hexadecimal numbers separated by colons. They are, in fact, integers (or whole numbers, or unsigned integers, etc Tomato/Tomahto). It doesn't matter whether we're talking about IPv4 or IPv6. The ranges of possible integers describing unicast IP addresses observable "in the wild" (currently) comprise 2 non-intersecting ranges of numbers. 

IPv4 global addresses use most of the range from 2,147,483,648 (1.0.0.0) to 3,758,096,383 (223.255.255.255), and IPv6 globals are currently using most of the range from 2000::/16 to 3FFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF (totaling 42,535,295,865,117,307,914,475,081,855,261,474,816 decimal addresses). 

The representation of IP addresses in the original Cloudflare GoFlow examples was probably influenced by the fact that ProtoBuffers lack a 128 bit unsigned integer type, which would be considerably simpler for a combined IPv4/IPv6 column type. It would be interesting to see what kind of performance hit we're taking fiddling around with this FixedString(16) type, which might even be possible with funneling everything into a new table, once it gets into Clickhouse.

My Clickhouse database is closely-related to the ones described in the goflow/goflow2 repos, with some added fields. 
I was able to make this schema work by simply adding fields in the clickhouse/create.sh file (see the demo compose folder (when it exists)). 

Currently, my data in tables "flows" and "flows_raw" looks like:

|name | type |
| ------------|------------------:|
|TimeReceived | DateTime  |
|TimeFlowStart | DateTime  |
|TimeFlowEnd | DateTime  |
|Type | UInt8  |
|SequenceNum | UInt32  |
|SamplingRate | UInt64  |
|SamplerAddress | FixedString(16)  |
|SrcAddr | FixedString(16)  |
|DstAddr | FixedString(16)  |
|SrcAS | UInt32  |
|DstAS | UInt32  |
|SrcNet | UInt8  |
|DstNet | UInt8  |
|SrcVlan | UInt32  |
|DstVlan | UInt32  |
|VlanId | UInt32  |
|IPTTL | UInt32  |
|TCPFlags | UInt32  |
|InIf | UInt32  |
|OutIf | UInt32  |
|IcmpType | UInt32  |
|IcmpCode | UInt32  |
|EType | UInt32  |
|Proto | UInt32  |
|SrcPort | UInt32  |
|DstPort | UInt32  |
|IPTos | UInt32  |
|IPv6FlowLabel | UInt32  |
|FragmentId | UInt32  |
|FragmentOffset | UInt32  |
|HasEncap | Bool  |
|SrcAddrEncap | FixedString(16)  |
|DstAddrEncap | FixedString(16)  |
|ProtoEncap | UInt32  |
|EtypeEncap | UInt32  |
|IPTosEncap | UInt32  |
|IPTTLEncap | UInt32  |
|IPv6FlowLableEncap | UInt32  |
|FragmentIdEncap | UInt32  |
|FragmentOffsetEncap | UInt32  |
|HasMPLS | Bool  |
|MPLSCount | UInt32  |
|MPLS1TTL | UInt32  |
|MPLS1Label | UInt32  |
|MPLS2TTL | UInt32  |
|MPLS2Label | UInt32  |
|MPLS3TTL | UInt32  |
|MPLS3Label | UInt32  |
|MPLSLastTTL | UInt32  |
|MPLSLastLabel | UInt32  |
|HasPPP | Bool  |
|PPPAddressControl | UInt32  |
|Bytes | UInt64  |
|Packets | UInt64 |

Some fields have been included to discover whether they're being reported by any router. (In my main 1000 packets-per-second of flow reports coming to the U. Hawaii KCG instance, I do in fact have flow records with "HasPPP" = true). 

Three of the columns contain IP addresses, which may be either IPv4 or IPv6 addresses, in FixedString(16). This type is a binary string, which will not print properly when displayed without some sort of formating function. If you are connected to you server by SSH, and you use the clickhouse-client to do:

    SELECT SrcAddr,DstAddr from flows_raw LIMIT 10

Then the result will include TTY control characters which will bork your terminal emulation, and you'll probably have to close the window and start over. The representation of addresses when displayed in the Clichouse/play web interface will be about equally useful, but less annoying, as it will print some series of non-ascii characters in the output, like ("��"), but it won't bother your web browser, probably. 

If I were starting from scratch (maybe later), I would make the abbreviation of the word "Address" consistent across current non-consistent fields Src*Addr*, Dst*Addr*, Sampler*Address*.

In my opinion, you should resist the impulse to separate IPv4 and IPv6. Developing queries that are independent of address-family allows you to treat all traffic similarly, and the Layer 4 protocols which do most of the work, TCP and UDP operate identically in IPv4 and IPv6. The two can be separated in queries by using ethertype ("EType") as will be illustrated below. 

### using hex()

The simplest way to display the FixedString(16) in a readable way which actually does display the address is:

  SELECT hex(SrcAddr) from flows_raw LIMIT 10

Which should show you an IP address as:
   CB007101000000000000000000000000 (for 0xCB007101, AKA "203.0.113.1")
   
or an IPv6 Address as:
   20010DB8410100307DB7A08DAB215578 (for "2001:db8:4101:30:7DB7:A08D:AB21:5578" )

While this may not be ideal for someone not familiar with a IP Addresses as hexadecimal strings, it is a clean, simple way to see the addresses and make them displayable simply, when you just want to form a query as a test. 

### Seeing addresses in familiar notations

Since IPv6 addresses are pretty-familiar-looking in the hex() example above, let's look at IPv4 addresses. 

To display a KCG IPv4 address as Clickhouse's IPv4 type:

   SELECT toIPv4(reinterpretAsUInt32(substring(reverse(SrcAddr), 13,4))) as src, toTypeName(src) as type FROM flows_raw LIMIT 1
   
   | src           | type |
   | -------------:|:-----:|
   |203.0.113.1 |IPv4|
   
Where "reverse(SrcAddr)" reverses the byte order of the FixedString(16):

    SrcAddr:            CB007101000000000000000000000000
    SrcAddr reversed:   000000000000000000000000017100CB

And "substring(reverse(SrcAddr), 13,4)" takes only the last 4 bytes (starting with byte 13 and taking 4 bytes). 
    SrcAddr reversed:   000000000000000000000000017100CB
    Truncated to:       017100CB
    
And "reinterpretAsUInt32(substring(reverse(SrcAddr), 13,4))" simply makes it look to Clickhouse as a 32-bit unsigned integer:

     From: 017100CB
       To: CB007101
(which is the same as the original 4 bytes of the SrcAddr FixedString(16) column) (stay tuned)

To display a KCG IPv4 address as an ASCII string:

   SELECT IPv4NumToString(reinterpretAsUInt32(substring(reverse(SrcAddr), 13,4))) as src, toTypeName(src) as type FROM flows_raw LIMIT 1
   
   | src           | type |
   | -------------:|:-----:|
   |203.0.113.1 |String|
   
   
Since the "IPv4" type is simply a UInt32 with different display rules, you don't need to convert to type IPv4 to use "IPv4NumToString".

The IPv6 version is less unsightly:

   SELECT IPv6NumToString(SrcAddr) AS src, toTypeName(src) as type FROM flows_raw WHERE EType = 0x86DD LIMIT 1
   
   | src           | type |
   | -------------:|:-----:|
   |2001:db8:4101:30:7DB7::A08D |String|
  
In this case, I used a WHERE clause to specify ethertype 0x86DD, which is indicates that the Ethernet frame payload is an IPv6 datagram. If I were going to specify IPv4, I would have used ethertype 0x0800. 

### Defining IP address display functions

In order to avoid typing things like:
    SELECT toIPv4(reinterpretAsUInt32(substring(reverse(SrcAddr), 13,4))) as src

I created 2 display functions, dispIPv4 and dispIPany. 

**dispIPv4** will display the provided FixedString's low-order 4 bytes as a dotted quad, without checking to see that the provided FixedString[16] acutally contains an IPv4 number:

    CREATE FUNCTION dispIPv4  AS (n) -> IPv4NumToString(reinterpretAsUInt32(substring(reverse(n), 13,4)))

Which can be used thusly:
    SELECT dispIPv4(SamplerAddress) as exp FROM flows_raw LIMIT 1

    | exp |
    |-----|
    |203.0.113.1 |

Note: **dispIPv4** will happily print 4 bytes of a supplied IPv6 address in dotted quad, and it will often look like a valid IPv4 address. If you're going to use this function, there needs to be some sort of assurance that it will only encounter IPv4 addresses, such as a "WHERE EType = 0x0800" or similar. 

**dispIPany** displays either IP address type, based on the EType in the current flow record, and NULL if the EType is neither 0x0800 (IPv4) nor 0x86dd (IPv6)
The NULL output can cause issues when the output is suppled to a receiver function that does not use type "NULLABLE". 

    CREATE FUNCTION dispIPany  AS (n) -> if (EType = 0x800, IPv4NumToString(reinterpretAsUInt32(substring(reverse(n), 13,4))) , if (EType = 0x86DD, IPv6NumToString(n),NULL ))

There is no "dispIPv6" user function, since IPv6NumToString(SrcAddr) is not much more typing. 

In my flow queries that include "SamplerAddress" (the IP address which the router that exported the flow record used to send it), I always use **dispIPv4** because all of my flow sources use IPv4 addresses, and the SamplerAddress is not necessarily the same family as the EType field (A routrer might send you an IPv6 flow record in an IPv4 packet). 

### The SrcNet and DstNet Fields
The schema provides 2 columns (SrcNet, DstNet) with mask-length number for source or destination addresses in flows where it has a route for the IP address in question. 

This is the number you see in so-called "CIDR" notation, after the slash (e.g. 203.0.113.0/24 --> SrcNet = 24).

Using SrcAddr/SrcNet as an example, **IFF** the router has a route for a prefix which includes SrcAddr, it will populate SrcNet. If it has no prefix for SrcAddr, then it will probably return a SrcNet of zero. If the reporting router is a border router with a full BGP table, it will probably report SrcNet for pretty much everything. If it's an internal IGP router, then it will report SrcNet of zero for source addresses outside its route table scope. 

In order to get the zero-number of the prefix formed with SrcAddr and SrcNet, you can use: 
    
    SELECT toIPv4(IPv4CIDRToRange(toIPv4(dispIPv4(SrcAddr)), SrcNet).1) AS prefix
    OR
    SELECT IPv6CIDRToRange(toIPv6(SrcAddr), SrcNet).1 as v6 prefix

The "IPv*CIDRToRange" functions return a tuple with the lowest address and the highest address in the range. The ".1" index in the above examples references the lowest (zero) address for the subnet range. 
    


    
