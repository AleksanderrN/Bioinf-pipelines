FROM mambaorg/micromamba:1.5.8
RUN micromamba install -n base -c bioconda -c conda-forge -y \
    trimmomatic=0.39 && \
    micromamba clean --all --yes
ENV PATH=/opt/conda/bin:$PATH