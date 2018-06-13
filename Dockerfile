FROM centos:7

RUN yum -y update && \
    yum -y install epel-release

# install RStudio Server

RUN yum -y install R && \
    yum -y install https://download2.rstudio.org/rstudio-server-rhel-1.0.136-x86_64.rpm && \
    yum -y install gdal gdal-devel gdal-libs proj proj-devel proj-epsg proj-nad libpng-devel openssl-devel libcurl-devel

#RUN rstudio-server verify-installation
#RUN systemctl enable rstudio-server.service && \
#    systemctl start rstudio-server.service

# install JupyterHub

RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm && \
    yum -y install yum-utils && \
    yum -y groupinstall development && \
    yum -y install python36u python36u-pip python36u-devel nodejs npm sudo && \
    npm install -g configurable-http-proxy && \
    pip3.6 install --upgrade jupyterhub && \
    pip3.6 install --upgrade notebook && \
    pip3.6 install git+https://github.com/jupyter/sudospawner && \
    pip3.6 install ipywidgets

RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
    useradd --home-dir '/usr/share/jupyter/hub' --shell '/bin/bash' jupyterhub && \
    mkdir /etc/jupyterhub /var/log/jupyterhub

RUN cd /etc/jupyterhub && \
    jupyterhub --generate-config
COPY jupyterhub_config.py /etc/jupyterhub/
RUN chown -R jupyterhub:jupyterhub /etc/jupyterhub /var/log/jupyterhub /usr/share/jupyter/hub

COPY sudoers.append /tmp/
RUN cat /tmp/sudoers.append >> /etc/sudoers

RUN groupadd shadow && \
    chgrp shadow /etc/shadow && \
    chmod g+r /etc/shadow && \
    usermod -a -G shadow jupyterhub

RUN useradd -ms /bin/bash jcyli && \
    echo 'jcyli:password' | chpasswd && \
    usermod -aG jupyterhub jcyli

EXPOSE 8000 8787

# COPY run-services.sh /usr/local/bin

# CMD sudo -u jupyterhub jupyterhub --config /etc/jupyterhub/jupyterhub_config.py

# CMD /usr/local/bin/run-services.sh

USER jupyterhub

CMD jupyterhub --config /etc/jupyterhub/jupyterhub_config.py
