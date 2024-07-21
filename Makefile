# Set default shell.
SHELL := bash

# Run recipe on a single shell.
.ONESHELL:

# Enable bash strict mode.
.SHELLFLAGS := -eu -o pipefail -c

# Delete generated files upon encountering an error.
.DELETE_ON_ERROR:

# Set GNU Make options.
MAKEFLAGS += --warn-undefined-variables --no-builtin-rules

# Override default prefix for recipes.
.RECIPEPREFIX = >

# Check if all required exectuables are installed.
EXE = fastqc multiqc megahit bio fastq-dump seqkit Bandage
CHECK := $(foreach exec, $(EXE),\
				 $(if $(shell which $(exec)),some string,$(error 'Program: $(exec) not found.')))

# Define path variables.

## This points to the project root directory.
ROOT ?= ${HOME}/gh-repos/learn-assembly

## This points to the data directory.
DATADIR = ${ROOT}/data

## This points to the metadata directory.
METADATADIR = ${ROOT}/metadata

## This points to the output directory.
OUTDIR = ${ROOT}/output

## This points to the reads directory.
READSDIR = ${DATADIR}/reads

## This points to the directory storing FASTQC reports.
FASTQC_DIR = ${OUTDIR}/fastqc

# Define file patterns.

## Matches pair-end reads in FASTQ format.
READS ?= ${READSDIR}/*

# Define parameterized variables.

## Accession ID for fetching SRA reads.
ACC ?= SRR10971381

## Number of reads to pull from the SRA archive. (Default = null)
N ?=

## Number of CPU threads to use.
CPU ?= 12

# Define ASSEMBLY parameters.
KMIN ?= 21
KMAX ?= 119
KSTEP ?= 12

usage:
> @echo -e '\nA simple de novo assembly pipeline for generating contigs from sequencing reads.'
> @echo
> @echo 'COMMANDS:'
> @echo -e '    data      \t download sequencing read from an accession number.'
> @echo -e '    metadata  \t retrieve run metadata from an accession number.'
> @echo -e '    fastqc    \t generate fastQC report from raw reads.'
> @echo -e '    multiqc   \t consolidate fastQC reports into a single summary.'
> @echo -e '    trim      \t remove low-quality bases and/or adapter reads.'
> @echo -e '    assemble  \t generate contigs from sequencing reads.'
> @echo -e '    stats     \t describe sequence statistics from reads.'
> @echo -e '    visualize \t generate an image from a genome graph.'
> @echo -e '    all       \t run complete pipeline. (data --> trim --> assemble)\n'

all: data trim assemble visualize

info:
> @echo -e '\nDEFAULTS:'
> @echo -e '\tAccession: ${ACC}'
> @echo -e '\tCores: ${CPU}'
> @echo 'FILEPATHS:'
> @echo -e '\tWorking directory: $(PWD)'
> @echo -e '\tData directory: ${DATADIR}'
> @echo -e '\tMetadata directory: ${DATADIR}'
> @echo -e '\tOutput directory: ${OUTDIR}'
> @echo 'DEPENDENCIES:'
> @echo -e '\t${EXE}\n'

metadata:
> # Fetches run metadata for specified accession id.
> bio search ${ACC} | jq '.[]' > ${METADATADIR}/${ACC}_info.json
> cat ${METADATADIR}/${ACC}_info.json

data:
> # Create directory for storing sequencing reads.
> mkdir -p ${READSDIR}
>
ifdef N
> # Download N reads from the SRA archive.
> @echo Fetching ${N} reads from accession: ${ACC}
> fastq-dump -X ${N} ${ACC} --split-files --origfmt --outdir ${READSDIR}
endif
>
ifndef N
> # Download ALL reads from the SRA archive.
>	@echo Fetching ALL reads from accession: ${ACC}
>	fastq-dump ${ACC} --split-files --origfmt --outdir ${READSDIR}
endif

# Print read statistics to standard output.
stats:
> seqkit stats ${READS}

# Trim low-quality reads.
trim: ${READSDIR}
> trimmomatic PE \
		${READSDIR}/${ACC}_1.fastq \
		${READSDIR}/${ACC}_2.fastq \
		-summary ${OUTDIR}/trim_summary.txt \
		-baseout ${READSDIR}/trimmed.fq SLIDINGWINDOW:4:30

# Run quality control on trimmed reads
fastqc:
> # Create directory for FASTQC reports.
> mkdir -p ${FASTQC_DIR}
>
> fastqc ${READSDIR}/*.fq -o ${FASTQC_DIR}

# Consolidate FastQC reports into a single summary.
multiqc: ${FASTQC_DIR}
> multiqc ${OUTDIR}/fastqc \
		--outdir ${OUTDIR}/multiqc \
		--force --interactive --export

# Generate contigs with megahit.
assemble: ${READSDIR}
> # Delete megahit directory.
> rm -rf ${OUTDIR}/megahit
>
> megahit -1 ${READSDIR}/trimmed_1P.fq -2 ${READSDIR}/trimmed_2P.fq \
		-o ${OUTDIR}/megahit \
		--num-cpu-threads ${CPU} \
		--k-min ${KMAX} --k-max ${KMIN} --k-step {KSTEP}
>
#	Generate sequence statistics for contigs.
> @echo "Generating stats for assembled contigs:"
> python3 scripts/summarize_assembly.py ${OUTDIR}/megahit/final.contigs.fa -o ${METADATADIR}/final.contigs.csv
> seqkit stats ${OUTDIR}/megahit/final.contigs.fa

# Visualize assembled contigs with Bandage.
visualize: ${OUTDIR}/megahit/final.contigs.fa
> # Convert intermediate contigs into genome graph (.fastg)
> megahit_toolkit contig2fastg ${KMAX} ${OUTDIR}/megahit/intermediate_contigs/k${KMAX}.contigs.fa > ${OUTDIR}/k${KMAX}.fastg
>
> # Generate image from graph
> Bandage image ${OUTDIR}/k${KMAX}.fastg ${OUTDIR}/k${KMAX}_genome_graph.png

.PHONY: info data metadata stats all
