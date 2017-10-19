FROM gapsystem/gap-docker-base

MAINTAINER The GAP Group <support@gap-system.org>

USER gap

RUN    cd /home/gap/inst/ \
    && rm -rf gap4r8 \
    && wget -q https://github.com/gap-system/gap/archive/master.zip \
    && unzip -q master.zip \
    && rm master.zip \
    && cd gap-master \
    && ./autogen.sh \
    && ./configure \
    && make \
    && mkdir pkg \
    && cd pkg \
    && wget -q https://www.gap-system.org/pub/gap/gap4pkgs/packages-master.tar.gz \
    && tar xzf packages-master.tar.gz \
    && rm packages-master.tar.gz \
    && ../bin/BuildPackages.sh

ENV GAP_HOME /home/gap/inst/gap-master
ENV PATH ${GAP_HOME}/bin:${PATH}

# Start at $HOME.
WORKDIR /home/gap

RUN sudo apt-get update && \
    sudo apt-get install -y --force-yes \
    build-essential pkg-config \
    python3 python3-dev \
    python3-pip python3-setuptools \
    libfreetype6-dev libpng-dev libjpeg-dev zlib1g-dev libzmq3-dev \
    && sudo pip3 install --upgrade setuptools pip \
    && sudo pip3 install jupyter \
    && sudo pip3 install notebook

RUN    cd /home/gap/inst/gap-master/pkg \
    && git clone https://github.com/gap-packages/uuid.git \
    && git clone https://github.com/gap-packages/crypting.git \
    && cd crypting \
    && ./autogen.sh \
    && ./configure \
    && make \
    && cd .. \
    && git clone https://github.com/gap-packages/ZeroMQInterface.git \
    && cd ZeroMQInterface \
    && ./autogen.sh \
    && ./configure \
    && make \
    && cd .. \
    && git clone https://github.com/gap-packages/JupyterKernel.git \
    && cd JupyterKernel \
    && python3 setup.py install --user \
    && cd ../.. \
    && cp bin/gap.sh bin/gap

ENV HOME /home/gap
ENV PATH /home/gap/inst/gap-master/pkg/JupyterKernel/etc/jupyter:${PATH}
ENV JUPYTER_GAP_EXECUTABLE /home/gap/inst/gap-master/bin/gap.sh

WORKDIR /home/gap
