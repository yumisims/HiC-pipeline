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
A yaml configuration file need to be completed if you choose this option. The yaml file format is tailored to the VGP analysis pipeline in GRIT processing other analysises, such as break10x and bionano. If you only run hic analysis please only alter the HiC session in the yaml file.

To fill in sample information.

```
  assembly:
  level: scaffold
  sample: fAnaAna1
  class: fish
  dbVersion: "1"
  asmVersion: test
  gevalType: VGP
  reference: /lustre/scratch115/teams/grit/users/yy5/hic/fish/ref/ref.fa
 ```
Prepare a list of hic data file

```
hic:
    hicreads: /lustre/scratch115//dove.fofn
```
 
