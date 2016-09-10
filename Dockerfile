#Training Camp Packages 

#TODO: We need to create our own jupyter entry in docker registry 
FROM kundajelab/jupyterhub:latest

MAINTAINER Kundaje Lab 


#RUN rm /bin/sh && ln -s /bin/bash /bin/sh
#set up environment modules 
RUN touch /etc/skel/.ksenv
RUN touch /etc/skel/.login 
RUN touch /etc/skel/.cshrc 

RUN apt-get -y install environment-modules 
#RUN add.modules 
RUN source /etc/profile 
#copy over the module files from training camp repo to the docker image-- right now these are mostly to teach the students 
#about what a module file is; though we can modify them to be useful/support multiple versions of tools 
#RUN mkdir /usr/share/modules
#RUN mkdir /usr/share/modules/modulefiles 
ADD modulefiles/bowtie /usr/share/modules/modulefiles/bowtie 
ADD modulefiles/bedtools /usr/share/modules/modulefiles/bedtools
ADD modulefiles/fastqc /usr/share/modules/modulesfiles/fastqc 
ADD modulefiles/java /usr/share/modules/modulefiles/java 
ADD modulefiles/picard-tools /usr/share/modules/modulefiles/picard-tools 
ADD modulefiles/r /usr/share/modules/modulefiles/r 
ADD modulefiles/samtools /usr/share/modules/modulefiles/samtools 
ADD modulefiles/ucsc_tools /usr/share/modules/modulesfiles/ucsc_tools 
ADD modulefiles/macs2 /usr/share/modules/modulefiles/macs2 
ADD modulefiles/homer /usr/share/modules/modulefiles/homer 
ADD modulefiles/fastqc /usr/share/modules/modulefiles/fastqc 

#install the toolkit for the training camp, some packages are available with apt (yay!) 
RUN apt-get -y install bowtie2 bedtools fastqc default-jre picard-tools samtools 

#download UCSC tools 
WORKDIR /opt
RUN mkdir ucsc_tools 
WORKDIR /opt/ucsc_tools 
RUN wget ftp://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/\* 
#blat is special -- doesn't get downloaded by the above command 
RUN wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/blat/blat
RUN chmod +x * 
RUN chmod -R 775 /opt/ucsc_tools
#don't need to modify the path if we're using environment modules 
#RUN echo "export PATH=/opt/ucsc_tools:$PATH" >> /etc/bash.bashrc 

#set up R 
RUN sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
RUN gpg -a --export E084DAB9 | sudo apt-key add -
RUN sudo apt-get -y install r-base

#install MACS2 
RUN /bin/bash -c "source activate py2 && pip install numpy && pip install MACS2 && source deactivate" 
RUN apt-get -y install macs


#install homer 
#ghostscript dependency for homer 
RUN mkdir /opt/gs 
WORKDIR /opt/gs 
RUN wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs919/ghostscript-9.19-linux-x86_64.tgz
RUN tar -xzvf ghostscript*tgz 
#don't need to modify the path if we are using environment modules 
#RUN echo "export PATH=/opt/gs/ghostscript-9.19-linux-x86_64:$PATH" >> /etc/bash.bashrc 
RUN chmod -R 775 /opt/gs

#seqlogo dependency for homer 
RUN mkdir /opt/weblogo 
WORKDIR /opt/weblogo 
RUN wget http://weblogo.berkeley.edu/release/weblogo.2.8.2.tar.gz
RUN tar -xzvf weblogo.2.8.2.tar.gz 
#don't need to modify the path if we are using environment modules 
#RUN echo "export PATH=/opt/weblogo/weblogo:$PATH" >> /etc/bash.bashrc 
RUN chmod -R 775 /opt/weblogo 

#homer itself 
RUN mkdir /opt/homer 
WORKDIR /opt/homer 
RUN wget http://homer.salk.edu/homer/configureHomer.pl
RUN perl configureHomer.pl -install 
#don't need to modify the path if we are using environment modules 
#RUN echo "export PATH=/opt/homer/bin:$PATH" >> /etc/bash.bashrc 
RUN chmod -R 755 /opt/homer

#create the directory for training camp 2016 files 
RUN mkdir -p /tc2016
