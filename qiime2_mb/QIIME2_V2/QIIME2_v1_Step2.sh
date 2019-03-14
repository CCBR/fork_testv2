#!/bin/bash

. ./QIIME2_v1_Global.sh

for manifest_file_split_parts_fastq_import in $(ls -v $MANIFEST_FILE_SPLIT_PARTS_FASTQ_IMPORT_DIR/*); do
	
	#echo $manifest_file_split_parts_fastq_import
	pe_manifest=$manifest_file_split_parts_fastq_import
	echo $pe_manifest
	
	part=$(basename $manifest_file_split_parts_fastq_import | cut -f1 -d'.' | rev | cut -f1 -d'_' |rev)
	echo "Part $part"
	
	demux_qza_split_part=${demux_qza_split_parts_dir}/${demux_param}_${part}.qza
	
	demux_qzv_split_part=${demux_qzv_split_parts_dir}/${demux_param}_${part}.qzv
	
	table_dada2_split_part=${table_dada2_qza_split_parts_dir}/${table_dada2_param}_${part}.qza
	
	repseqs_dada2_split_part=${repseqs_dada2_qza_split_parts_dir}/${repseqs_dada2_param}_${part}.qza
	
	cmd="qsub -cwd \
		-pe by_node 10 \
		-q ${QUEUE} \
		-o ${log_dir_stage_2}/stage2.1_qiime2_${part}.stdout \
		-e ${log_dir_stage_2}/stage2.1_qiime2_${part}.stderr \
		-N stage2_qiime2_${part} \
		-S /bin/sh \
		${SCRIPT_DIR}/substeps/QIIME2_v1_Step2.1.sh \
		$demux_qza_split_part \
		$demux_qzv_split_part \
		$table_dada2_split_part \
		$repseqs_dada2_split_part \
		$pe_manifest"
	
	echo $cmd
	eval $cmd
	echo
done

#Determine the total number of runs
TOTAL_RUNS=$(ls -v $MANIFEST_FILE_SPLIT_PARTS_FASTQ_IMPORT_DIR/* | wc -l)
echo $TOTAL_RUNS
echo

#If there is more than one flowcell run:
if [$TOTAL_RUNS -gt 1]; then 
	cmd="qsub -cwd \
		-pe by_node 10 \
		-q ${QUEUE} \
		-o ${log_dir_stage_2}/stage2.2_qiime2.stdout \
		-e ${log_dir_stage_2}/stage2.2_qiime2.stderr \
		-N stage2_qiime2_${part} \
		-S /bin/sh \
		${SCRIPT_DIR}/substeps/QIIME2_v1_Step2.2.sh"
	echo $cmd
	eval $cmd
	echo
#If there is only one flow cell, create a copy with same name as "multiple":
else 
	output_table_merged_final_qza=${table_dada2_qza_merged_parts_final_dir}/${table_dada2_merged_final_param}.qza
	output_repseqs_merged_final_qza=${repseqs_dada2_qza_merged_parts_final_dir}/${repseqs_dada2_merged_final_param}.qza
	cmd="cp ${table_dada2_qza_split_parts_dir}/${table_dada2_param}_${part1}.qza ${output_table_merged_final_qza}"
	echo $cmd
	eval $cmd

	cmd="cp ${repseqs_dada2_qza_split_parts_dir}/${repseqs_dada2_param}_${part1}.qza ${output_repseqs_merged_final_qza}"
	echo $cmd
	eval $cmd
	echo "All Done"
done 