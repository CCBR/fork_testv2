#!/usr/bin/perl

use warnings;
use strict;
use Cwd;
use CPAN;
	eval "use File::chdir" 
	 or do { 
	  CPAN::install("File::chdir");
	};
	
	eval "use File::Copy" 
	 or do { 
	  CPAN::install("File::Copy");
	};
	
	use File::chdir;
	use File::Copy;

use CGI qw(:standard);
use CGI::Carp qw/fatalsToBrowser/;

#Save URL for later printing
my $url = "http://www.binf.gmu.edu/ssevilla/cgi-bin/MB_Neph.pl";

#Initialize the HTML webpage
print header;
print start_html('Microbiome Nephele Input');
print h1('Microbiome Nephele Input');
print h4('This program will take in the Microbime Manifest, and create a Nephele Manifest, as well as move sequencing files');

#Select Location for Microbiome Manifest
print start_multipart_form;
print p;
print "Click the button to choose a Manifest file:";
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
	
	#Intialize variables
	my $QCpath; my $Manpath; my $Nephpath; 
	my @SampleID; my @ExternalID; my @SourceMaterial;
	my @SampleType;	my @ExtractionBatchID; my @RunID; 
	my @SourcePCRPlate; my @ProjectID;
	my @AssayPlate_Neph; my @SampleID_Neph; 
	my @Treatment_Neph;	my @VialLab_Neph; 
	my @ExtractBatch_Neph; my @Descrip_Neph;
	my @filename_R1; my @filename_R2;

	
	#Take in Directory from Command Line and format for CWD
	print "Do you want to include study samples (Y or N)? ";
		my $StudyAns = <STDIN>; chomp $StudyAns;
	print "What is the name of your project? (NP0440-MB2) ";
		my $ProjName = <STDIN>; chomp $ProjName; ###
		### my $ProjName = "NP0452-MB3"; chomp $ProjName; 	###Testing only
	print "What is the MR assoicated with the project (MR-0440)? ";
		my $MRName = <STDIN>; chomp $MRName;###
		###my $MRName = "MR-0452"; chomp $MRName; ###Testing only
	print "What is the date to assoicate with analysis?(04_10_17) ";
		my $date = <STDIN>; chomp $date;###
		###my $date = "test"; chomp $date; ###Testing only

#Call subroutines
	qc_mb_dir(\$ProjName, \$MRName, \$QCpath, \$Manpath);
		$CWD = $QCpath;

	
	##################################################################################################################
################################################# SUBROUTINES ####################################################
##################################################################################################################

	#Creates variables of directories
	sub qc_mb_dir {
		
		#Initiate variables
		my ($ProjName, $MRName, $QCpath, $Manpath)=@_;
		
		#Create pathway for QIIME Folder (QCPath) and Manifest (Manpath)
		$$QCpath = "T:\\DCEG\\CGF\\Laboratory\\Projects\\$$MRName\\$$ProjName\\QC Data";
		$$Manpath = "T:\\DCEG\\CGF\\Laboratory\\Projects\\$$MRName\\$$ProjName\\Analysis Manifests";
	}


	#Add a button to reset the webpage
	print address( a({href=>$url},"Click here to submit another file."));
}
print end_html;
exit;