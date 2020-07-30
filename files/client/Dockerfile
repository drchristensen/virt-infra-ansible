FROM centos:8.2.2004
MAINTAINER David Christensen <drc@ibm.com>
RUN yum update -y; yum install -y qperf crontabs; yum clean all

# Add the actual qperf test script
ADD qperf-test.sh /root/qperf-test.sh
RUN chmod 0744 /root/qperf-test.sh

ADD entry.sh /root/entry.sh
RUN chmod 0744 /root/entry.sh

# Modify PAM to X and setup the environment correctly
RUN sed -i -e '/pam_loginuid.so/s/^/#/' /etc/pam.d/crond

# Add the qperf cron file
ADD qperf.cron /etc/cron.d/qperf.cron
RUN chmod 0644 /etc/cron.d/qperf.cron
RUN touch /var/log/cron

# This will add it to the cron table (crontab -e)
RUN crontab /etc/cron.d/qperf.cron

# Run our script
ENTRYPOINT ["/root/entry.sh"]
CMD ["client"]
