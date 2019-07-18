#!/usr/bin/perl
#User: Samantha Sevilla

use strict;
use warnings;
use Cwd;
use CPAN;
use File::chdir;
use File::Copy;
use File::Find;

#initalize variables
my @unique; my @sampleid; my @fastqpath; my @fileR1;my @fileR2;

print "\nHave you run the nephele manifest code, and moved FASTQ files? ";
		my $ans = <STDIN>; chomp $ans;
	
	if ($ans=~'Y' or $ans=~'y') {
		print "\nWhat is the Project (IE NP0084-MB6)? ";
			#my $ProjName = <STDIN>; chomp $ProjName;
		print "\nWhat is the date associated with the project (IE 07_17_19)? ";
			#my $date = <STDIN>; chomp $date;
		
		###Testing
		my $ProjName="NP0084-MB4";
		my $date="07_17_19";
		
		my $MRName = $ProjName;
		$MRName =~ s/NP//g;
		$MRName =~ s/-.*$//g;
		$MRName = "MR-$MRName";
	
		my $QCPath = "T:\\DCEG\\CGF\\Laboratory\\Projects\\$MRName\\$ProjName\\QC Data\\nephele\\$date\_input";
		
		
		read_Man($ProjName, $date, $QCPath, \@unique,\@sampleid, \@fastqpath,\@fileR1,\@fileR2);
		delete_files($ProjName, $date, $QCPath, \@unique,\@sampleid, \@fastqpath,\@fileR1,\@fileR2);
		moveandrename_files($ProjName, $date, $QCPath, \@unique,\@sampleid, \@fastqpath,\@fileR1,\@fileR2);
	} else{
		print "\n Please run code and move files prior to running this code";
	}

sub read_Man{
	#Initialize Variables
	my ($ProjName, $date, $QCPath, $unique,$sampleid, $fastqpath, $fileR1, $fileR2) =  @_;
	my @QCdata; 

	$CWD = $QCPath;
	
	my $manifile= "$ProjName\_status\_$date.txt";

	#If file cannot be opened, give error message and close
	unless (open(READ_FILE, $manifile)) {
		print "\nCannot open file $manifile \n\n";
		exit;
	}
	
	#Confirmations
	print "\n\n******************************\nReading in manifest file\n";

	#Read in the file, and close
	my @filedata= <READ_FILE>;
	close READ_FILE;
		
	foreach my $line (@filedata) {
		push (@QCdata, $line);
	}
	shift @QCdata;

	#Create arrays with sample line data separated by tabs
	foreach (@QCdata) {
		my @columns = split('\t',$_);
		push(@unique, $columns[1]);
		push(@sampleid, $columns[2]);
		push(@fastqpath, $columns[3]);
		push(@fileR1, $columns[4]);
		push(@fileR2, $columns[5]);
	}
}

sub delete_files{
	#Initialize Variables
	my ($ProjName, $date, $QCPath, $unique,$sampleid, $fastqpath, $fileR1, $fileR2) =  @_;
	my $n=0;
	
	my $Nephpath = $QCPath;
	$Nephpath .= "\\FastQ";
	$CWD = $Nephpath;
				
	foreach my $line (@unique){
	
		if ($line=~"A"){
			#unlink $fileR1[$n];
			#unlink $fileR2[$n];
			print "Deleting files $fileR1[$n]\n";
			$n++;
		} else{
			$n++;
			next;
		}
	}
}

sub moveandrename_files{
	
	#Initialize Variables
	my ($ProjName, $date, $QCPath, $unique, $sampleid, $fastqpath, $fileR1, $fileR2) =  @_;
	my @curfilepath; my @destfilepath; my @oldname; my @newname;
	my $n=0;
	
	my $Nephpath = $QCPath;
	$Nephpath .= "\\FastQ";

	
	foreach my $line (@unique){
		if ($line=~"A"){
			
			my $newid=$sampleid[$n];
			my $newname = $fileR1[$n];
			$newname =~ s/SC....../$newid/g;
			$newname =~ s/-/./g;
				
			my $file1 = $fileR1[$n];
			copy( "$fastqpath[$n]\\$file1", "$Nephpath\\$file1" );
			rename "$Nephpath\\$file1", "$Nephpath\\$newname";
			print "new name $newname\n";
			
			$newid=$sampleid[$n];
			$newname = $fileR2[$n];
			$newname =~ s/SC....../$newid/g;
			$newname =~ s/-/./g;
				
			my $file2 = $fileR2[$n];
			copy( "$fastqpath[$n]\\$file1", "$Nephpath\\$file1" );
			rename "$Nephpath\\$file1", "$Nephpath\\$newname";
			print "new name $newname\n";
		
			$n++;
		}
		else {$n++;}
	}
}

sub update_manifest{




}