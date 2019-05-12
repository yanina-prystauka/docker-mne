FROM rhancock/opengl
MAINTAINER <rhancock@gmail.com>
# with help from @yanina-prystauka
##
ENV DOWNLOADS /tmp/downloads
WORKDIR $DOWNLOADS


# libxi6 is the critical packge to get qt/xcb working
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
gcc-multilib libx11-xcb1 libxi6


# freesurfer
RUN wget -N -qO- https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.0/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.0.tar.gz | tar zxv --no-same-owner -C /opt \
    --exclude='freesurfer/trctrain' \
    --exclude='freesurfer/subjects/fsaverage_sym' \
    --exclude='freesurfer/subjects/fsaverage3' \
    --exclude='freesurfer/subjects/fsaverage4' \
    --exclude='freesurfer/subjects/fsaverage5' \
    --exclude='freesurfer/subjects/fsaverage6' \
    --exclude='freesurfer/subjects/cvs_avg35' \
    --exclude='freesurfer/subjects/cvs_avg35_inMNI152' \
    --exclude='freesurfer/subjects/bert' \
    --exclude='freesurfer/subjects/V1_average' \
    --exclude='freesurfer/average/mult-comp-cor' \
    --exclude='freesurfer/lib/cuda' \
    --exclude='freesurfer/lib/qt'


# Configure basic freesurfer ENV
ENV OS Linux
ENV FS_OVERRIDE 0
ENV FIX_VERTEX_AREA=
ENV SUBJECTS_DIR /freesurfer
ENV FSF_OUTPUT_FORMAT nii.gz
ENV MNI_DIR /opt/freesurfer/mni
ENV LOCAL_DIR /opt/freesurfer/local
ENV FREESURFER_HOME /opt/freesurfer
ENV FSFAST_HOME /opt/freesurfer/fsfast
ENV MINC_BIN_DIR /opt/freesurfer/mni/bin
ENV MINC_LIB_DIR /opt/freesurfer/mni/lib
ENV MNI_DATAPATH /opt/freesurfer/mni/data
ENV FMRI_ANALYSIS_DIR /opt/freesurfer/fsfast
ENV PERL5LIB /opt/freesurfer/mni/lib/perl5/5.8.5
ENV MNI_PERL5LIB /opt/freesurfer/mni/lib/perl5/5.8.5
ENV PATH $PATH:/opt/freesurfer/bin:/opt/freesurfer/fsfast/bin:/opt/freesurfer/tktools:/opt/freesurfer/mni/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin


# Python
## Anaconda 3
WORKDIR $DOWNLOADS
RUN wget "https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh" && \
	bash Anaconda3-5.0.1-Linux-x86_64.sh -b -p /usr/local/anaconda3
ENV PATH "/usr/local/anaconda3/bin:${PATH}"
RUN wget "https://raw.githubusercontent.com/rhancockn/mne-python/master/environment.yml" && \
	conda install -y git pip && conda env update -n root -f environment.yml


# Cleanup
RUN apt-get clean -y && apt-get autoclean -y && apt-get autoremove -y
RUN rm -rf $DOWNLOADS
RUN ldconfig


# Directories
## binds
RUN mkdir -p /scratch && mkdir /input && \
    mkdir /freesurfer && \
    mkdir /data && \
    mkdir /output
RUN mkdir -p /bind/scripts

RUN pip install --force-reinstall -U git+https://github.com/rhancockn/mne-python.git@593b7b78e6774c3ac87fd6afadb82473daaafcad && \
pip install -U autoreject

RUN pip install pathlib
RUN conda install -y qt pyqt


# Configuration

## PREpend user scripts to the path
ENV PATH /bind/scripts:$PATH

ENTRYPOINT ["/usr/bin/env","/singularity"]

COPY entry_init.sh /singularity
RUN chmod 755 /singularity

RUN /usr/bin/env |sed  '/^HOME/d' | sed '/^HOSTNAME/d' | sed  '/^USER/d' | sed '/^PWD/d' > /environment && \
	chmod 755 /environment


#RUN useradd --create-home -s /bin/bash mne
#USER mne

#ENV USER=mne

# RUN echo "source activate mne" > ~/.bashrc
