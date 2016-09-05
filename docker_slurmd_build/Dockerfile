FROM docker-slurm:latest

#EXPOSE 22
ADD deploy.sh /root/deploy.sh
RUN chmod +x /root/deploy.sh

ADD supervisord.slurmd /etc/supervisord.d/slurmd.ini
CMD ["/bin/bash","/root/deploy.sh"]
#CMD /usr/bin/supervisord
#CMD ["sh", "-c", "exec /usr/sbin/slurmd"]


