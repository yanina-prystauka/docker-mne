FROM rhancock/opengl
MAINTAINER <rhancock@gmail.com>

##
ENV DOWNLOADS /tmp/downloads
WORKDIR $DOWNLOADS


# Python
## Anaconda 3
WORKDIR $DOWNLOADS
RUN wget "https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh" && \
	bash Anaconda3-5.0.1-Linux-x86_64.sh -b -p /usr/local/anaconda3
ENV PATH "/usr/local/anaconda3/bin:${PATH}"
RUN wget "https://raw.githubusercontent.com/rhancockn/mne-python/master/environment.yml" && \
	conda env create -n mne -f environment.yml

RUN /bin/bash -c ". activate mne" && \
conda install -y git pip && \
pip install autoreject && \
pip install -U git+https://github.com/rhancockn/mne-python.git && \
pip install pathlib && \
conda install -y qt pyqt

# libxi6 is the critical packge to get qt/xcb working
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
gcc-multilib libx11-xcb1 libxi6
# Cleanup
RUN apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y
RUN rm -rf $DOWNLOADS
RUN ldconfig


# Directories
## binds
RUN mkdir -p /{scratch,input,ouput}
RUN mkdir -p /bind/scripts


# Configuration

## PREpend user scripts to the path
ENV PATH /bind/scripts:$PATH

ENTRYPOINT ["/usr/bin/env","/singularity"]

COPY entry_init.sh /singularity
RUN chmod 755 /singularity

RUN /usr/bin/env |sed  '/^HOME/d' | sed '/^HOSTNAME/d' | sed  '/^USER/d' | sed '/^PWD/d' > /environment && \
	chmod 755 /environment


RUN useradd --create-home -s /bin/bash mne
USER mne

ENV USER=mne

RUN echo "source activate mne" > ~/.bashrc

