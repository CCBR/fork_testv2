#!/usr/bin/env python3

import shutil
import zipfile
import os
import numpy as np

#Directory paths
path_exec="/DCEG/CGF/Bioinformatics/Production/Microbiome/testing/2.0_acceptance/sample_concordance_tests"
path_v1="/2017.11/2017.11_v1.0/Output/qza_results/"
path_v2="/2017.11/2017.11_v2.0/"

#src and destination file names
files_v1=["table_dada2_qza_merged_parts_final/table_dada2_merged_final_filt.qza","repseqs_dada2_qza_merged_parts_final/repseqs_dada2_merged_final.qza","core_metrics_results/bray_curtis_distance_matrix.qza","taxonomy_qza_results/taxonomy_greengenes.qza","taxonomy_qza_results/taxonomy_silva.qza"]
files_v2=["denoising/feature_tables/merged_filtered.qza","denoising/sequence_tables/merged.qza","diversity_core_metrics/bray-curtis_dist.qza","taxonomic_classification/classify-sklearn_gg-13-8-99-nb-classifier.qza","taxonomic_classification/classify-sklearn_silva-119-99-nb-classifier.qza"]
files_rename=["features_filtered","seq","bray_curtis","tax_gg","tax_silva"]
files_target=[".biom","dna-sequences.fasta","distance-matrix.tsv",".tsv",".tsv"]

#Flags
move_files='N'
analyze_files='Y'

#Functions
def file_manage(path_v,filename,version,count):
	path_unzip=path_exec+path_v+filename
	path_out=path_exec+'/Output/'+files_rename[count]+'_'+version
	path_final=path_exec+'/Output/_final'
				
	if not os.path.exists(path_out):
		os.makedirs(path_out)
	
	with zipfile.ZipFile(path_unzip, 'r') as zipObj:
	   zipObj.extractall(path_out)
	   
	if not os.path.exists(path_final):
		os.makedirs(path_final)
	   
	for root, dirs, files in os.walk(path_out):
		for file in files:
			file_final=path_final+'/'+files_rename[count]+'_'+version+'_'+file
			
			if file.endswith(files_target[count]):
				shutil.copyfile(os.path.join(root, file), file_final)
				
				if file.endswith(".biom"):
						mycmd='biom convert -i '+file_final+' -o '+file_final+'.txt'+' --to-tsv'
						os.system(mycmd)

#Move and unzip the original files
if 'Y' in move_files:
	count=0
	for x in files_v1:
		file_manage(path_v1,x,"2017v1",count)
		count=count+1
	
	count=0
	for x in files_v2:
		file_manage(path_v2,x,"2017v2",count)
		count=count+1

#Analyze each output
save_files=[]
if 'Y' in analyze_files:
	path_final=path_exec+'/Output/_final'

	for root, dirs, files in os.walk(path_final):
		for file in files:
			if not file.endswith(".biom"):
				save_files=np.append(save_files,file)
	
	save_files.sort()	
	
	for i in range(0,len(files_rename)*2,2):
		mycmd='diff '+path_final+'/'+ save_files[i]+' '+path_final+'/'+ save_files[i+1]
		echoeval = 'echo '+mycmd+' >> Output/comparison.txt; eval '+mycmd+' >> Output/comparison.txt'
		os.system(echoeval)