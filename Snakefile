'''
Basic usage:
  snakemake -p --configfile path/to/config.yaml -j 8

© 2020 Yumi Sims

dummy snakemake file of geval analysis pipeline
'''

import os
import os.path
import errno
#include: 'scripts/functions.py'

### define the common varables
runner_path = config['tools']['runner_path']
print (runner_path )
work_dir = config['workdir']
myAsm=config['reference']
minimapindex=os.path.splitext(myAsm)[0] +".mmi"
print (minimapindex)
myAnalysis=config['analysis']
print (myAnalysis)
myAnalysisDic={}
myfinishedFile=[]

dbVersion=config['assembly']['dbVersion']
asmVersion=config['assembly']['asmVersion']
gType=config['assembly']['gevalType']
sample=config['assembly']['sample']

plotName=gType+"_"+sample+"_"+dbVersion
bwName=gType+"_"+sample+"_"+dbVersion+"_"+asmVersion
higlassName=sample+"_"+dbVersion

### parse the yaml config file and establish the workflow
flag = 0
for key, value in myAnalysis.items() :
    myDir = os.path.join(work_dir, key)
    for k, v in value.items():
        if v == []:
            print ("process " + str(key)+" argument is missing, skip this process...")
            flag = 0
            break
        else:
            flag = 1
    if flag == 1:
        myAnalysisDic[key] = myDir
        myfinishedFile.append(myDir+"/"+key+"_done")
        try:
            print ("my working dir is " +myDir)
            os.makedirs(myDir)
            os.makedirs(myDir+'/sort_tmp')
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise
    if flag ==0:
        #print ('do not process '+ key)
        myAnalysisDic[key] = myDir

#####x

rule all:
    input:
        expand("{myfile}", myfile=myfinishedFile)

rule run_indexing:
    input :
        myref=myAsm
    output:
        my_index=minimapindex
    log:
        work_dir+"/idx.log"
    shell:
        "/software/grit/bin/minimap2 -d {output} {input.myref} > {log} 2>&1"

rule run_minimap:
    input:
        myref=myAsm,
        myindex=minimapindex,
        myrunner=runner_path+"/run-minimap"
    params:
        myDir=myAnalysisDic['minimap'],
        myreads=config['analysis']['minimap']['reads'],
        pname=plotName,
        bname=bwName
    output:
        myAnalysisDic['minimap']+'/minimap_done'
    shell:
        "cd {params.myDir} && {input.myrunner} +loop 100 -r {input.myref} -f {params.myreads} -m {input.myindex} -o {params.myDir} -s {params.bname} -g {params.pname} -z {output} || true"

rule run_minidazzler:
    input:
        myref=myAsm,
        myindex=minimapindex,
        myrunner=runner_path+"/run-minidazzler"
    params:
        myDir=myAnalysisDic['minidazzler'],
        myreads=config['analysis']['minidazzler']['preads'],
        dbVersion=config['assembly']['dbVersion'],
        asmVersion=config['assembly']['asmVersion'],
        gType=config['assembly']['gevalType'],
        sample=config['assembly']['sample']
    output:
        myAnalysisDic['minidazzler']+'/minidazzler_done'
    shell:
        "cd {params.myDir} && {input.myrunner} +loop 60 -f {params.myreads} -v {params.dbVersion} -s {params.sample} -a {params.asmVersion} -t {params.gType} -r {input.myref} -m {input.myindex} -o {params.myDir} -z {output} || true"



rule run_break10x:
    input:
        myref=myAsm,
        myrunner=runner_path+"/run-break10x",
    params:
        reads10x=config['analysis']['break10x']['10x_reads'],
        myDir=myAnalysisDic["break10x"]
    output:
        myAnalysisDic["break10x"]+'/break10x_done'
    shell:
        'cd {params.myDir} && {input.myrunner} +loop 60 -p {params.reads10x} -r {input.myref} -o {params.myDir} -z {output} || true'

rule run_busco:
    input:
        myref=myAsm,
        myrunner=runner_path+"/run-busco"
    params:
        species=config['analysis']['busco']['sp'],
        ordb=config['analysis']['busco']['ordb'],
        myDir=myAnalysisDic['busco']
    conda:
        "/nfs/team135/yy5/geval_pipe/envs/busco3.yaml"
    output:
        myAnalysisDic['busco']+'/busco_done'
    shell:
        'cd {params.myDir} && {input.myrunner} +loop 60 -s {params.species} -r {input.myref} -o {params.myDir} -l {params.ordb} -z {output} || true'

rule run_hic:
    input:
        myref=myAsm,
        myrunner=runner_path+"/run-hic"
    params:
        myDir=myAnalysisDic['hic'],
        hicReads=config['analysis']['hic']['hicreads'],
        hName=higlassName
    output:
        myAnalysisDic['hic']+'/hic_done'
    shell:
        'cd {params.myDir} && {input.myrunner} +loop 60 -f {params.hicReads} -s {params.hName} -r {input.myref} -o {params.myDir} -z {output} || true'

rule run_salsa:
    input:
        myref=myAsm,
        myrunner=runner_path+"/run-salsa",
        myinput=myAnalysisDic['hic']+'/hic_done'
    params:
        myDir=myAnalysisDic['salsa'],
        motif=config['analysis']['salsa']['enzyme'],
        myindir=myAnalysisDic['hic']
    conda:
        "/nfs/team135/yy5/geval_pipe/envs/python2.yaml"
    output:
        myAnalysisDic['salsa']+'/salsa_done'
    shell:
        'cd {params.myDir} && {input.myrunner} -b -m {params.motif} +loop 60 -r {input.myref} -o {params.myDir} -y {params.myindir} -z {output} || true'

rule run_lepbase:
    input:
        myref=myAsm,
        myrunner=runner_path+"/run-lepbase"
    params:
        prefix=config['analysis']['lepbase']['prefix'],
        myDir=myAnalysisDic['lepbase']
    output:
        myAnalysisDic['lepbase']+'/lepbase_done'
    shell:
        'cd {params.myDir} && {input.myrunner} +loop 60 -b -s {params.prefix} -r {input.myref} -o {params.myDir} -z {output} || true'

rule run_altAsm:
    input:
        myref=myAsm,
        myrunner=runner_path+"/run-altAsm"
    params:
        altAsm=config['analysis']['altAsm']['asm'],
        myDir=myAnalysisDic['altAsm']
    output:
        myAnalysisDic['altAsm']+'/altAsm_done'
    shell:
        'cd {params.myDir} && {input.myrunner} +loop 60 -b -f {params.altAsm} -r {input.myref} -o {params.myDir} -z {output} || true'

rule run_telomere:
    input:
        myref=myAsm,
        myrunner=runner_path+"/run-telomere"
    params:
        myDir=myAnalysisDic['telomere'],
        teloseq=config['analysis']['telomere']['teloseq']
    output:
        myAnalysisDic['telomere']+'/telomere_done'
    shell:
        'cd {params.myDir} && {input.myrunner} +loop 60 -b -r {input.myref} -s {params.teloseq} -o {params.myDir} -z {output}|| true'


rule decontamination:
    input:
        confile=config['analysis']['decontamination']['contamination_file'],
        myrunner=runner_path+"/run-decontamination"
    params:
        myDir=myAnalysisDic['decontamination']
    output:
        myAnalysisDic['decontamination']+'/decontamination_done'
    shell:
        'cd {params.myDir} && {input.myrunner} +loop 60 -b -f {input.confile} -o {params.myDir} -z {output} || true'

rule run_bionano:
    input:
        myref=myAsm,
        myrunner=runner_path+"/run-bionano",
        myqcmap_path=config['analysis']['bionano']['qcmap'],
    params:
        myDir=myAnalysisDic['bionano'],
        myEnzyme=config['analysis']['bionano']['enzyme'],
        no_cpu=config['analysis']['bionano']['no_cpu'],
        hap=config['analysis']['bionano']['hap']
    conda:
        "/nfs/team135/yy5/geval_pipe/envs/python2.yaml"
    output:
        myAnalysisDic['bionano']+'/bionano_done'
    shell:
        'cd {params.myDir} && {input.myrunner} +loop 60 -m {input.myqcmap_path} -p {params.hap} -y {params.myEnzyme} -r {input.myref} -o {params.myDir} -u {params.no_cpu} -z {output} || true'