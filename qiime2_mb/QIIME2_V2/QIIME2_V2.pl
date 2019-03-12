#!/usr/bin/perl

use strict;
use warnings;
use Cwd;
use CPAN;
use File::chdir;
use File::Copy;
use List::MoreUtils qw(uniq);

######################################################################################
								##NOTES##
######################################################################################
##This script is to create the directories needed for the QIIME2 pipeline
##Search for ###TESTING to find testing variables

######################################################################################
					##Step 1 - Directory and Manifest Preparation##
######################################################################################
{
								##Main Code##
######################################################################################
#Ask user where the project directory is
print "Where is the project directory?";
#my $PROJECT_DIR = <STDIN>; chomp $PROJECT_DIR;
my $PROJECT_DIR =("T:\\DCEG\\Projects\\Microbiome\\CGR_MB\\MicroBiome\\Project_NP0501_MB1and2"); ###Testing

#Ask user what type of file is being used
print "What is the name of the manifest file (include .txt)?";
#my $MANIFEST_ORI=<STDIN>; chomp $MANIFEST_ORI;
my $MANIFEST_FILE="NP0501_MB1and2.txt"; ###Testing

#Assign directory pathways
##To Create
my $INP_DIR=$PROJECT_DIR; $INP_DIR.="\\Input"; 
	my $TEMP_DIR=$INP_DIR; $TEMP_DIR.="\\tmp";
	my $LOG_DIR=$INP_DIR; $LOG_DIR .= "\\Log";
	my $MANIFEST_FILE_SPLIT_PARTS_DIR=$INP_DIR; $MANIFEST_FILE_SPLIT_PARTS_DIR .="\\manifest_file_split_parts";
	my $MANIFEST_FILE_SPLIT_PARTS_FASTQ_IMPORT_DIR=$INP_DIR; $MANIFEST_FILE_SPLIT_PARTS_FASTQ_IMPORT_DIR .="\\manifest_file_split_parts_fastq_import";
	my $FASTA_DIR= $INP_DIR; $FASTA_DIR.="\\Fasta";
	my $FASTA_DIR_TOTAL= $INP_DIR; $FASTA_DIR_TOTAL.="\\Fasta_Total";
	my $QZA_RESULTS_DIR=$INP_DIR; $QZA_RESULTS_DIR.= "\\qza_results";
	my $QZV_RESULTS_DIR=$INP_DIR; $QZV_RESULTS_DIR.="\\qzv_results";
	
#Imp Files
my $SCRIPT_DIR="T:\\DCEG\\Projects\\Microbiome\\CGR_MB\\MicroBiome\\ss_scripts_microbiome_analysis\\ss_scripts_qiime2_pipeline_V1";
	my $RESOURCES_DIR= $SCRIPT_DIR; $RESOURCES_DIR.="\\resources";
	
#Run Subroutines
##Create directories
makedirect($INP_DIR, $TEMP_DIR, $LOG_DIR, $MANIFEST_FILE_SPLIT_PARTS_DIR, $MANIFEST_FILE_SPLIT_PARTS_FASTQ_IMPORT_DIR, $FASTA_DIR, $FASTA_DIR_TOTAL, $QZA_RESULTS_DIR, $QZV_RESULTS_DIR);

##Create manifest for QIIME
manifest($PROJECT_DIR, $MANIFEST_FILE);

								##Subroutines##
######################################################################################
sub makedirect{
	#Initialize variables / Read in variables
	my ($INP_DIR, $TEMP_DIR, $LOG_DIR, $MANIFEST_FILE_SPLIT_PARTS_DIR, $MANIFEST_FILE_SPLIT_PARTS_FASTQ_IMPORT_DIR, $FASTA_DIR, $FASTA_DIR_TOTAL, $QZA_RESULTS_DIR, $QZV_RESULTS_DIR)=@_;
	
	#Make directories
	mkdir ($INP_DIR);
	mkdir ($TEMP_DIR);
	mkdir ($LOG_DIR);
	mkdir ($MANIFEST_FILE_SPLIT_PARTS_DIR);
	mkdir ($MANIFEST_FILE_SPLIT_PARTS_FASTQ_IMPORT_DIR);
	mkdir ($FASTA_DIR);
	mkdir ($FASTA_DIR_TOTAL);
	mkdir ($QZA_RESULTS_DIR);
	mkdir ($QZV_RESULTS_DIR);
}

sub manifest{
	#Initialize variables / Read in variables
	my ($PROJECT_DIR, $MANIFEST_FILE)=@_;
	my @sampleid; my @sampletype; my @sourcematerial; my @runid;
	
	#Set pathway for manifest
	my $MANIFEST_FILE_TXT=$PROJECT_DIR; $MANIFEST_FILE_TXT.="\\";
	$MANIFEST_FILE_TXT.= $MANIFEST_FILE; 

	#Open text file and remove header
	open my $in, "<:encoding(utf8)", $MANIFEST_FILE_TXT or die "$MANIFEST_FILE_TXT: $!";
	my @lines = <$in>; close $in;
	chomp @lines;
	
	#Create the TXT manifest to the QIIME manifest with sample ID, Sample Type, Source Material
	my $MANIFEST_FILE_QIIME = $PROJECT_DIR; $MANIFEST_FILE_QIIME .="\\Input\\manifest_qiime2.tsv";

	foreach (@lines) {
		my @columns = split('\t',$_);
		push(@sampleid, $columns[0]); #SampleID
		push(@sampletype, $columns[2]); #Sample Type
		push(@sourcematerial, $columns[3]); #Source Material
		push (@runid, $columns[7]); #RunID
	}
	
	##Print the qiime manifest
	my $i=0; 
	open my $fh, ">$MANIFEST_FILE_QIIME";
	print $fh "#";
	foreach my $line (@sampleid){
		print $fh "$line \t";
		print $fh "$sampletype[$i]\t";
		print $fh "$sourcematerial[$i]\n";
		$i++;
	} 
	close $fh;
	
	#Find all unique run ID's
	shift @runid;
	my @runid_unique = uniq @runid;
	
	my $count = 1;
	$i=0;
	
	#Create manifests for each RunID
	foreach my $line (@runid_unique){
		
		#Create new manifest file based on current count
		my $MANIFEST_FILE_SPLIT = $PROJECT_DIR;
		$MANIFEST_FILE_SPLIT .= "\\Input\\manifest_file_split_parts\\manifest_split_part_";
		$MANIFEST_FILE_SPLIT .= $count; $MANIFEST_FILE_SPLIT .= ".txt";
		
		print "$MANIFEST_FILE_SPLIT\n";
		
		open my $fh, ">$MANIFEST_FILE_SPLIT";

		foreach (@lines){
			my @columns = split ('\t', $_);
			my $check = $columns[7];
			
			if ($check =~ $line){
				print $fh "$sampleid[$i]\t";
				print $fh "$sampletype[$i] \t";
				print $fh "$sourcematerial[$i]\n";

			} else{
			next;
			}
			$i++;
		
		}
	$i=0;
	$count ++;
	close $fh;

	}
}
}

######################################################################################
					##Step 2 - FASTA LINKS##
######################################################################################
								##Main Code##
######################################################################################





								##Subroutines##
######################################################################################