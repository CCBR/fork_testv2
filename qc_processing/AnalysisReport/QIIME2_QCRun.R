###
# This script generates a QC Report of microbiome projects, downstream of QIIME2 pipeline, for both internal
# and external usage. 
# 
# INPUT (user provided):
#  -config_qc.yml
# 
# INPUT (needed from QIIME2 pipeline output):
#  -otu table {qiime_dir/denoising/feature_tables/merged_filtered_paired_end_demux.qza}
#  -rooted tree {qiime_dir/phylogenetics/rooted_tree.qza}
#  -taxonomy file {qiime_dir/taxonomic_classification/classify-sklearn_gg-13-8-99-nb-classifier.qza}
#  -metadata QIIME2 file {qiime_dir/manifests/manifest_qiime2.tsv}
# 
# OUTPUT (intermediary files, graphs):
#  -Graphs {out_dir/report/graphs}
#   -Pre and post filtering sequencing depth histographs for all samples
#   -Non-bacterial species abundances for all samples
#   -Alpha diversity metrics for extraction and sequencing batch, by sample type, and by any given metadata parameters
#   -Bray Curtis PCOA plots for all samples, and for study samples only by extraction batch
#   -Weighted Unifrac PCOA plots for all samples, and for study samples only by extraction batch
#  -Summary text files {out_dir/report/data} 
#   -Pre and post filtering data summary text file
#   -Pre and post filtering data summary text file, by sample type
# 
# 
# OUTPUT (report related):
#  -final reprot: {out_dir/report}
#  -workspace for analysis: {out_dir/report}
###

#Download and load all required libraries
check_cran_pkg <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  sapply(pkg, require, character.only = TRUE)
}

check_bioc_pkg<-function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  sapply(pkg, require, character.only = TRUE)
}

packages<-c("yaml","rmarkdown","biomformat", "ape", "magrittr","ggplot2","GGally", "knitr")
check_cran_pkg(packages)

packages<-c("phyloseq")
check_bioc_pkg(packages)

#Import yaml and knit document
import_yaml<-yaml.load_file("config_report.yml")

#Create dirs
rep_dirs = c("/report","/report/Data","/report/Graphs")
for (a in rep_dirs){
 if (dir.exists(paste(import_yaml$out_dir, a,sep="/"))==FALSE){
	dir.create(paste(import_yaml$out_dir, a,sep="/"))
  }
}

Sys.setenv(RSTUDIO_PANDOC="/DCEG/Resources/Tools/RStudio/0.98.1028/bin/pandoc")
Sys.setenv(PATH="/DCEG/Resources/Tools/RStudio/0.98.1028/bin/:${PATH}")

rmarkdown::render(input=paste(import_yaml$exec_dir,"/QIIME2_QCReport.Rmd",sep=""),
                  params=list(
                    out_dir=import_yaml$out_dir,
                    qiime_dir=import_yaml$qiime_dir,
                    exec_dir=import_yaml$exec_dir,
                    seq_depth=import_yaml$seq_depth,
                    sample_depth=import_yaml$sample_depth,
                    include_reps=import_yaml$include_reps,
                    var_list=import_yaml$var_list,
                    ProjectID=import_yaml$ProjectID,
                    pipeline_ver=import_yaml$pipeline_ver,
                    extract_CGR=import_yaml$extract_CGR,
                    pcr_CGR=import_yaml$pcr_CGR),
                  output_file = paste(import_yaml$out_dir,"/report/finalreport_",Sys.Date(),".docx",sep=""))
