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
    apt-get install -y --no-install-recommends gettext-base mariadb-server && \
    apt-get install -y --no-install-recommends mythtv-backend-master mythtv-theme-mythbuntu iputils-ping && \
    apt-get install -y --no-install-recommends mythbuntu-control-centre && \

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
  #  chown mysql:mysql /var/lib/mysql && \
  #  printf '[mysqld]\nskip-name-resolve\n' > /etc/mysql/conf.d/skip-name-resolve.cnf && \

# clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        /usr/share/man /usr/share/groff /usr/share/info \
        /usr/share/lintian /usr/share/linda /var/cache/man && \
    (( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
    (( find /usr/share/doc -empty|xargs rmdir || true ))

# expose ports (UPnP, MythTV backend + API)
EXPOSE 5000/udp 6543 6544 22 3306
VOLUME /var/lib/mysql/

COPY ["docker-entrypoint.sh", "/"]
COPY ["config.xml", "/etc/mythtv/"]
COPY ["mariadb.conf", "/etc/supervisor/conf.d/"]
COPY ["mythtv.conf", "/etc/supervisor/conf.d/"]
