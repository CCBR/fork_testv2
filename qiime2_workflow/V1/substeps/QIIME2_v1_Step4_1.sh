#!/bin/bash

#. /DCEG/Projects/Microbiome/CGR_MB/MicroBiome/ss_scripts_microbiome_analysis/sc_scripts_qiime2_pipeline/V1/QIIME2_v1_Step4.sh

input_repseqs_merged_final_qza=$1
shift
output1_qza=$1
shift
output2_qza=$1
shift
output3_qza=$1
shift
output4_qza=$1
shift
input_table_merged_final_qza=$1
shift
input_rooted_tree_qza=$1
shift
output_dir=$1
shift
Manifest_File=$1
shift
sampling_depth=$1
shift
alpha_rarefaction_qzv=$1
shift
max_depth=$1
shift

#Step 1: First, we perform a multiple sequence alignment of the sequences
##Why is this here, and not in step 3
date
echo "Here we perform a multiple sequence alignment of the sequences"
echo "INPUT = ${input_repseqs_merged_final_qza}"
echo "OUTPUT = ${output1_qza}"
echo
cmd="qiime alignment mafft \
  	--i-sequences ${input_repseqs_merged_final_qza} \
  	--o-alignment ${output1_qza}"
echo $cmd
eval $cmd
echo
date
echo "Done"
echo
echo  
  
#Step 2: Here, we mask (or filter) the alignment to remove positions that are highly variable
date
echo "Here we mask (or filter) the alignment to remove positions that are highly variable"
echo "INPUT = ${output1_qza}"
echo "OUTPUT = ${output2_qza}"
echo
cmd="qiime alignment mask \
  --i-alignment ${output1_qza} \
  --o-masked-alignment ${output2_qza}"
echo $cmd
eval $cmd
echo
date
echo "Done"
echo
echo
  
#Step 3: Here, we’ll apply FastTree to generate a phylogenetic tree from the masked alignment
date
echo "Here we’ll apply FastTree to generate a phylogenetic tree from the masked alignment"
echo "INPUT = ${output2_qza}"
echo "OUTPUT = ${output3_qza}"
echo
cmd="qiime phylogeny fasttree \
  --i-alignment ${output2_qza} \
  --o-tree ${output3_qza}"
echo $cmd
eval $cmd
echo
date
echo "Done"
echo
echo
  
#Step 4: Here, we apply midpoint rooting to place the root of the tree at the midpoint of the longest tip-to-tip distance in the unrooted tree
date
echo "Here  we apply midpoint rooting to place the root of the tree at the midpoint of the longest tip-to-tip distance in the unrooted tree"
echo "INPUT = ${output3_qza}"
echo "OUTPUT = ${output4_qza}"
echo
cmd="qiime phylogeny midpoint-root \
  --i-tree ${output3_qza} \
  --o-rooted-tree ${output4_qza}"
echo $cmd
eval $cmd
echo
date
echo "Done"
echo

#Step 5: perform Alpha and beta diversity analysis
date
echo "Here we perform Alpha and beta diversity analysis "
echo "INPUT1:Tree = ${input_rooted_tree_qza} "
echo "INPUT2:Table = ${input_table_merged_final_qza}"
echo "INPUT3:Manifest-File = ${Manifest_File}"
echo "Sampling-Depth = ${sampling_depth}"
echo "OUTPUT-DIR = ${output_dir}"
echo

cmd="qiime diversity core-metrics-phylogenetic \
	  --i-phylogeny ${input_rooted_tree_qza} \
	  --i-table ${input_table_merged_final_qza} \
	  --p-sampling-depth ${sampling_depth} \
	  --m-metadata-file ${Manifest_File} \
	  --output-dir ${output_dir}"
	  
echo $cmd
eval $cmd
echo
date
echo "Done"
echo
echo

#Step 6: Here we Export the Alpha-Diversity Artifacts as an integrated Visualization Table"

cmd="qiime metadata tabulate \
	--m-input-file ${output_dir}/observed_otus_vector.qza \
	--m-input-file ${output_dir}/shannon_vector.qza \
	--m-input-file ${output_dir}/evenness_vector.qza \
	--m-input-file ${output_dir}/faith_pd_vector.qza \
	--o-visualization ${output_dir}/alpha-table.qzv"

echo $cmd
eval $cmd
echo
date
echo "Done"
echo
echo

#Step 7: Rarefraction diversity
cmd="qiime diversity alpha-rarefaction \
  	--i-table ${input_table_merged_final_qza} \
  	--i-phylogeny ${input_rooted_tree_qza} \
  	--p-max-depth ${max_depth} \
  	--m-metadata-file ${Manifest_File} \
  	--o-visualization ${alpha_rarefaction_qzv}"
  	
echo $cmd
eval $cmd
echo
date
echo "Done"
echo
echo


