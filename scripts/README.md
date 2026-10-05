# Analysis scripts and pipeline
This directory contains the Bash and Python scripts powering the *E. coli* REL606 variant calling and visualisation pipeline.

To ensure 100% reproducibility, all required tool dependencies and exact versions are managed via Conda/Mamba using `environment.yml` file.

---

## Environment Setup

Before executing any script, build and activate the dedicated Conda environment:

```bash
# Create the environment from the root directory
conda env create -f ../environment.yml

# Activate the environment
conda activate ecoli-variant-env
