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

Next, install micromamba as instructed [here](https://mamba.readthedocs.io/en/latest/installation/micromamba-installation.html) and configure with:
```sh
micromamba config append channels bioconda     # source of many bioinformatics-specific tools
micromamba config append channels conda-forge  # for other python packages such as numpy and pandas
micromamba config set channel_priority strict
```

Then create a new environment from the `env.yml` file:
```sh
micromamba create -f env.yml
```

Activate the environment with:
```sh
micromamba activate assembly
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

Fetching data from the SRA can take a long time depending on your network speed. Additionally, the assembly process make take up a significant portion of your machine's computing resources. To run the pipeline on a smaller subset of the SRA data, pass in the number of reads using the `N` parameter. You can also specify the amount of cores to be alloted for the assembly through the `CPU` parameter.
```sh
# Run assembly with 100000 reads and 8 cores
make assemble N=100000 CPU=8
```

After identifying the id of the longest generated contig, run a BLAST query to identify similar sequences and their respective hosts:
```sh
make blast
```

Run the entire pipeline using:
```
make all

# Do some cleanup afterwards to save disk space
make clean
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

For any questions or suggestions, feel free to contact me at `jegsamson.dev@gmail.com`.
