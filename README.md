# Docker Container for MythTV

This is a Docker image for running the MythTV package
based on the work done by Floppe. I've added in mariadb
so that it's standalone as well as bumped mythtv to version 29.
Access to backend setup is via x2go.  Note that this is not secured
really in any way so be sure you're running it on a trusted network
or secure it yourself.


Run Directly:
```
docker run -d \
           --name mythtv \
           --net=host \
           -h mythtv.local \
           -v <database directory>:/var/lib/mysql \
           -v <recordings directory>:/mnt/recordings \
           -v /etc/localtime:/etc/localtime:ro \
           apnar/mythtv-backend
```
On first run it'll initialize the mariadb but the backend won't start until configured.

You'll need to download the x2go client if you don't already have it from here:

https://wiki.x2go.org/doku.php/download:start

Then connect to your docker host using x2go on port 6522 with username 'mythtv' and password 'mythtv'.

You should see a MythTV Backend Setup icon on the desktop that you can launch to configure MythTV.

Configuring MythTV is it's own thing which you can read more about here:

https://www.mythtv.org/wiki/Configuring_MythTV

A few notes as you do the configuration.

 - In the Host Address Beckend Setup I suggest making the Primary IP address the regular IP of your docker host.
 - Mapped recordings directory is /mnt/recordings 


## Note:

I generally try to avoid using host networking whenever possible but MythTV doesn't support advertizing
an IP address that it doesn't see on the box itself.  This resulted in clients not being able to access
the backend correctly unless host networking was used. Ports used are:

3306 - mariadb
6522 - ssh (used for x2go)
6543 - mythtv
6544 - mythtv

