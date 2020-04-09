###
# This script generates the deliverable Report of microbiome projects, downstream of QIIME2 pipeline, for both internal
# and external usage. 
# 
# INPUT (user provided):
#  -config_deliver.yml
# 
## OUTPUT (report related):
#  -final reprot: {out_dir/report}
###

#Download and load all required libraries
check_cran_pkg <- function(pkg){
 new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
 sapply(pkg, require, character.only = TRUE)
}

packages<-c("yaml","rmarkdown","knitr")
check_cran_pkg(packages)

#Import yaml and knit document
import_yaml<-yaml.load_file("config_report.yml")

Sys.setenv(RSTUDIO_PANDOC="/DCEG/Resources/Tools/RStudio/0.98.1028/bin/pandoc")
Sys.setenv(PATH="/DCEG/Resources/Tools/RStudio/0.98.1028/bin/:${PATH}")

rmarkdown::render(input=paste(import_yaml$exec_dir,"/QIIME2_DeliverReport.Rmd",sep=""),
                  params=list(
                   out_dir=import_yaml$out_dir,
                   exec_dir=import_yaml$exec_dir,
                   ProjectID=import_yaml$ProjectID,
                   pipeline_ver=import_yaml$pipeline_ver,
                   manifest_dir=import_yaml$manifest_dir),
                  output_file = paste(import_yaml$out_dir,"/report/report_deliverable_",Sys.Date(),".docx",sep=""))
