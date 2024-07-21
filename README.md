# Assembling the SARS-CoV-2 Genome

The main purpose of this repository is to demonstrate the steps involved in *de novo* assembly of a viral genome, namely **SARS-CoV-2**.

Sequencing reads used for the pipeline were retrieved from accession [SRR10971381](https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR10971381&display=metadata) as provided by [Wu et al. 2020](https://www.nature.com/articles/s41586-020-2008-3). The steps involved in the assembly pipeline is listed as follows:

1. Data retrieval
2. Exploration of sequence properties
2. Trimming of low-scoring bases
3. Quality contol
4. Genome assembly
5. Contig visualization

Each task in the pipeline can be executed as a separate bash script. The order of execution is orchestrated using `GNU Make`, as provided by a `Makefile` in the root directory. A custom `conda` environment is used to manage dependencies.

The first step in reproducing the analysis is to clone the repository in your local machine:
```sh
# Locally clone repository
git clone https://github.com/dagsdags212/learn-genome-assembly.git

# Change to the project directory
cd learn-genome-assembly
```

Explore available commands by running:
```sh
make usage

# or simply
make
```

Run the assembly pipeline by invoking the following command:
```sh
make assemble
```

Other commands include:
```
# Gather sequence statistics
make stats

# Consolidate fastQC reports into a interactive summary file.
make multiqc

# Visualize assembled contigs using Bandage
make visualize
```
