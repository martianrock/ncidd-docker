# ncidd-docker
Dockerized NCID (network caller id) daemon service.

See https://sourceforge.net/projects/ncid/ for NCID information.
This image contains only ncidd, the service portion of NCID project.

Logs are not written to /var/log/ncidd.log, only stdout/stderr from the daemon are sent to docker logs.

This image implements docker healthchecks by periodically sending "HELLO: CMD: no_log" and then "GOODBYE" commands to the local ncidd. State of the container is considered healthy when 200 Server: ncidd response is received back.

Configuration:
Mount /etc/ncid outside of this container. Container's startup scripts check for empty/missing /etc/ncid and restore content with default configs, so run it the first time with /etc/ncid mounted as a volume in writeable mode. Once it is done, you can put mount in read-only mode and start tweaking your ncidd configs. Follow http://ncid.sourceforge.net/doc/NCID-UserManual.html for details on configuring ncidd.
