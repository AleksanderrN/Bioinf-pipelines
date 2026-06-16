FROM mambaorg/micromamba:1.5.8
RUN micromamba install -n base -c bioconda -c conda-forge -y \
    samtools=1.21 matplotlib pandas && \
    micromamba clean --all --yes
ENV PATH=/opt/conda/bin:$PATH