# HiC-pipeline user guide

## software and dependencies 

### (1) Install conda and snakemake
```
conda activate snake_env
conda install -c bioconda snakemake
```
### (2) software
* samtools
* pretext
* bwa
* bamToBed
* picard
* bammarkduplicates2

### usuage
The pipeline can be run under snakemake conda environment or without:

#### To run the pipeline under conda environment
A yaml configuration file need to be completed if you choose this option. 
