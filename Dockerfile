FROM docker.io/alpine:3.8

MAINTAINER Andrew Cutler <andrew@panubo.com>

RUN	sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \  	
    apk add --update bash git openssh-server rsync augeas e2fsprogs nfs-utils supervisor && \
    deluser $(getent passwd 33 | cut -d: -f1) && \
    delgroup $(getent group 33 | cut -d: -f1) 2>/dev/null || true && \
    mkdir -p ~root/.ssh /etc/authorized_keys && chmod 700 ~root/.ssh/ && \
    augtool 'set /files/etc/ssh/sshd_config/AuthorizedKeysFile ".ssh/authorized_keys /etc/authorized_keys/%u"' && \
    echo -e "Port 22\n" >> /etc/ssh/sshd_config && \
    cp -a /etc/ssh /etc/ssh.cache && \
    mkdir -p -m0755 /var/run/sshd && \
    rm -rf /var/cache/apk/* 
  
  
EXPOSE 22 9001  
  
COPY resources/etc /etc
COPY resources/entry.sh /entry.sh  
RUN  chmod +x /entry.sh
ENTRYPOINT ["/entry.sh"]    
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
  
  
