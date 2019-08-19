#!/usr/bin/perl
#User: Samantha Sevilla
#Date Created: 7/18/19

use strict;
use warnings;
use Cwd;
use CPAN;
use File::chdir;
use File::Copy;
use File::Find;

######################################################################################
								##NOTES##
######################################################################################
###This script reads in the status nephele file and determines whether samples have duplicate names
###if they do, the script will delete the original files, and move the correct files with new files names
###to the FASTQ folder. It will create a new nephele manifest with these new file names included

#initalize variables
my @unique; my @sampleid; my @fastqpath; my @fileR1;my @fileR2;

print "\nHave you run the nephele manifest code, and moved FASTQ files (Y or N)? ";
		my $ans = <STDIN>; chomp $ans;
	
	if ($ans=~'Y' or $ans=~'y') {
		print "\nWhat is the Project (IE NP0084-MB6)? ";
			my $ProjName = <STDIN>; chomp $ProjName;
		print "\nWhat is the date associated with the project (IE 07_17_19)? ";
			my $date = <STDIN>; chomp $date;
		
		###Testing
		#my $ProjName="NP0084-MB4";
		#my $date="07_17_19";
		
		my $MRName = $ProjName;
		$MRName =~ s/NP//g;
		$MRName =~ s/-.*$//g;
		$MRName = "MR-$MRName";
	
		my $QCPath = "T:\\DCEG\\CGF\\Laboratory\\Projects\\$MRName\\$ProjName\\QC Data\\nephele\\$date\_input";
		
		
		read_Man($ProjName, $date, $QCPath, \@unique,\@sampleid, \@fastqpath,\@fileR1,\@fileR2);
		delete_files($ProjName, $date, $QCPath, \@unique,\@sampleid, \@fastqpath,\@fileR1,\@fileR2);
		moveandrename_files($ProjName, $date, $QCPath, \@unique,\@sampleid,\@fastqpath,\@fileR1,\@fileR2);
		update_manifest($ProjName, $date, $QCPath, \@unique,\@sampleid, \@fastqpath,\@fileR1,\@fileR2);
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
	
	#Confirmations
	print "\n\n******************************\nDeleting files\n";	
	
	foreach my $line (@unique){
			if ($line=~"N"){
			unlink $fileR1[$n];
			unlink $fileR2[$n];
			#print "Deleting files $fileR1[$n]\n";
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

	#Confirmations
	print "\n\n******************************\nCopying and renaming files\n";	
	
	foreach my $line (@unique){
		if ($line=~"N"){
				
			#Forward strand
			my $newid=$sampleid[$n];
			my $newname = $fileR1[$n];
			$newname =~ s/SC....../$newid/g;
			$newname =~ s/-/./g;
				
			my $file1 = $fileR1[$n];
			copy( "$fastqpath[$n]\\$file1", "$Nephpath\\$file1" );
			rename "$Nephpath\\$file1", "$Nephpath\\$newname";
			$fileR1[$n]=$newname;
			#print "new name $newname\n";
			
			#Reverse strand
			$newid=$sampleid[$n];
			$newname = $fileR2[$n];
			$newname =~ s/SC....../$newid/g;
			$newname =~ s/-/./g;
				
			my $file2 = $fileR2[$n];
			copy( "$fastqpath[$n]\\$file1", "$Nephpath\\$file1" );
			rename "$Nephpath\\$file1", "$Nephpath\\$newname";
			$fileR2[$n]=$newname;
			#print "new name $newname\n";
		
			$n++;
		}
		else {$n++;}
	}
}

sub update_manifest{

	#Initialize Variables
	my ($ProjName, $date, $QCPath, $unique,$sampleid, $fastqpath, $fileR1, $fileR2) =  @_;
	my @QCdata; my @nephe_sample; my @nephe_r1; my @nephe_r2; my @nephe_treat; my @nephe_vial; my @nephe_plate; my @nephe_batch; my @nephe_desc;

	$CWD = $QCPath;
	
	my $manfile= "$ProjName\_Nephele\_Input\_$date.txt";

	#If file cannot be opened, give error message and close
	unless (open(READ_FILE, $manfile)) {
		print "\nCannot open file $manfile \n\n";
		exit;
	}
	
	#Confirmations
	print "\n\n******************************\nReading in manifest file\n";

	#Read in the file, and close
	my $n=0;
	my @filedata= <READ_FILE>;
	close READ_FILE;
		
	foreach my $line (@filedata) {
		push (@QCdata, $line);
	}
	shift @QCdata;
	
	#Add remaining columns
	foreach (@QCdata) {
		my @columns = split('\t',$_);
		push (@nephe_sample, $columns[0]);
		push(@nephe_r1, $columns[1]);
		push(@nephe_r2, $columns[2]);
		push(@nephe_treat, $columns[3]);
		push(@nephe_vial, $columns[4]);
		push(@nephe_plate, $columns[5]);
		push(@nephe_batch, $columns[6]);
		push(@nephe_desc, $columns[7]);
		$n++;
	}
	
	#Update the R1 and R2 names
	$n=0;
	foreach my $line (@sampleid){
		if($unique[$n]=~"N"){
			$nephe_r1[$n]=$fileR1[$n]; 
			$nephe_r2[$n]=$fileR2[$n];
			$n++;
		} else{
			$n++;
			next;
		}
	}
	
	#Create updated nephele manifest with new file names
	my $newmanfile= "$ProjName\_Nephele\_Input\_Update\_$date.txt";

	#Print the new nephele text file
	my @headers = ("\#SampleID", "ForwardFastqFile", "ReverseFastqFile", "TreatmentGroup", "VialLabel", "AssayPlate", "ExtractionBatch", "Description");
	
	#Print data to Nephele txt file
	$n=0;
	open (FILE, ">$newmanfile") or die;
		
	#Confirmations
	print "\n\n******************************\nUpdating manifest file\n";	
	
	#Print headers to file
	print FILE join ("\t", @headers), "\n";
		
	#Print data to manifest file
	foreach my $sample (@nephe_sample) {
		my @temparray;
		push(@temparray, $sample);
		push(@temparray, $nephe_r1[$n]);
		push(@temparray, $nephe_r2[$n]);
		push(@temparray, $nephe_treat[$n]);
		push(@temparray, $nephe_vial[$n]);
		push(@temparray, $nephe_plate[$n]);
		push(@temparray, $nephe_batch[$n]);
		push(@temparray, $nephe_desc[$n]);
		print FILE join("\t",@temparray);
		$n++;
	}
	

}