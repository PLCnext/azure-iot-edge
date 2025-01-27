#!/bin/bash
echo "SetupEdge.SH Script"
echo "Execute as root!"

## Setup Docker/balena/moby
# See other tutorial

## FIND MACHINE TYPE
# ONLY PLCNEXT ARM32V7 or X86 are supported

# VERSION=$(echo "$VERSION" | sed 's|+|.|g')

machine=$(uname -m)

case "$machine" in
#	"armv5"*)
#		arch="armv5"
#		;;
#	"armv6"*)
#		arch="armv6"
#		;;
	"armv7"*)
		arch="armv7"
		;;
#	"armv8"*)
#		arch="aarch64"
#		;;
#	"aarch64"*)
#		arch="aarch64"
#		;;
#	"i386")
#		arch="i386"
#		;;
#	"i686")
#		arch="i386"
#		;;
	"x86_64")
		arch="x86_64"
		;;
	*)
		echo "Unknown machine type: $machine"
		exit 1
esac

echo "Machine type: $machine"

echo "Setting up Docker/moby"
echo " Binaries included in repo"

set -x
mkdir tmp_moby

case "$arch" in
	"armv7")
		curl  -L https://packages.microsoft.com/repos/microsoft-debian-stretch-multiarch-prod/pool/main/m/moby-engine/moby-engine_3.0.13%2Bazure-0_armhf.deb -o moby_engine.deb
		curl  -L https://packages.microsoft.com/repos/microsoft-debian-stretch-multiarch-prod/pool/main/m/moby-cli/moby-cli_3.0.13%2Bazure-0_armhf.deb -o moby_cli.deb
		;;
	"x86_64")
		curl  -L https://packages.microsoft.com/repos/microsoft-debian-stretch-multiarch-prod/pool/main/m/moby-engine/moby-engine_3.0.13%2Bazure-0_amd64.deb -o moby_engine.deb
		curl  -L https://packages.microsoft.com/repos/microsoft-debian-stretch-multiarch-prod/pool/main/m/moby-cli/moby-cli_3.0.13%2Bazure-0_amd64.deb 	-o moby_cli.deb
		;;
esac
		
dpkg -x ./moby_engine.deb tmp_moby
dpkg -x ./moby_cli.deb tmp_moby


cp -R ./tmp_moby/* ./archive/


echo " Docker setup succesfull"
echo " extract archive"

cd archive
chmod +x setup.sh
./setup.sh

cd ..

### BEGIN INIT INFO
## This is a Beta

## Download binaries
mkdir tmp_install
cd tmp_install

#curl  -L https://aka.ms/libiothsm-std-linux-armhf-latest -o libiothsm-std.deb
#curl  -L https://aka.ms/iotedged-linux-armhf-latest -o iotedge.deb

case "$arch" in
	"armv7")
		curl  -L https://github.com/Azure/azure-iotedge/releases/download/1.1.6/libiothsm-std_1.1.6-1-1_debian9_armhf.deb -o libiothsm-std.deb
		curl  -L https://github.com/Azure/azure-iotedge/releases/download/1.1.6/iotedge_1.1.6-1_debian9_armhf.deb -o iotedge.deb
		;;
	"x86_64")
		curl  -L https://github.com/Azure/azure-iotedge/releases/download/1.0.10.4/libiothsm-std_1.0.10.4-1-1_debian9_amd64.deb -o libiothsm-std.deb
		curl  -L https://github.com/Azure/azure-iotedge/releases/download/1.0.10.4/iotedge_1.0.10.4-1_debian9_amd64.deb -o iotedge.deb
		;;
esac

dpkg -x iotedge.deb .
dpkg -x libiothsm-std.deb .
chown -R admin:plcnext *

cp -r * /
## Preinstall set groups
    adduser --system iotedge --home /var/lib/iotedge --shell /bin/false
    addgroup --system iotedge
# add iotedge user to docker group so that it can talk to the docker socket
    adduser iotedge docker
    usermod -a -G docker iotedge
    usermod -a -G iotedge iotedge
# Add each admin user to the iotedge group - for systems installed before precise
    usermod -a -G  iotedge admin >/dev/null || true
    usermod -a -G  iotedge plcnext_firmware>/dev/null || true
# Add each sudo user to the iotedge group
    usermod -a -G  iotedge root >/dev/null || true


cd ..
rm -r tmp_install


update-rc.d -f iotedge remove

mv /etc/init.d/iotedge /etc/init.d/iotedge.backup
cp ./iotedge /etc/init.d/iotedge
chmod +x /etc/init.d/iotedge
chown root:root /etc/init.d/iotedge
chmod +x /etc/init.d/iotedge
 
export IOTEDGE_HOMEDIR=/var/lib/iotedge

echo "Set localTime"
date
rm /etc/localtime
ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime
echo "server 0.de.pool.ntp.org" >> /etc/ntp.conf
/etc/init.d/ntpd restart

echo "Setting up ${MyContainerRuntime} "

mkdir -p /var/run/iotedge/
chmod 774 /var/run/iotedge
chown admin:plcnext /var/run/iotedge

mkdir -p /var/lib/iotedge
chmod 774 /var/lib/iotedge
chown admin:plcnext /var/lib/iotedge


# TODO: Change your connect string and Agent image here!

cp ./config.yaml /etc/iotedge


# Setup IP Tables 

#chmod +x /usr/sbin/ip6tables /usr/sbin/ip6tables-restore /usr/sbin/ip6tables-save
#chmod +x /usr/sbin/iptables /usr/sbin/iptables-restore /usr/sbin/iptables-save

#ln -s -f /usr/lib/libip4tc.so.0.1.0  /usr/lib/libip4tc.so.0
#ln -s -f /usr/lib/libip6tc.so.0.1.0 /usr/lib/libip6tc.so.0
#ln -s -f /usr/lib/libiptc.so.0.0.0 /usr/lib/libiptc.so.0
#ln -s -f /usr/lib/libxtables.so.12.0.0 libxtables.so.12


## RC Update 
### configure autostart of iotedge

update-rc.d iotedge defaults 98
## 


