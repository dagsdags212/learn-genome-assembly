#!/usr/bin/env bash

set -uex

# Filepath of assembled contigs
CONTIGS='output/megahit/final.contigs.fa'

# Filepath to BLAST database.
DB='db/contigs'

# BLAST query format.
FORMAT='6 pident length sacc stitle'

# Create a BLAST database from contigs.
makeblastdb -in ${CONTIGS} -out ${DB} -dbtype nucl -parse_seqids

# Extract id of largest contig
LARGEST_CONTIG_ID=$(blastdbcmd -db ${DB} -entry all -outfmt "%l %a" | sort -rn | head -n 1 | csvcut -d , -c 2)

# Save sequence of largest contig as putative genome.
blastdbcmd -db ${DB} -entry ${LARGEST_CONTIG_ID} > data/candidate_genome.fa

# Query largest contig sequence against the non-redundant nucleotide database hosted at NCBI.
blastn -db nt -query data/candidate_genome.fa -outfmt ${FORMAT} > data/blast.out.txt
