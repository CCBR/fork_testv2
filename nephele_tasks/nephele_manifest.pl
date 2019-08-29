#!/usr/bin/perl
# Name of file: microbiome.pl
# Owner: Samantha Sevilla
# Last Update: 4/23/18

######################################################################################
								##NOTES##
######################################################################################
###This script takes in the Project and MR number of a program and finds the associated MB Manifest, downloaded
###from LIMS. It then copies the fastq files of all QC samples and moves them to the Nephele folder. It creates
###the necessary txt file to input into Nephele.

######################################################################################
								##Main Code##
######################################################################################
use warnings;
use strict;
use Cwd;
use CPAN;
use File::chdir;
use File::Copy;

#Intialize variables
	my $QCPath; my $ManPath; my $Nephpath; my $MRName;
	my @SampleID; my @ExternalID; my @SourceMaterial;
	my @SampleType;	my @ExtractionBatchID; my @RunID; 
	my @SourcePCRPlate; my @ProjectID; my @fastqpath_sampledir;
	my @SourcePCRPlate_Neph; my @SampleID_Neph; my @SampleID_DupCheck;
	my @Treatment_Neph;	my @VialLab_Neph; 
	my @ExtractBatch_Neph; my @Descrip_Neph;
	my @filename_R1; my @filename_R2; my @copystatus;
	my @Unique; my @fastqpath;
	
#Take in Directory from Command Line and format for CWD
	print "\nHave you downloaded the Microbiome manifest from LIMS - Will be placed in the AnalysisManifest folder of Project (Y or N) ";
	#	my $ManiAns = <STDIN>; chomp $ManiAns;
	#	if($ManiAns =~ "N") {print "\n**Generate Microbiome Manifest for Project from LIMS, then re-run**\n";
	#		exit;}
	print "Do you only need the manifest (1) or do you need to create the manifest and move FASTQ files (2)? ";
	#	my $man_only = <STDIN>; chomp $man_only;
	print "Do you want to include study samples (Y or N)? ";
	#	my $StudyAns = <STDIN>; chomp $StudyAns;
	print "What is the date to assoicate with analysis (04_10_17)? ";
	#	my $date = <STDIN>; chomp $date;
	print "What is the name of your project? (NP0452-MB3) ";
	#	my $ProjName = <STDIN>; chomp $ProjName;
	
	###Testing
	my $man_only = 2;
	my $StudyAns = "Y";
	my $date = "08_28_19";
	my $ProjName = "NP0084-MB4"; 

#Call subroutines
	qc_mb_dir(\$ProjName, \$MRName, \$QCPath, \$ManPath);
		$CWD = $QCPath;
	Neph_Dir(\$Nephpath, $date); 
		$CWD = $ManPath;
	read_MB_Man($StudyAns, $ProjName, $ManPath, \@SampleID, \@ExternalID, \@SampleType, \@ExtractionBatchID, \@SourcePCRPlate, \@RunID, \@ProjectID);
	dupsample_check(@SourcePCRPlate,@SampleID,\@SampleID_DupCheck,\@Unique);
	neph_variables(@SampleID_DupCheck, @ExternalID, @SampleType, @SourcePCRPlate, \@SourcePCRPlate_Neph, \@SampleID_Neph, \@Treatment_Neph, \@VialLab_Neph);
		$CWD = $Nephpath;
	FastQ_FilePath($Nephpath, $man_only, @SampleID_DupCheck, @Unique, \@filename_R1, \@filename_R2, \@copystatus, \@fastqpath_sampledir, \@fastqpath);
	FastQ_FileMove($Nephpath, $man_only, @RunID, @ProjectID, @SampleID, \@filename_R1, \@filename_R2, \@copystatus, \@fastqpath_sampledir, \@fastqpath);
	#FastQ_Man($Nephpath, $date, $ProjName, @SampleID_Neph, @Treatment_Neph, @VialLab_Neph, @SourcePCRPlate_Neph, @ExtractionBatchID,@filename_R1, @filename_R2, @copystatus, @fastqpath_sampledir);
	
	
######################################################################################
								##Subroutines##
######################################################################################

#Creates variables with directory names of the Manifest file location, and QIIME directory location
sub qc_mb_dir {

	#Initiate variables
	my ($ProjName, $MRName, $QCPath, $ManPath)=@_;
	my $tempQC; my $tempMan;
	
	$$MRName = $$ProjName;
	$$MRName =~ s/NP//g;
	$$MRName =~ s/-.*$//g;
	$$MRName = "MR-$$MRName";

	#Create pathway for QIIME Folder (QCPath) and Manifest (Manpath)
	$$QCPath = "T:\\DCEG\\CGF\\Laboratory\\Projects\\$$MRName\\$$ProjName\\QC Data";
	$$ManPath = "T:\\DCEG\\CGF\\Laboratory\\Projects\\$$MRName\\$$ProjName\\Analysis Manifests";
}

#Creates Nephele Directory, if necessary using variables created in QC_MB_DIR
sub Neph_Dir {
	
	#Initialize variables
	my ($Nephpath, $date) = @_;
	my $nephele = "nephele";
	
	#Make Directories for nephele (unless already created)
	mkdir $nephele unless -d $nephele;

	#Create new Nephele directory
	my $nephele_vers = "$date\_input";
	$CWD .= "\\$nephele";
	mkdir $nephele_vers unless -d $nephele_vers;
	$$Nephpath = "$CWD\\$nephele_vers";
}

#Reads in Microbiome Manifest from LIMS, and parses for data
sub read_MB_Man {
	
	#Initialize Variables
	my ($StudyAns, $ProjName, $ManPath, $SampleID, $ExternalID, $SampleType, $ExtractionBatchID, $SourcePCRPlate, $RunID, $ProjectID) =@_;
	my $manifile=""; my @filedata; my @QCdata;

	#Create a loop for each Study included, to read in manifest and save data into array variables
	$CWD = $ManPath;
		
	#Create Manifest File name from Project Info;
	$manifile = $ProjName; $manifile =~ s/\\//g;
	$manifile .= "-manifest_test.txt";
		
	#If filename not provided, give error message and close
	unless (open(READ_FILE, $manifile)) {
		print "Cannot open file $manifile \n\n";
		exit;
	}
	
	#Confirmations
	print "\n\n******************************\nReading in manifest file\n";

	#Read in the file, and close
	@filedata= <READ_FILE>;
	close READ_FILE;
		
	#Create database with ("Y") or without ("N") study samples
	if (lc $StudyAns eq lc "Y") {
		foreach my $line (@filedata) {
			push (@QCdata, $line);
			next; 
		}
	} else{ 
		for(my $i=0; $i < @filedata; $i++) {
			if ($filedata[$i] =~ m/Study/) {
				next;
			} elsif($filedata[$i] =~ m/SACCOMANNOFLUID/){
				next;
			} elsif($filedata[$i] =~ m/ORALRNS_TEBUFFER/){
				next;
			} elsif($filedata[$i] =~ m/ExtractionReplicate/){
				push(@QCdata,$filedata[$i-1]); ##To include the study matches for replicate sample
				push(@QCdata,$filedata[$i]);
			} else {
				push (@QCdata, $filedata[$i]);
				next;
			}
		}
	} 
	shift @QCdata;

	#Create arrays with sample line data separated by tabs
	foreach (@QCdata) {
		my @columns = split('\t',$_);
		if(length $columns[6]>0){
			push(@SampleID, $columns[0]);
			push(@ExternalID, $columns[1]);
			push(@SampleType, $columns[2]);
			push(@ExtractionBatchID, $columns[3]);
			push(@SourcePCRPlate, $columns[4]);
			push(@RunID,$columns[5]);
			push(@ProjectID,$columns[6]);
		} else {next;}
	}
}

#Dup Check
sub dupsample_check{
	my ($SourcePCRPlate, $SampleID,$SampleID_DupCheck, $Unique)=@_;
	my $n=0;
	
	#Samples may have duplicate ID names and need to be individualized
	$n=0; my $count=0;
	foreach my $line1 (@SampleID){
		foreach my $line2 (@SampleID){
			if($line1=~$line2){
				$count++;
			} 
		}
		
		if($count>1){
			$Unique[$n]="N";
			$SampleID_DupCheck[$n]=$SampleID[$n];
			$SampleID_DupCheck[$n].="-$SourcePCRPlate[$n]"; #add - PCR plate ID.location to sample ID, as this will be unique for the duplicates
			$SampleID_DupCheck[$n] =~ s/_/-/g;
		} else {
			$Unique[$n]="Y";
			$SampleID_DupCheck[$n]=$SampleID[$n];
		}
		$n++;
		$count=0;
	}	
}

#Creates variables needed for Neph Manifest
sub neph_variables{
	
	#Initialize variables
	my ($SampleID_DupCheck, $ExternalID, $SampleType, $SourcePCRPlate, $SourcePCRPlate_Neph, $SampleID_Neph, $Treatment_Neph, $VialLab_Neph)=@_;
 	my @tempSampleID; my $n = 0;
	
	#Format Sample IDs
	foreach my $line (@SampleID_DupCheck) {
		my $templine=$SampleID_DupCheck[$n];
		
		if($templine =~ m/NTC/){
			$templine = "NTC";
		} elsif($templine =~ m/Water/){
			$templine = "Water";
		} 
		$templine .= ".$SourcePCRPlate[$n]";
		
		$templine =~ s/_/./g; $templine =~ s/-/./g;
		$templine =~ s/\.0/0/g;
		$templine =~ s/\.1/1/g;
		
		push(@SampleID_Neph, $templine);
		$n++;
	}
	
	#Remove _ from Source PCR Plate and save PB# as AssayPlate for Nephele
	foreach my $line (@SourcePCRPlate) {
		$line =~ s/\..*//g;
		push (@SourcePCRPlate_Neph, $line);
	}	

	#Format treatment groups and assign
	foreach my $line (@SampleType){
		if($line =~ /ExtractionReplicate/){
			$line = "Extraction.Replicate";
		} elsif($line =~ /ExtractionBlank/){
			$line = "Extraction.Blank";
		} elsif($line =~/PCRNTCBlank/){
			$line = "PCRNTC";
		} elsif($line=~/PCRWaterBlank/){
			$line = "PCRWATER";
		} elsif($line=~/artificialcolony/){
			$line = "artificial.colony";
		} push (@Treatment_Neph, $line);
	}

	#Set External ID as Vial Label and format with ".", remove "_"
	foreach my $line (@ExternalID){
		$line =~ s/_/./g;
		push (@VialLab_Neph, $line);
	}
}

#Creates paths for the FastQfiles
sub FastQ_FilePath{
	
	#Initialize Variables
	my ($RunID, $ProjectID, $SampleID, $filename_R1, $filename_R2, $fastqpath_sampledir, $fastqpath) =@_;
	my @foldernames;  
	my $a=0; my $b = 0; my $c=0; my $n=0; 
	my $FQPath; my $FQPath_sampledir;

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
		$FQPath = "T:\\DCEG\\CGF\\Sequencing\\Illumina\\MiSeq\\PostRun_Analysis\\Data\\$tempRun\\CASAVA\\L1\\Project_$tempProj\\";
		$FQPath =~ s/_MB/-MB/g;
		$FQPath_sampledir=$FQPath; $FQPath_sampledir.="\\$line\\";
		push (@fastqpath_sampledir, $FQPath_sampledir);
		push (@fastqpath, $FQPath);
		$n++;
	}
	
	#Run through each directory, find paths for FASTQ Files
	foreach my $line (@fastqpath_sampledir){
	
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
}

#Creates paths for the FastQfiles and copies them into Nephele folder
sub FastQ_FileMove{
	
	#Initialize Variables
	my ($Nephpath, $man_only, $SampleID_DupCheck, $Unique, $filename_R1, $filename_R2, $fastqpath_sampledir, $fastqpath) =@_;
	my @foldernames;  
	my $a=0; my $b = 0; my $c=0; my $n=0; 

	#Create copies and move FASTQ File to Nephele Folder
	if($man_only==2){
		#Confirmations
		print "\n\n******************************\nMoving FastQ files\n";		
		
		#Create folder for FASTQ Files
		my $fastqdir = "FASTQ";
		mkdir $fastqdir unless -d $fastqdir;
		my $fastqnewpath= "$CWD\\$fastqdir";
		opendir (NDIR, $Nephpath);
		
		#Move files
		foreach my $line(@fastqpath_sampledir) {
			
			#Open directory with FastQ folders
			$CWD = $line;
			my $tempfile_R1 = $filename_R1[$a];
			my $tempfile_R2 = $filename_R2[$b];
			
			if (-e $line){
				copy ($tempfile_R1, $fastqnewpath);
				copy ($tempfile_R2, $fastqnewpath);
			
				if($Unique[$c]=~"N"){
					#Need to generate unique to ID for replicates that do not have plate or location id 
					#Grab all characters after the _ to eliminate the original sample ID name
					my $fastq_seqtag_R1=$tempfile_R1; $fastq_seqtag_R1 =~ s/^[^_]*_/_/; 
					my $fastq_seqtag_R2=$tempfile_R2; $fastq_seqtag_R2 =~ s/^[^_]*_/_/;

					my $fastq_nameupdate_R1= $SampleID_DupCheck[$c];
					$fastq_nameupdate_R1.=$fastq_seqtag_R1;
					rename ("$fastqnewpath\\$tempfile_R1","$fastqnewpath\\$fastq_nameupdate_R1");
					
					my $fastq_nameupdate_R2= $SampleID_DupCheck[$c];
					$fastq_nameupdate_R2.=$fastq_seqtag_R2;
					rename ("$fastqnewpath\\$tempfile_R2","$fastqnewpath\\$fastq_nameupdate_R2");

					$CWD = $fastqpath[$c]; #To avoid problems with file naming in Q2, create a new folder and move renamed files to the folder
					mkdir ("Sample_$SampleID_DupCheck[$c]") unless -d $SampleID_DupCheck[$c];
					copy ("$fastqnewpath\\$fastq_nameupdate_R1","$fastqpath[$c]\\Sample_$SampleID_DupCheck[$c]");
					copy ("$fastqnewpath\\$fastq_nameupdate_R2","$fastqpath[$c]\\Sample_$SampleID_DupCheck[$c]");
				}
				$c++;
			} else{
				$c++;
				print "Failed transfer of $tempfile_R1 and $tempfile_R2\n";
			}
			$a++; $b++;
		}
		closedir(NDIR);
		print "\nCompleted moving FastQ files";
	}
}


#Creates the Manifest for Nephele input
sub FastQ_Man {
	#Initialize Variables
	my ($Nephpath, $date, $ProjName, $SampleID_Neph, $Treatment_Neph, $VialLab_Neph, $SourcePCRPlate_Neph, 
		$ExtractionBatchID, $filename_R1, $filename_R2, $copystatus, $fastqpath_sampledir)= @_;
	my $n =0; 
	
	#Create headers for text file
	my @headers = ("\#SampleID", "ForwardFastqFile", "ReverseFastqFile", "TreatmentGroup", "VialLabel", "AssayPlate", "ExtractionBatch", "Description");
	my @statusheadters = ("Copy Status", "Unique", "SampleID", "FASTQ Path",  "File name R1", "File name R2", "PlateID");
	
	#Create Nephele txt file in Nephele Directory
	$CWD = $Nephpath; 
	my $manfile= "$ProjName\_Nephele\_Input\_$date.txt";
	my $statfile= "$ProjName\_status\_$date.txt";

	#Confirmations
	print "\n\n******************************\nGenerating manifest and status files\n";
	
	#Print data to Nephele txt file
	open (FILE, ">$manfile") or die;
		
		#Print headers to file
		print FILE join ("\t", @headers), "\n";
		
		#Print data to manifest file
		foreach my $sample (@SampleID_Neph) {
			my @temparray;
			
			#Convert "-" in sample ID to "."
			my $temp = $SampleID_Neph[$n];
			$temp =~ s/-/./g;
			push(@temparray, $temp);
			
			#Add remaining columns
			push(@temparray, $filename_R1[$n]);
			push(@temparray, $filename_R2[$n]);
			push(@temparray, $Treatment_Neph[$n]);
			push(@temparray, $VialLab_Neph[$n]);
			push(@temparray, $SourcePCRPlate_Neph[$n]);
			push(@temparray, $ExtractionBatchID[$n]);
			print FILE join("\t",@temparray), "\n";
			$n++;
		}

	my $total = scalar @SampleID_Neph*2;
	print "\n******************************\nThere should be $total FASTQ files in the FASTQ folder\n\n";
}

exit;

##################################################################################################################
################################################# Updates ####################################################
##################################################################################################################

##6/19/17: Changed the file GREP from .gz to include 001.fastq.gz to eliminate incorrect files from being copied
##6/20/17: Added a require install of chdir
##6/21/17: Add sample type to description column to ensure it is not left blank; Add validation to RunID length to allow for partial runs
##7/6/17: Modifications to print screens
##8/4/17: Changed MR input to search, allowed for second study input
##8/6/17: Continued with 8/4 changes, fixed bugs for second and third study input
##9/11/17: Added feature to compare Study sample that pairs with Extraction Replicate
##4/23/18: Added option to only create manifest file
##12/4/18: Formatting edits to initial questions, remove testing information
##12/6/18: Disable eval of File::Copy until new perl module downloaded, add confirmations to file moving, and final file count
		# Updated Manifest subroutine to match new Nephele file parameters 
		## 1)remove Barcode and Linker Seq columns
		## 2) change all "-" in sample ID to "."
		## 3) remove code that previously removed .gz from file name of FastQ - required now
##12/13/18: Change directory name from qiime to nephele
##7/17/19: Changed name of the file, changed question for manifest only, removed project lists - multiple projects read through one manifest file, updates to fastq location, create status file to update file locations + 
##whether copying was successful or if fastq files are named uniquely
