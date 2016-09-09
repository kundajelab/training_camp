#Training Camp Packages 

#TODO: We need to create our own jupyter entry in docker registry 
FROM kundajelab:jupyterhub  

MAINTAINER Kundaje Lab 

#conda 2 & conda 3 environments 
RUN conda create -n py3 python=3 anaconda
RUN conda create -n py2 python=2 anaconda

# register py2 kernel
RUN source activate py2
#make sure to install with --user flag to avoid permissions issues 
RUN ipython kernel install --user

# register py3 kernel 
RUN source activate py3
#make sure to install with --user flag to avoid permissions issues 
RUN ipython kernel install --user 
RUN source deactivate 

#install the toolkit for the training camp, some packages are available with apt (yay!) 
RUN apt-get -y install bowtie bedtools fastqc default-jre picard-tools samtools 

#download UCSC tools 
WORKDIR /opt
RUN mkdir ucsc_tools 
WORKDIR /opt/ucsc_tools 
RUN wget ftp://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/\* 
#blat is special -- doesn't get downloaded by the above command 
RUN wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/blat/blat
RUN chmod +x * 
RUN chmod -R 775 /opt/ucsc_tools
RUN echo "export PATH=/opt/ucsc_tools:$PATH" >> /etc/bash.bashrc 

#set up R 
RUN sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list'
RUN gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
RUN gpg -a --export E084DAB9 | sudo apt-key add -
RUN sudo apt-get -y install r-base

#install MACS2 
RUN source activate py2 
RUN pip install MACS2
RUN apt-get install macs


#install homer 
#ghostscript dependency for homer 
RUN mkdir /opt/gs 
WORKDIR /opt/gs 
RUN wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs919/ghostscript-9.19-linux-x86_64.tgz
RUN tar -xzvf ghostscript*tgz 
RUN echo "export PATH=/opt/gs/ghostscript-9.19-linux-x86_64:$PATH" >> /etc/bash.bashrc 
RUN chmod -R 775 /opt/gs

#seqlogo dependency for homer 
RUN mkdir /opt/weblogo 
WORKDIR /opt/weblogo 
RUN wget http://weblogo.berkeley.edu/release/weblogo.2.8.2.tar.gz
RUN tar -xzvf weblogo.2.8.2.tar.gz 
RUN echo "export PATH=/opt/weblogo/weblogo:$PATH" >> /etc/bash.bashrc 
RUN chmod -R 775 /opt/weblogo 

#homer itself 
RUN mkdir /opt/homer 
WORKDIR /opt/homer 
RUN wget http://homer.salk.edu/homer/configureHomer.pl
RUN perl configureHomer.pl -install 
RUN echo "export PATH=/opt/homer/bin:$PATH" >> /etc/bash.bashrc 
RUN chmod -R 755 /opt/homer


#set up environment modules 
RUN touch /etc/skel/.ksenv
RUN touch /etc/skel/.login 
RUN touch /etc/skel/.cshrc 

RUN apt-get -y install environment-modules 
RUN add.modules 

#set up SGE 

#create the directory for training camp 2016 files 
RUN mkdir -p /tc2016
