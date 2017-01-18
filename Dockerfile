FROM debian:jessie-backports

MAINTAINER Marcelo Almeida <ms.almeida86@gmail.com>

# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    git \
    zip \
    supervisor \
    default-jre-headless && \
    wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add - && \
    sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list' && \
    apt-get update && apt-get install -y jenkins && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Install the wrapper script from https://raw.githubusercontent.com/docker/docker/master/hack/dind.
ADD https://raw.githubusercontent.com/docker/docker/master/hack/dind /usr/local/bin/dind
RUN chmod +x /usr/local/bin/dind

ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker

ENV \
  JENKINS_HOME="/var/lib/jenkins" \
  GIT_TIMEOUT="60" \
  MAX_HEAP_SIZE="512m" \
  MAX_PERM_SIZE="2048m"

RUN \
  usermod -a -G docker jenkins

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
