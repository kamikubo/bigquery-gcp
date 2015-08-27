# GCP
# Dockerfile for FluentdبႹ sample code
#
# This image will run nginx, fluentd and bigquery plugin to send access log to BigQuery.
#

FROM ubuntu:14.04

# environment
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

# update, curl, sudo
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install curl 
RUN apt-get -y install sudo

# fluentd
RUN curl -O http://packages.treasure-data.com/debian/RPM-GPG-KEY-td-agent && apt-key add RPM-GPG-KEY-td-agent && rm RPM-GPG-KEY-td-agent
RUN curl -L http://toolbelt.treasuredata.com/sh/install-ubuntu-precise-td-agent2.sh | sh 
ADD td-agent.conf /etc/td-agent/td-agent.conf
RUN curl -L https://raw.githubusercontent.com/fluent/fluentd/master/COPYING > /fluentd-license.txt

# nginx
RUN apt-get install -y nginx
ADD nginx.conf /etc/nginx/nginx.conf
RUN curl -L http://nginx.org/LICENSE > /nginx-license.txt

# fluent-plugin-bigquery
RUN /usr/sbin/td-agent-gem install fluent-plugin-bigquery --no-ri --no-rdoc -V
RUN curl -L https://raw.githubusercontent.com/kaizenplatform/fluent-plugin-bigquery/master/LICENSE.txt > fluent-plugin-bigquery-license.txt

# nagios
RUN apt-get install nagios-nrpe-server nagios-plugins
ADD nrpe.cfg /etc/nagios/nrpe.cfg
ADD check_mem.pl /usr/lib/nagios/plugins/check_mem.pl

# start fluentd and nginx and nrpe
EXPOSE 80
ENTRYPOINT /etc/init.d/td-agent restart&& /etc/init.d/nagios-nrpe-server start && /etc/init.d/nginx start && /bin/bash

## auto start
RUN aptitude -y install sysv-rc-conf
RUN sysv-rc-conf nagios-nrpe-server on
RUN sysv-rc-conf td-agent on
RUN sysv-rc-conf nginx on
