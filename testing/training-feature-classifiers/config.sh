#Overview:
#Create a new trained classifer, using the SILVA DB. The most updated classifer
#available for the QIIME Version 2017.11 is SILVA DB X.

parent_dir="/DCEG/Projects/Microbiome/CGR_MB/MicroBiome/sc_scripts_qiime2_pipeline/dev/training-feature-classifiers/"
training_dir="silva_132_99_16S_20191016/"
ref_dir="/DCEG/Projects/Microbiome/CGR_MB/MicroBiome/sc_scripts_qiime2_pipeline/working/Resources/Silva_132_release/"

fasta_file_path="SILVA_132_QIIME_release/rep_set/rep_set_16S_only/99/silva_132_99_16S.fna" #fasta file (using reference sequences clustered at 99% similarity)
tax_file_path="SILVA_132_QIIME_release/taxonomy/16S_only/99/taxonomy_all_levels.tsv" #must be TSV format

database="silva_132"
percent_sim="99"
region="16S"

rep_seqs_dir="/DCEG/Projects/Microbiome/CGR_MB/MicroBiome/sc_scripts_qiime2_pipeline/working/Resources/rep-seqs.qza"
#downloaded from: https://data.qiime2.org/2018.11/tutorials/training-feature-classifiers/rep-seqs.qza
