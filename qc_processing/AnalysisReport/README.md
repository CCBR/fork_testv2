# CGR QIIME2 Microbiome Report Generation

This is the Cancer Genomics Research Laboratory's (CGR) microbiome report generation tool. This tool relies on the QIIME2 pipeline (which utilizes [QIIME2](https://qiime2.org/)) to classify sequence data, determine taxonomic relationships, and link metadata provided by the user. It determines alpha and beta diversity, qc run metrics, and provides an output report in Word format.

## How to run

### Input requirements

- Successful run of QIIME2v2.0 pipeline
- config_report.yml
- run_report.sh

### Run the pipeline

Production run: Copy `run_report.sh` and `config.yaml` to your directory, edit as needed, then execute the script.

## Configuration details

- out_dir: full path to desired output directory (note that production runs are stored at `/DCEG/Projects/Microbiome/Analysis/`)
- exec_dir: full path to pipeline (e.g. Snakefile)
- qiime_dir: full path to the QIIME2 output directory
- manifest_dir: full ptah to the manifest_qiime2.tsv file to use as metadata
- seq_depth: numeric value to set as the sequencing depth
- sample_depth: numeric value to determine the sampling depth
- include_reps: either 'Y' or 'N' for whether or not to include sample replicates
- ProjectID: 'NP0493-MB1, NP0493-MB2'
- pipeline_ver: only two versions permitted (2017.11 or 2019.1)
- extract_CGR: either 'Y' or 'N' for whether extraction was done at CGR
- pcr_CGR: either 'Y' or 'N' for whether PCR was done at CGR
- var_list: metadata categories that are included in manifest file as column headers, to be analyzed wtihin the report
	
## Manifest Requirements
- SampleID
- SampleType
- Run-ID
- Source PCRPlate (if PCR information available)
- ExtractionID (if extraction informatio available)

## Workflow summary
1. Package management:
  - Determine if packages are dowloaded and loaded
  - If any are missing install and/or load
2. Read in QIIME2 artifacts and create PhyloSeq object
3. Filter non-bacterial species, filter based on sequencing depth, filter based on sample depth
4. Perform alpha and beta diversity analysis
5. Generate QC Report
6. Save report and worktable to `<out_dir>/report`

## Dependencies
The following packages are required:
- Yaml
- rmarkdown
- biomformat
- ape
- magrittr
- ggplot2
- GGally
- knitr
- phyloseq
Additionally, [pandoc](https://rmarkdown.rstudio.com/docs/articles/pandoc.html) is required as either a standalone feature, or within RStudio

## Example output directory structure
- Within parent directory `<out_dir>/report` defined in config.yaml
- Example output structure:
├── Data
│   ├── summary_postfilt_sampletype.txt
│   ├── summary_postfilt.txt
│   ├── summary_prefilter_sampletype.txt
│   └── summary_prefilter.txt
├── finalreport_2020-01-09.docx
├── Graphs
│   ├── alphadiv_AdditionalAttributes.tiff
│   ├── alphadiv_CollectionMethod.tiff
│   ├── alphadiv_extbatch.tiff
│   ├── alphadiv_pcrbatch.tiff
│   ├── alphadiv_Primaryphenotype.tiff
│   ├── alphadiv_sampletype.tiff
│   ├── alphadiv_seqbatch.tiff
│   ├── alphadiv_TumorAttribute.tiff
│   ├── bray_extbatch_samples.tiff
│   ├── bray_pcrbatch_samples.tiff
│   ├── bray_sampletype_all.tiff
│   ├── bray_seqbatch_samples.tiff
│   ├── nonbacterial.tiff
│   ├── postfilt_seqdepth.tiff
│   ├── postscale_rarecurve.tiff
│   ├── prefilt_seqdepth.tiff
│   ├── prescale_rarecurve.tiff
│   ├── wunifrac_extbatch_samples.tiff
│   ├── wunifrac_pcrbatch_samples.tiff
│   ├── wunifrac_sampletype_all.tiff
│   └── wunifrac_seqbatch_samples.tiff
└── workspace_2020-01-09.RData


------------------------------------------------------------------------------------

## Notes 