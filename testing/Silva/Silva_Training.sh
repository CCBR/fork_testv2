#!/bin/#!/usr/bin/env bash

#Overview:
#Create a new trained classifer, using the SILVA DB. The most updated classifer
#available for the QIIME Version 2017.11 is SILVA DB X.

#Following tutorial listed at https://docs.qiime2.org/2018.11/tutorials/feature-classifier/

module load miniconda/3
source active qiime2-2017.11


#Dir
parent_dir="/drives/c/Program Files/Git/Coding/microbiome_workflow/testing/Silva/"

cmd="mkdir -p 'training-feature-classifiers'"
eval $cmd
cmd="cd 'training-feature-classifiers'"
eval $cmd

#Download Silva DB
ref_dir="/drives/t/DCEG/Projects/Microbiome/CGR_MB/MicroBiome/sc_scripts_qiime2_pipeline/working/Resources/Silva_132_release"

#Pull fasta file (using reference sequences clustered at 99% similarity) and taxonomy file (includes all levels)
fasta_file=$ref_dir+"SILVA_132_QIIME_release/rep_set/rep_set_16S_only/99/silva_132_99_16S.fna"
tax_file=$ref_dir+"SILVA_132_QIIME_release/taxonomy/16S_only/99/taxonomy_all_levels.txt"


qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path 85_otus.fasta \
  --output-path 85_otus.qza

qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path 85_otu_taxonomy.txt \
  --output-path ref-taxonomy.qza
