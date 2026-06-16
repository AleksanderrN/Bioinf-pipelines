FROM mambaorg/micromamba:1.5.8
RUN micromamba install -n base -c bioconda -c conda-forge -y \
    spades=4.0.0 && \
    micromamba clean --all --yes
ENV PATH=/opt/conda/bin:$PATH