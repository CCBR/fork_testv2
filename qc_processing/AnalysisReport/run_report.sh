#!/bin/bash

set -euo pipefail
. /etc/profile.d/modules.sh; module load R/3.5.2 pandoc/1.17.2
unset module

cmd="Rscript /DCEG/CGF/Bioinformatics/Production/Sam/report/QIIME_pipeline/report/QIIME2_QCRun.R --no-save"
echo "Command run: $cmd"
eval "$cmd"