#!/bin/bash

. ./QIIME2_v1_Global.sh

##################################################################################################################
input_repseqs_merged_final_qza=${repseqs_dada2_qza_merged_parts_final_dir}/${repseqs_dada2_merged_final_param}.qza
output1_qza=${phylogeny_qza_dir}/${output1_param}.qza
output2_qza=${phylogeny_qza_dir}/${output2_param}.qza
output3_qza=${phylogeny_qza_dir}/${output3_param}.qza
output4_qza=${phylogeny_qza_dir}/${output4_param}.qza

cmd="qsub -cwd \
	-pe by_node 10 \
	-q ${QUEUE} \
	-o ${log_dir_stage_4}/stage4.1_qiime2.stdout \
	-e ${log_dir_stage_4}/stage4.1_qiime2.stderr \
	-N stage4.1_qiime2 \
	-S /bin/sh \
	${SCRIPT_DIR}/QIIME2_v1_Step4.1.sh \
	$input_repseqs_merged_final_qza \
	$output1_qza \
	$output2_qza \
	$output3_qza \
	$output4_qza"
	
echo $cmd
eval $cmd
echo

##################################################################################################################
input_table_merged_final_qza=${table_dada2_qza_merged_parts_final_dir}/${table_dada2_merged_final_param}.qza
input_rooted_tree_qza=${phylogeny_qza_dir}/${output4_param}.qza
output_dir=$core_metrics_output_dir
Manifest_File=$MANIFEST_FILE_qiime2_format
sampling_depth=$sampling_depth
alpha_rarefaction_qzv=${rarefaction_qzv_dir}/${rarefaction_param}.qzv
max_depth=${max_depth}

rm -rf ${output_dir}

cmd="qsub -cwd \
	-pe by_node 10 \
	-q ${QUEUE} \
	-o ${log_dir_stage_4}/stage4.2_qiime2.stdout \
	-e ${log_dir_stage_4}/stage4.2_qiime2.stderr \
	-N stage4.2_qiime2 \
	-S /bin/sh \
	${SCRIPT_DIR}/QIIME2_v1_Step4.2.sh \
	$input_table_merged_final_qza\
	$input_rooted_tree_qza \
	$output_dir \
	$Manifest_File \
	$sampling_depth \
	$alpha_rarefaction_qzv \
	$max_depth"
	
echo $cmd
eval $cmd
echo

##################################################################################################################
reference_classifier_1=${refernce_1}
reference_classifier_2=${refernce_2}
taxonomy_qza_1=${taxonomy_qza_dir}/${taxonomy_1}.qza
taxonomy_qza_2=${taxonomy_qza_dir}/${taxonomy_2}.qza
taxonomy_qzv_1=${taxonomy_qzv_dir}/${taxonomy_1}.qzv
taxonomy_qzv_2=${taxonomy_qzv_dir}/${taxonomy_2}.qzv
taxa_bar_plots_qzv_1=${taxonomy_qzv_dir}/${taxonomy_1}_bar_plots.qzv
taxa_bar_plots_qzv_2=${taxonomy_qzv_dir}/${taxonomy_2}_bar_plots.qzv

cmd="qsub -cwd \
	-pe by_node 10 \
	-q ${QUEUE} \
	-o ${log_dir_stage_4}/stage4.3_qiime2.stdout \
	-e ${log_dir_stage_4}/stage4.3_qiime2.stderr \
	-N stage4.3_qiime2 \
	-S /bin/sh \
	${SCRIPT_DIR}/QIIME2_v1_Step4.3.sh \
	$input_table_merged_final_qza \
	$input_repseqs_merged_final_qza \
	$Manifest_File \
	$reference_classifier_1 \
	$reference_classifier_2	\
	$taxonomy_qza_1	\
	$taxonomy_qza_2	\
	$taxonomy_qzv_1	\
	$taxonomy_qzv_2	\
	$taxa_bar_plots_qzv_1 \
	$taxa_bar_plots_qzv_2"
	
echo $cmd
eval $cmd
echo
echo

