FROM mambaorg/micromamba:1.5.8
RUN micromamba install -n base -c bioconda -c conda-forge -y \
    bwa=0.7.18 samtools=1.21 && \
    micromamba clean --all --yes
ENV PATH=/opt/conda/bin:$PATH