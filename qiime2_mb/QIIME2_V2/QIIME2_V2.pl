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
##This script is to complete the pre-processng tasks needed for the QIIME2 pipeline
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

#Run Subroutines
##Create directories within Input folder
makedirect_input($PROJECT_DIR);

##Create manifest for QIIME, and split manifests
manifest($PROJECT_DIR, $MANIFEST_FILE);

##Create directories within Output folder
makedirect_output($PROJECT_DIR);

								##Subroutines##
######################################################################################
sub makedirect_input{
	#Initialize variables / Read in variables
	my ($PROJECT_DIR)=@_;
	my $DIR_NAME; 
	
	#Make Input directory
	my $INP_DIR = $PROJECT_DIR;
	$INP_DIR.= "\\Input";
	mkdir($INP_DIR);
	
	#Make directories nested under Input
	my @directory_list = ("\\tmp", "\\Log", "\\manifest_file_split_parts", "\\manifest_file_split_parts_fastq_import", "\\Fasta","\\qza_results", "\\qzv_results");
		
	foreach my $DIR_NEW (@directory_list){
		
		#Add Input to the directory path
		$DIR_NAME = $INP_DIR;
		$DIR_NAME .= $DIR_NEW;
		
		#Make new directory
		mkdir($DIR_NAME);
	}
}

sub manifest{
	#Initialize variables / Read in variables
	my ($PROJECT_DIR, $MANIFEST_FILE)=@_;
	my (@sampleid, @externalid, @sampletype, @sourcematerial, @sourcepcrplate, @runid, @projectid);
	
	#Set pathway for manifest
	my $MANIFEST_FILE_TXT=$PROJECT_DIR; $MANIFEST_FILE_TXT.="\\";
	$MANIFEST_FILE_TXT.= $MANIFEST_FILE; 

	#Open text file
	open my $in, "<:encoding(utf8)", $MANIFEST_FILE_TXT or die "$MANIFEST_FILE_TXT: $!";
	my @lines = <$in>; close $in;
	chomp @lines;
	
	#Run through each line and save relevant information
	foreach (@lines) {
		my @columns = split('\t',$_);
		push(@sampleid, $columns[0]); #SampleID
		push (@externalid, $columns[1]); #External ID
		push(@sampletype, $columns[2]); #Sample Type
		push(@sourcematerial, $columns[3]); #Source Material
		push(@sourcepcrplate, $columns[6]); #Souce Plate ID
		push (@runid, $columns[7]); #RunID
		push (@projectid, $columns[9]); #Project ID
	}
	
	#Create the TXT manifest to the QIIME manifest with sample ID, Sample Type, Source Material
	my $MANIFEST_FILE_QIIME = $PROJECT_DIR; $MANIFEST_FILE_QIIME .="\\Input\\manifest_qiime2.tsv";
	
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
	my @runid_unique = uniq @runid;
	shift @runid_unique;
	
	#Create split manifests with sample ID's
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
				print $fh "$externalid[$i]\t";
				print $fh "$sampletype[$i] \t";
				print $fh "$sourcematerial[$i]\t";
				print $fh "$sourcepcrplate[$i]\t";
				print $fh "$runid[$i]\t";
				print $fh "$projectid[$i]\n";
			} else{next;}
			$i++;
		}
	$i=0;
	$count ++;
	close $fh;

	}
}
}
sub makedirect_output{
	#Initialize variables / Read in variables
	my ($PROJECT_DIR)=@_;
	my $DIR_NAME; 
	
	#Make Input directory
	my $OUTP_DIR = $PROJECT_DIR;
	$OUTP_DIR.= "\\Output";
	mkdir($OUTP_DIR);
	
	#Make directories nested under Input
	my @directory_list = ("\\abundance_qza_results", "\\core_metrics_results", "\\demux_qza_split_parts", "\\phylogeny_qza_results", "\\repseqs_dada2_qza_merged_parts_final","\\repseqs_dada2_qza_merged_parts_temp", "\\repseqs_dada2_qza_split_parts", "\\table_dada2_qza_merged_parts_final", "\\table_dada2_qza_merged_parts_tmp", "\\table_dada2_qza_split_parts", "\\taxonomy_qza_results");
		
	foreach my $DIR_NEW (@directory_list){
		
		#Add Input to the directory path
		$DIR_NAME = $OUTP_DIR;
		$DIR_NAME .= $DIR_NEW;
		
		#Make new directory
		mkdir($DIR_NAME);
	}


}


######################################################################################
					##Step 2 - FASTA LINKS##
######################################################################################
								##Main Code##
######################################################################################

#Set Pathway for FastQ files
my $Nephpath = "T:\DCEG\Projects\Microbiome\CGR_MB\MicroBiome\Project_NP0501_MB1and2\Input\manifest_file_split_parts_fastq_import";

FastQ_File($Nephpath, $man_only, @RunID, @ProjectID, @SampleID, \@filename_R1, \@filename_R2);

								##Subroutines##
######################################################################################
sub FastQ_File{
	
	#Initialize Variables
	my ($Nephpath, $man_only, $RunID, $ProjectID, $SampleID, $filename_R1, $filename_R2) =@_;
	my @foldernames; my @fastqpath;
	my $b = 0; my $c=0; my $n=0; my $FastP;

	#Create Folder Names from Sample ID's IF RunID is not blank (allows partial runs)
	foreach my $line(@SampleID) {
		my $Sample = "Sample_";
		$Sample .=$line;
		push (@foldernames, $Sample);
	}

	#Create Directory paths for all samples
	foreach my $line (@foldernames) {
		my $tempRun = $RunID[$n];
		my $tempProj= $ProjectID[$n];
		chomp $tempProj;

		#Create pathway for FastQ files, second pass
		$FastP = "T:\\DCEG\\CGF\\Sequencing\\Illumina\\MiSeq\\PostRun_Analysis\\Data\\$tempRun\\CASAVA\\L1\\Project_$tempProj\\$line\\";
		$FastP =~ s/_MB/-MB/g;
		push (@fastqpath, $FastP);
		$n++;
	}
	print "\n****************************** \nMoving Files\n";
	
	#Run through each directory, find paths for FASTQ Files
	foreach my $line (@fastqpath){
	
		#Open File Directory and copy fastq files
		opendir(DIR, $line) or die "Can't open directory $line!";
		my @files = grep {/_001\.fastq\.gz$/} readdir(DIR);
		closedir(DIR);

		#Read through each file of the directory
		for my $file (@files) {
							
			#If the file is an R1 FASTQ File, save
			if ($file =~ /R1/) {
                
				#Push file names and directory locations
				push(@filename_R1, $file);
			}
			
			#If the file is an R2 FASTQ File, save
			elsif ($file =~ /R2/){
                push(@filename_R2, $file);
			} else{next;}
		}
	}

	#Create copies and move FASTQ File to Nephele Folder
	if($man_only=~'N'){
		opendir (NDIR, $Nephpath);
		foreach my $line(@fastqpath) {
			
			#Open directory with FastQ folders
			$CWD = $line;
			my $tempfile_R1 = $filename_R1[$b];
			my $tempfile_R2 = $filename_R2[$c];
		
		#Create loop for files to be copied and pasted to nephele
			copy ($tempfile_R1, $Nephpath) or die;
			copy ($tempfile_R2, $Nephpath) or die;
			$b++; $c++;
		}
		closedir(NDIR);
		print "\nCompleted moving FastQ files";
	}
}
