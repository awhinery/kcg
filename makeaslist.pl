#!/usr/bin/perl

#<a href="/cgi-bin/as-report?as=AS1&view=2.0">AS1    </a> LVLT-1 - Level 3 Parent, LLC, US
#<a href="/cgi-bin/as-report?as=AS2&view=2.0">AS2    </a> UDEL-DCN - University of Delaware, US
#<a href="/cgi-bin/as-report?as=AS3&view=2.0">AS3    </a> MIT-GATEWAYS - Massachusetts Institute of Technology, US
#<a href="/cgi-bin/as-report?as=AS4&view=2.0">AS4    </a> ISI-AS - University of Southern California, US

#<a href="/cgi-bin/as-report?as=AS55&view=2.0">AS55   </a> UPENN, US
print "as_number\tas_name\tas_cc\n";
while (<>)
{
chop;
#if (/^<a href=.*?>AS([0-9]+)\s*<\/a>\s+([-A-Z0-9]+).*?,([A-Z][A-Z])$/)
#<a href="/cgi-bin/as-report?as=AS4&view=2.0">AS4    </a> ISI-AS - University of Southern California, US
if (/^<a href=.*?>AS([0-9]+)\s*<\/a>\s+(.*?), ([A-Z][A-Z])$/)
        {
        my $num = $1;
        my $org = $2;
        my $cc = $3;
	$org =~ s/,$//;
	$name =~ s/,$//;
        print "$num\t$org\t$cc\n";
        }
else {print STDERR $_,"\n";}


}# while
