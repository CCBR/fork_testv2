#!/usr/bin/env python3

import shutil
import zipfile
import os
import numpy as np

#Directory paths
path_exec="/DCEG/CGF/Bioinformatics/Production/Microbiome/testing/2.0_acceptance/sample_concordance_tests"
path_vers=["/2017.11/2017.11_v1.0/Output","/2017.11/2017.11_v2.0"]
inputfile="compare_files.txt"

import pandas as pd 
  
# reading comparison file 
df = pd.read_csv(inputfile, sep="\t",header=0) 

#include test names based off flag
include_list=df.ix[:,1].tolist()
test_name=[]
for i in range(0,len(include_list)):
	if include_list[i]=='Y':
		#test_name=df.ix[:,0].tolist()
		test_name.append(df.ix[i,0])
versions=['v1','v2']

#Flags
move_files='N'
analyze_files='N'

#Functions
def file_manage(x):

	for i in range(0,len(versions)):
		path_out=path_exec+'/Output/'+versions[i]
		
		subpath=df.loc[df.test_name == x, versions[i]+'_path'].values[0]
		filename=df.loc[df.test_name == x, versions[i]+'_file'].values[0]
		path_unzip=path_exec+path_vers[i]+'/'+subpath+'/'+filename
		
		#Unzip QZA/QVA files
		with zipfile.ZipFile(path_unzip, 'r') as zipObj:
			zipObj.extractall(path_out)
			
		path_final=path_out+'/data/'
		if not os.path.exists(path_final):
			os.makedirs(path_final)
	
		target=df.loc[df.test_name == x, 'target_files'].values[0]
	
		#Rename final files; convert biom file
		for root, dirs, files in os.walk(path_out):
			for file in files:
				file_final=path_final+x+'_'+target

				if file.startswith(target):
					shutil.copyfile(os.path.join(root, file), file_final)
				
					if file.endswith(".biom"):
								mycmd='biom convert -i '+file_final+' -o '+file_final+'.txt'+' --to-tsv'
								os.system(mycmd)

def compare_files(x):
	file1=path_out=path_exec+'/Output/'+versions[0]+'/data/'+x+"_"+df.loc[df.test_name == x, 'target_files'].values[0]
	file2=path_out=path_exec+'/Output/'+versions[1]+'/data/'+x+"_"+df.loc[df.test_name == x, 'target_files'].values[0]

	#skip biom files, use the converted text file
	if file1.endswith('.biom'):
		file1=file1+'.txt'
		file2=file2+'.txt'
	mycmd='diff '+file1+' '+file2
	echoeval = 'echo '+mycmd+' >> Output/comparison.txt; eval '+mycmd+' >> Output/comparison.txt'
	os.system(echoeval)

#Move and unzip the original files
if 'Y' in move_files:
	for x in versions:
		path_out=path_exec+'/Output/'+x
		if not os.path.exists(path_out):
			os.makedirs(path_out)

	for x in test_name:
		file_manage(x)

#Analyze each output
if 'Y' in analyze_files:
	for x in test_name:
		compare_files(x)