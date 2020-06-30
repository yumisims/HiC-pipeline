# HiC-pipeline user guide

## software and dependencies 

### (1) Install conda and snakemake
```
conda activate snake_env
conda install -c bioconda snakemake
```
### (2) software
* vr-runner
download the vr-runner from github

https://github.com/VertebrateResequencing/vr-runner

Modify you PERL5LIB
```
export PERL5LIB="$HOME/git/vr-runner/modules:$PERL5LIB"
```
* samtools
* pretext
* bwa
* bamToBed
* picard
* bammarkduplicates2
* cooler

https://github.com/mirnylab/cooler


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
    hicreads: /lustre/scratch115/dove.fofn
```
The dove.fofn contains the list of unmapped HiC cram/bam files should look like:
```
/lustre/scratch116/vr/projects/vgp/build/fish/fEleEle1/Arima/crams/fEleEle1_ARIMA241127L002.cram
/lustre/scratch116/vr/projects/vgp/build/fish/fEleEle1/Arima/crams/fEleEle1_ARIMA241127L005.cram
/lustre/scratch116/vr/projects/vgp/build/fish/fEleEle1/Arima/crams/fEleEle1_ARIMA241127L007.cram
```
Amend the path to the runner script (run-hic script in runners folder)
```
tools:
  runner_path: /nfs/team135/yy5/geval_pipe_dev/runner_scripts
```
You may also need to change the cluster information in the cluster.yaml.
