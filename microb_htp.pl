#!/usr/bin/perl

use strict;
use warnings;
use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;

#Save URL for later printing
my $url = "http://www.binf.gmu.edu/ssevilla/cgi-bin/MB_Neph.pl";

#Initialize the HTML webpage
print header;
print start_html('Microbiome Nephele Input');
print h1('Microbiome Nephele Input');
print h4('This program will take in the Microbime Manifest, and create a Nephele Manifest, as well as move sequencing files');

#Create form for users to interface with on the web
print start_multipart_form;
print p;
print "Click the button to choose a FASTA file:";
print br;

#Same the filename as a paramter
print filefield(-name=>'file_name');
print p;
reset;
print submit('submit','Submit File');
print hr; 
print endform;

#If a file has been submitted, read in the file, and perform statistic count
if (param()) {
	#Initialize variables for code
	my $file_name = upload('file_name');
	my @fastadata = ();
	my @header;
	my @sequence;
	my $n = 0;
	my $seqlength = '';
	my @seqarray = ();
	my @sort =();
	my $line = '';
	my $statsdata = '';
	my $A = 0, my $afq =0;
	my $C = 0, my $cfq=0;
	my $G = 0, my $gfq=0;
	my $T = 0, my $tfq=0;
	my $CG = 0, my $CGfq=0;

	#Call Sub-Routes
	read_file(\@fastadata, $file_name);

	#Take data file and initialize into headers and sequences
	foreach $line (@fastadata) {
		if ($line =~ /^>/) {
		  $n++;
		  $header[$n] = $line;
		  $sequence[$n] = "";
		} else {
		  $line =~ s/\s//g;
		  $sequence[$n] .= $line
		}
	}

	#Create Loop to determine all sequences
	for (my $i = 1; $i < $n+1; $i++) {
		$seqlength = length($sequence[$i]);
		push(@seqarray, $seqlength);
	}

	#Sort data in length order
	@sort = sort {$a <=> $b} @seqarray;

	#Add all lengths together for overall sum and average
	my $sum = eval join '+', @sort;
	my $average = $sum / $n;

	#Print all overall report figures
	print "Report for file $file_name"; print p;
	print "There are $n sequence(s) in this file"; print p;
	print "Total Sequence Length = $sum"; print p;
	print "Maximum Sequence Length = $sort[$n-1]"; print p;
	print "Minimum Sequence Length = $sort[0]"; print p;
	print "Average Sequence Length = $average"; print p;

	#Create Loop for Sequence Specific Reporting
	for (my $i = 1; $i < $n+1; $i++) {
		print $header[$i]; print p;
		my $statsdata = $sequence[$i];
		my $lengthfile = length($statsdata);
		
		#Determine Counts for sequences
		while($statsdata=~/a/ig)  {$A++}; while($statsdata=~/c/ig)  {$C++};
		while($statsdata=~/g/ig)  {$G++}; while($statsdata=~/t/ig)  {$T++};
		while($statsdata=~/CG/ig) {$CG++};
					
		#Determine frequencies
		$afq = $A / $lengthfile; $cfq = $C / $lengthfile;
		$gfq = $G / $lengthfile; $tfq = $T / $lengthfile;
		$CGfq = $CG / $lengthfile;
				
		#Print all statements
		print "Length: $lengthfile"; print p;
		print "A: $A----";
		printf("%.2f", $afq); print p;
		print "C: $C----";
		printf("%.2f", $cfq); print p;
		print "G: $G----";
		printf("%.2f", $gfq); print p;
		print "T: $T----";
		printf("%.2f", $tfq); print p;
		print "CpG: $CG----";
		printf("%.2f", $CGfq); print p;
		print "$line";
				
		#Reset all counts to Zero
		$A =0, $T=0, $C=0, $G=0, $CG =0, $statsdata =0;
	}
	
	#################################################################################################################################
	#Called Subroutes below
	#################################################################################################################################
	sub read_file {
		
		#Initialize variables
		my($fastadata, $file_name)=@_;
		
		#Read in the file, and close
		@$fastadata= <$file_name>;
		close $file_name;	
	}
	
	#Add a button to reset the webpage
	print address( a({href=>$url},"Click here to submit another file."));
}
print end_html;
exit;