FROM centos:8.2.2004
MAINTAINER David Christensen <drc@ibm.com>
RUN yum update -y; yum install -y qperf; yum clean all
CMD /usr/bin/qperf -lp $QPERF_PORT
