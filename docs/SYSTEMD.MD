## Setting up P2Pool as a systemd service (Linux)

With this config, P2Pool will run as a service with redirected I/O. It uses `n2pool` user which you should setup beforehand.

You can execute console commands by running `echo "status" > /run/n2pool/n2pool.control`

### n2pool.service
```
[Unit]
Description=n2pool daemon
After=network-online.target systemd-modules-load.service monerod.service
Wants=network-online.target systemd-modules-load.service monerod.service
Requires=n2pool.socket

[Service]
Type=exec
Sockets=n2pool.socket
StandardInput=socket
StandardOutput=journal
StandardError=journal

# /usr/local/bin/n2pool.sh simply invokes the n2pool executable with your chosen command-line options. 
ExecStart=/usr/local/bin/n2pool.sh
TimeoutStopSec=60

# Run as n2pool:n2pool
User=n2pool
Group=n2pool

WorkingDirectory=/var/lib/n2pool

[Install]
WantedBy=multi-user.target
```

### n2pool.socket
```
# FIFO socket for controlling n2pool daemon
[Unit]
Description=Command FIFO for n2pool daemon

[Socket]
ListenFIFO=/run/n2pool/n2pool.control
DirectoryMode=0755
SocketMode=0666
SocketUser=n2pool
SocketGroup=n2pool
RemoveOnStop=true
```
