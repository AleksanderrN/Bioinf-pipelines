FROM mambaorg/micromamba:1.5.8
RUN micromamba install -n base -c bioconda -c conda-forge -y \
    bcftools=1.21 samtools=1.21 && \
    micromamba clean --all --yes
ENV PATH=/opt/conda/bin:$PATH