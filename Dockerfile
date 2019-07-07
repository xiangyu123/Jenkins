# Pull base image
# ---------------
FROM docker:18.06.0-ce as docker
FROM jenkins/jenkins

COPY --from=docker /usr/local/bin/docker /usr/bin/
ENV DOCKER_API_VERSION=1.38

# Author
# ------
MAINTAINER zhigui.xu

# Build the container
# -------------------

USER root

# install wget curl vim
RUN apt-get install -y wget && addgroup --system --gid 993 docker

# get maven 3.6.1
ENV MAVEN_VERSION=3.6.1
RUN wget --no-verbose -O /tmp/apache-maven-3.6.1-bin.tar.gz http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz

# verify checksum
# RUN echo "35c39251d2af99b6624d40d801f6ff02 /tmp/apache-maven-3.4.0-bin.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-3.6.1-bin.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-3.6.1 /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-3.6.1-bin.tar.gz
ADD --chown=jenkins:jenkins ./settings.xml /opt/maven/conf/
ENV MAVEN_HOME /opt/maven
RUN curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod 755 /usr/local/bin/docker-compose

RUN chown -R jenkins:jenkins /opt/maven && usermod -a -G docker jenkins

# install git (MH: Git should be preinstalled in the original Jenkins docker image prep)
# RUN apt-get install -y git

# remove download archive files
RUN apt-get clean

USER jenkins
ADD --chown=jenkins:jenkins ./install.sh /var/jenkins_home/
ADD --chown=jenkins:jenkins ./plugins.txt /var/jenkins_home/
RUN echo 'cd /var/jenkins_home/ && sh install.sh $(echo $(cat plugins.txt))' >> /etc/rc.local
WORKDIR /var/jenkins_home
