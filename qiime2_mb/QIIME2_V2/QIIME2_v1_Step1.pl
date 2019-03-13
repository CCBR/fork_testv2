#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
use CPAN;
use File::Copy;
use List::MoreUtils qw(uniq);
use Win32::OLE;

######################################################################################
								##NOTES##
######################################################################################
##This script is to complete the pre-processng tasks needed for the QIIME2 pipeline
##Search for ###TESTING to find testing variables

######################################################################################
								##Main Code##
######################################################################################
my @runid_unique; my @projectid;

#Ask user where the project directory is
print "Where is the project directory?\n";
print "ANS: ";
#my $PROJECT_DIR = <STDIN>; chomp $PROJECT_DIR;
#my $PROJECT_DIR =("T:\\DCEG\\Projects\\Microbiome\\CGR_MB\\MicroBiome\\Project_NP0440-MB3_Baseline_Month1_Repeat"); ###Testing
my $PROJECT_DIR =("T:\\DCEG\\Projects\\Microbiome\\CGR_MB\\MicroBiome\\Project_NP0501_MB1and2"); ###Testing

#Ask user what type of file is being used
print "\n\nWhat is the name of the manifest file (include .txt)?\n";
print "ANS: ";
#my $MANIFEST_ORI=<STDIN>; chomp $MANIFEST_ORI;
#my $MANIFEST_FILE="NP0440-MB3-manifest_withmeta.txt"; ###Testing
my $MANIFEST_FILE="NP0501_MB1and2.txt"; ###Testing


######################################################################################
								##Subroutines##
######################################################################################
#Create directories within Input folder
makedirect_input($PROJECT_DIR);

#Create manifest for QIIME, and split manifests
manifest($PROJECT_DIR, $MANIFEST_FILE, @runid_unique, @projectid);

#Creates directories for flowcells
makedirect_output($PROJECT_DIR,\@runid_unique);

#Finds FastQ files and creates softlinks
fastq_files($PROJECT_DIR, @runid_unique);

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
	
	#Make QZA directories
	$INP_DIR = $PROJECT_DIR;
	$INP_DIR.= "\\Input\\qza_results";
	
	#Make directories nested under Input \ QZA
	@directory_list = ("\\abundance_qza_results", "\\core_metrics_results", "\\demux_qza_split_parts", "\\phylogeny_qza_results", "\\repseqs_dada2_qza_merged_parts_final","\\repseqs_dada2_qza_merged_parts_temp", "\\repseqs_dada2_qza_split_parts", "\\table_dada2_qza_merged_parts_final", "\\table_dada2_qza_merged_parts_tmp", "\\table_dada2_qza_split_parts", "\\taxonomy_qza_results");
		
	foreach my $DIR_NEW (@directory_list){
		
		#Add Input to the directory path
		$DIR_NAME = $INP_DIR;
		$DIR_NAME .= $DIR_NEW;
		
		#Make new directory
		mkdir($DIR_NAME);
	}
	
	#Make QZV directories
	$INP_DIR = $PROJECT_DIR;
	$INP_DIR.= "\\Input\\qzv_results";
	
	#Make directories nested under Input \ QZA
	@directory_list = ("\\demux_qzv_split_parts", "\\otu_relative_abundance_results", "\\rarefaction_qzv_results", "\\repseqs_dada2_qzv_merged_parts_final", "\\table_dada2_qzv_merged_parts_final","\\taxonomy_qzv_results", "\\taxonomy_relative_abundance_results");
		
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
	my ($PROJECT_DIR, $MANIFEST_FILE, $runid_unique, $projectid)=@_;
	my (@sampleid, @externalid, @sampletype, @sourcematerial, @sourcepcrplate, @runid);
	my @fastqpath;
	
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

	foreach my $line (@sampleid){
		print $fh "$line \t";
		print $fh "$sampletype[$i]\t";
		print $fh "$sourcematerial[$i]\n";
		$i++;
	} 
	close $fh;
	
	#Find all unique run ID's
	@runid_unique = uniq @runid;
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
			} 
			$i++;
		}
		
		#Create new manifest file based on current count
		my $MANIFEST_FILE_SPLIT_FASTQ = $PROJECT_DIR;
		$MANIFEST_FILE_SPLIT_FASTQ .= "\\Input\\manifest_file_split_parts_fastq_import\\manifest_file_split_parts_fastq_import_";
		$MANIFEST_FILE_SPLIT_FASTQ .= $count; $MANIFEST_FILE_SPLIT_FASTQ .= ".txt";
		
		open my $fh1, ">$MANIFEST_FILE_SPLIT_FASTQ";
		$i=0;
		
		foreach (@lines){
			my @columns = split ('\t', $_);
			my $check = $columns[7];
			
			if ($check =~ $line){
			
				my $sample_name = "Sample_";
				$sample_name .= $sampleid[$i];
				
				my $FastP = "T:\\DCEG\\CGF\\Sequencing\\Illumina\\MiSeq\\PostRun_Analysis\\Data\\$runid[$i]\\CASAVA\\L1\\Project_$projectid[$i]\\$sample_name\\";
				push (@fastqpath, $FastP);
								
				print $fh1 "$FastP\n";
			} 
			$i++;
		}
		
	$i=0;
	$count ++;
	close $fh;
	close $fh1;

	}
	print "\n***********************************\n";
	print "Completed generating needed manifests\n";
}

sub makedirect_output{
	#Initialize variables / Read in variables
	my ($PROJECT_DIR, $runid_unique)=@_;
	my $DIR_NAME; 
	
	#Make Input directory
	my $INP_DIR = $PROJECT_DIR;
	$INP_DIR.= "\\Input\\Fasta";
	
	my $count=1;
	
	foreach my $DIR_NEW (@$runid_unique){
		
		#Add Input to the directory path
		$DIR_NAME = $INP_DIR;
		$DIR_NAME .="\\fasta_dir_split_part_";
		$DIR_NAME .= $count;
		
		#Make new directory
		mkdir($DIR_NAME);
		$count++;
	}
	
	my $length = scalar (@$runid_unique);
	print "\n***********************************\n";
	print "Completed generating directories for $length flowcell(s)\n";
}

sub fastq_files{
	
	#Initialize Variables
	my ($PROJECT_DIR, $runid_unique) =@_;
	my (@fastq_files_R1, @fastq_files_R2);
	my $wsh = new Win32::OLE 'WScript.Shell';
	
	#Set Pathway for FastQ files
	my $MANIFEST_DIR = $PROJECT_DIR;
		$MANIFEST_DIR .="\\Input\\manifest_file_split_parts_fastq_import\\";
	my $FASTQ_DIR = $PROJECT_DIR;
		$FASTQ_DIR .= "\\Input\\Fasta\\fasta_dir_split_part_";

	#Set counter to number of unique flow cells
	my $unique_count = scalar(@runid_unique);
	my $count=1;
	
	#For each of the flow cells
	while ($unique_count>0){
		my $manifest_name = $MANIFEST_DIR;
		$manifest_name .= "manifest_file_split_parts_fastq_import_";
		$manifest_name .=$count; $manifest_name .= ".txt";	
		
		#Open the manifest with all sample ID's for that flow cell
		open my $in, "<:encoding(utf8)", $manifest_name or die "$manifest_name: $!";
		my @lines = <$in>; close $in;
		chomp @lines;
		
		#Print message for user to know status
		print "\n***********************************\n";
		print "Creating links for $manifest_name\n";
		
		#Run through each directory and copy the directory
		foreach (@lines) {
			my @columns = split('\t',$_);		
						
			#Open File Directory and copy fastq file names
			opendir(DIR, $columns[0]) or die "Can't open directory $columns[0]!";
			my @fastq_files = grep {/_001\.fastq\.gz$/} readdir(DIR);
			closedir(DIR);
			
			#Create links in the split directories for each fastq file, store in corresponding folder
			foreach my $file (@fastq_files){
				
				#Original File location
				my $link_old = $columns[0]; $link_old.= $file;
				
				#New File location
				my $link_new = $FASTQ_DIR; $link_new.= $count; $link_new.="\\"; $link_new .= $file; $link_new .=".lnk";
				
				#Create soft links
				my $lnk_path = $link_new; # path of new .lnk file
				my $target_path = $link_old;
				my $shcut = $wsh->CreateShortcut($lnk_path) or die "Can't create $lnk_path";
				$shcut->{'TargetPath'} = $target_path;
				$shcut->Save;
			}
		}
		$unique_count= $unique_count-1;
		$count++;		
	}
}