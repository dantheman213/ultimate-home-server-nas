# Home Server Powerhouse

A list of curated software to replace Unraid, FreeNAS, OpenMediaVault, Proxmox, etc focused on serving the home or small businuess.

Find the apps you need for NAS, VMs, Containers, Shares, Streams, and Services.

### Curated Software

#### Operating System

* Ubuntu
* Debian
* RHEL
* CentOS

#### Filesystem
* ZFS with RAIDZ2 configuration
* UnionFS + SnapRaid (a possible alternative)

#### General Management Interfaces
* Heimdall
* Cockpit
* Webmin
* Virtualmin

#### Monitoring / Metrics

* Grafana
* Netdata
https://github.com/netdata/netdata

#### Docker
* Docker
* Portainer
* Rancher

#### KVM / QEMU / Virtual Machine Management
* vMango
* Kimchi
https://github.com/kimchi-project/kimchi
* oVirt (RHEL)
https://www.ovirt.org/download/
* webvirtmgr

#### UPS / Disaster Prevention
* NUT
https://networkupstools.org/index.html
* apcupsd
* WinPower

#### Disk Integrity
* Smartmontools

#### DNS
* DuckDNS
* PiHole

#### File Share

##### SMB/CIFS

##### NFS

##### AFP

##### FTPS

##### Rsync Server

##### DLNA

* Rygel

NOTE: minidlna, uShare, mediatomb are no longer supported projects.

#### Media Conversion
* Handbrake with web GUI
* ffmpeg (CLI)

#### Spotify Extraction
* Spytify
https://jwallet.github.io/spy-spotify/overview.html

#### BitTorrent Client / Media Ingestion
* Deluge with Web GUI
* Transmission
* qbittorrent

#### UseNet / Media Ingestion
* nzbget

#### Media Tracker
* Bobarr
* Sickrage
* Sickbeard
* Sonarr

#### Code Management
* GitLab

#### Personal Cloud
* NextCloud
* FileCloud
* OwnCloud

#### Password Management
* Bitwarden

#### Backup Tools
* Duplicati

#### Backup Services
* Backblaze Personal Backup
* AWS S3 Deep Glacier
* Google Drive
* Dropbox

#### Audio specific Streaming Apps
* Volumio
* Madsonic
* Libresonic
* Subsonic

#### Video or Multimedia Streaming Apps
* Plex
* Tautulli
* Emby
* Jellyfin

#### Secure Remote Entry
* OpenVPN Server

#### SSL Management
* Let’s Encrypt
* openssl

#### Home Automation
* HomeAssistant

#### CCTV / NVR Management
?

#### Tor / Privacy Proxy
* DockerHub linuxconfig/instantprivacy

#### SOCKS5 / Proxy
?

#### Data Syncing Between High Speed Cache To Disk Array
* Rsync with Cron. Overwrite files automatically?
* Use a cache disk built into ZFS

#### ZFS Management Tools

* zpool
