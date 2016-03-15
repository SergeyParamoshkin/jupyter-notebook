FROM serg3091/docker-centos


ENV NB_USER datascience
ENV NB_UID 1000

WORKDIR /tmp
COPY ./distr/ipykernel_install.sh /tmp/ipykernel_install.sh
RUN /bin/bash ipykernel_install.sh
RUN rm -f ipykernel_install.sh

RUN pip install --upgrade pip 
RUN pip install --upgrade "ipython[all]" --ignore-installed

RUN pip3 install --upgrade pip
RUN pip3 install --upgrade "ipython[all]" --ignore-installed

RUN curl https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo  
RUN yum install -y sbt

COPY ./distr/jupyter-scala /opt/jupyter-scala

WORKDIR /opt/jupyter-scala
RUN sbt compile
RUN /bin/bash jupyter-scala

RUN pip install ipyparallel
RUN pip3 install ipyparallel
RUN ipcluster nbextension enable

RUN jupyter-kernelspec list

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER
RUN chown -R $NB_USER /opt/conda/*

COPY ./distr/start-notebook.sh /usr/local/bin/
COPY ./distr/jupyter_notebook_config.py /home/$NB_USER/.jupyter/
RUN mkdir -p /home/$NB_USER/work
RUN chown -R $NB_USER:users /home/$NB_USER/*
RUN chown -R $NB_USER:users /home/$NB_USER/.*

COPY ./distr/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

USER $NB_USER
RUN /bin/bash jupyter-scala

EXPOSE 8888
WORKDIR /home/$NB_USER/work
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]
