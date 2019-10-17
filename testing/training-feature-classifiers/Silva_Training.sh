#!/bin/#!/usr/bin/env bash

#Overview:
#Create a new trained classifer, using the SILVA DB. The most updated classifer
#available for the QIIME Version 2017.11 is SILVA DB X.

#Following tutorial listed at https://docs.qiime2.org/2018.11/tutorials/feature-classifier/

. /DCEG/Projects/Microbiome/CGR_MB/MicroBiome/sc_scripts_qiime2_pipeline/dev/training-feature-classifiers/config.sh

module load miniconda/3
source activate qiime2-2017.11

#dir
parent_path=${parent_dir}
training_path=${parent_dir}${training_dir}
ref_path=${ref_dir}

#Store config in training dir to review parameters later, if needed
config_path="/DCEG/Projects/Microbiome/CGR_MB/MicroBiome/sc_scripts_qiime2_pipeline/dev/training-feature-classifiers/config.sh"
config_store="${training_path}/config_stored.sh"

cmd="cp -p ${config_path} ${config_store}"
eval $cmd

#Pull fasta and taxonomy files
fasta_path=${ref_path}${fasta_file_path}
tax_path=${ref_path}${tax_file_path}

#Import as Q2 artifacts
#NOTE: 2017.10 version does not have --input-format feature shown in tutorial, but
#instead has "source-format"
fasta_file_qza="${training_path}${database}_${percent_sim}_${region}.qza"
tax_file_qza="${training_path}ref-taxonomy.qza"

if [ ! -f ${fasta_file_qza} ]; then
  cmd="qiime tools import \
    --type 'FeatureData[Sequence]' \
    --input-path ${fasta_path} \
    --output-path ${fasta_file_qza}"

  echo $cmd
  eval $cmd
fi

if [ ! -f ${tax_file_qza} ]; then
  cmd="qiime tools import \
      --type 'FeatureData[Taxonomy]' \
      --source-format HeaderlessTSVTaxonomyFormat \
      --input-path ${tax_path} \
      --output-path ${tax_file_qza}"
  echo $cmd
  eval $cmd
fi

# #Extract referece reads
# #NOTE: Using the primer reads we can optimze by extracing reads from the reference
# #DB based on matches to the primer pair, and then slicing in 120 bases. Will be tested in
# #tandom to "non-optimzed" method
#
# #NOTE: The --p-trunc-len parameter used to trim reference sequences if query sequences
# #are trimmed to this same length or shorter. Paired-end sequences that successfully join will typically be variable in length.
# #For classification of paired-end reads and untrimmed single-end reads, Q2 recommends training a classifier on sequences that
# #have been extracted at the appropriate primer sites, but are not trimmed.
#
# #NOTE: The example command  uses the min-length and max-length parameters to exclude simulated amplicons
# # that are far outside of the anticipated length distribution using those primers. #Such amplicons are likely non-target hits
# #and should be excluded. The min-length parameter is applied _after_ the trim-left and trunc-len parameters, and max-length _before_,
# #so be sure to set appropriate settings to prevent valid sequences from being filtered out.
#
# ref_seq_qza="${training_dir}ref-seqs.qza"
#
# if [ ! -f ${ref_seq_qza} ]; then
#   cmd="qiime feature-classifier extract-reads \
#       --i-sequences ${fasta_file_qza} \
#       --p-f-primer GTGCCAGCMGCCGCGGTAA \
#       --p-r-primer GGACTACHVGGGTWTCTAAT \
#       --p-trunc-len 120 \
#       --p-min-length 100 \
#       --p-max-length 400 \
#       --o-reads ${ref_seqs_qza}"
#   echo $cmd
#   eval $cmd
# fi
#
# #Train the classifier
# classifier_qza="${training_dir}classifier.qza"
#
# if [ ! -f ${classifier_qza} ]; then
#   cmd="qiime feature-classifier fit-classifier-naive-bayes \
#       --i-reference-reads ${ref_seq_qza} \
#       --i-reference-taxonomy ${tax_file_qza} \
#       --o-classifier ${classifier_qza}"
#   echo $cmd
#   eval $cmd
# fi
#
# #Test the classifier
# taxonomy_qza="${training_dir}taxonomy.qza"
# taxonomy_qzv="${training_dir}taxonomy.qzv"
#
# if [ ! -f ${classifier_qza} ]; then
#   cmd="qiime feature-classifier classify-sklearn \
#       --i-classifier ${classifier_qza} \
#       --i-reads ${rep_seqs_dir} \
#       --o-classification ${taxonomy_qza}"
#     echo $cmd
#     eval $cmd
# fi
#
# if [ ! -f ${taxonomy_qzv} ]; then
#   cmd="qiime metadata tabulate \
#     --m-input-file ${taxonomy_qza} \
#     --o-visualization ${taxonomy_qzv}"
#     echo $cmd
#     eval $cmd
# fi
