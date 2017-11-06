FROM apnar/ubuntu-mate-x2go-desktop

USER root

# set correct environment variables
ENV USER=mythtv \
    DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

# add repositories
RUN add-apt-repository universe -y && \
    apt-add-repository ppa:mythbuntu/0.28 -y && \

    apt-get update -qq && \

# install mythtv-backend, database and ping util
    apt-get install -y --no-install-recommends mythtv-backend mythtv-database mythtv-theme-mythbuntu iputils-ping && \

# create/place required files/folders
    mkdir -p /home/mythtv/.mythtv /var/lib/mythtv /var/log/mythtv /var/run/mysqld /root/.mythtv \
        /mnt/movies /mnt/recordings && \

# set a password for user mythtv and add to required groups
    echo "mythtv:mythtv" | chpasswd && \
    usermod -s /bin/bash -d /home/mythtv -a -G users,mythtv,adm,sudo mythtv && \

# have myth setup use proper start and stop scripts
    sed -i 's#/usr/sbin/service mythtv-backend stop#/usr/bin/supervisorctl stop mythtv#' /usr/bin/mythtv-setup && \
    sed -i 's#/usr/sbin/service mythtv-backend start#/usr/bin/supervisorctl start mythtv#' /usr/bin/mythtv-setup && \

# set permissions for files/folders
    chown -R mythtv:users /var/lib/mythtv /var/log/mythtv /mnt/recordings /mnt/movies && \

# install mariadb
    groupadd mysql && \
    useradd -g mysql mysql && \
    apt-get install -y gettext-base mariadb-server pwgen && \
    rm -rf /var/lib/mysql && \
    mkdir --mode=0777 /var/lib/mysql /var/run/mysqld && \
    chown mysql:mysql /var/lib/mysql && \
    printf '[mysqld]\nskip-name-resolve\n' > /etc/mysql/conf.d/skip-name-resolve.cnf && \
    chmod 0777 -R /var/lib/mysql /var/log/mysql && \
    chmod 0775 -R /etc/mysql && \
    cat > /etc/supervisor/conf.d/mariadb-10.0.conf <<EOF
[program:mariadb-10.0]
command=mysqld_safe
autostart=true
autorestart=true
startretries=3

stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOF && \


# clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        /usr/share/man /usr/share/groff /usr/share/info \
        /usr/share/lintian /usr/share/linda /var/cache/man && \
    (( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
    (( find /usr/share/doc -empty|xargs rmdir || true ))

# expose ports (UPnP, MythTV backend + API)
EXPOSE 5000/udp 6543 6544 22
VOLUME /var/lib/mysql/

COPY ["*.sh", "/"]
COPY ["config.xml", "/etc/mythtv/"]
COPY ["*.conf", "/etc/supervisor/conf.d/"]
