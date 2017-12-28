#!/usr/bin/env bash
# Starts syncing a full node
#
# alias progress='BLOCKS=`bitcoin-cli getblockcount 2>&1`; HEADERS=`wget -O - http://blockchain.info/q/getblockcount 2>/dev/null`; awk "BEGIN {print $BLOCKS/$HEADERS; exit}"'
# Mining pool owners on the other hand may not want to adopt the block pruning option at all. Granted, with 550 blocks of history, it should be possible to validate newly mined blocks on the network without too much trouble. However, it might be in their best interest to keep the blockchain stored in its entirety as a failsafe as well.
#
# With the recent issue surrounding invalid Bitcoin block validation, 550 blocks is not exactly a major buffer to prevent a potential Bitcoin fork. And if the majority of mining pools end up on on a fork of the network for a lengthy period of time, all hell will break loose. Granted, that issue affecting invalid block confirmations has been rectified in a swift manner, but invalid blocks were being generated at an alarming rate for a lengthy period of time.
#
# Companies providing a Bitcoin service are a different matter entirely. Any financial platforms should stick to the full blockchain at all times, no matter what. Other companies, such as the ones providing API access for example, can use block pruning to their advantage, while keeping a copy of the entire blockchain running simultaneously to see which option can handle the user’s requests better.
# TODO: adjust dbcache according to RAM of digitalocean

exec > ~/user-data.log
exec 2>&1

set -e
set -x

echo "########### Creating Swap"
date
dd if=/dev/zero of=/swapfile bs=1M count=2048 ; mkswap /swapfile ; swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
echo "########### Install dependencies of bitcoin apart from Berkeley DB"
sudo apt-get update
sudo apt-get -y install software-properties-common python-software-properties build-essential wget htop git build-essential autoconf autotools-dev automake libboost-all-dev libssl-dev pkg-config libevent-dev bsdmainutils libprotobuf-dev protobuf-compiler libqt4-dev libqrencode-dev libtool libcurl4-openssl-dev
#db4.8 
echo "########### Compiling and installing Berkeley DB. Bitcoin does not support the berkeley db that comes with ubuntu 16.04"
wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix
../dist/configure --enable-cxx --prefix=/usr
make -j8
sudo make install
echo "########### Compiling and installing Bitcoin. Bitcoin does not support ubuntu 16.04 due to its 'ancient gcc and Boost versions'."
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin
git checkout v0.15.1
./autogen.sh
./configure --without-gui --without-upnp --disable-tests
make
make install
cd -
echo "########### Formating volume lazily as the sometimes the volume is not available initially at digitalocean"
vid=`ls /dev/disk/by-id/`
volume="/dev/disk/by-id/$vid"
partition="$volume""-part1"
mountpoint="/mnt/$vid""-part1"
sudo parted $volume mklabel gpt
sudo parted -a opt $volume mkpart primary ext4 0% 100%
sleep 2
sudo mkfs.ext4 -F $partition
sudo mkdir -p $mountpoint
echo "$partition $mountpoint ext4 defaults,nofail,discard 0 2" | sudo tee -a /etc/fstab
sudo mount -a
sudo chmod 777 $mountpoint
echo "########### Configure bitcoind"
mkdir $mountpoint/Bitcoin
mkdir ~/.bitcoin
cat <<EOT >> ~/.bitcoin/bitcoin.conf
datadir=$mountpoint/Bitcoin
txindex=1
server=1
blocksonly=1
rpcuser=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
rpcpassword=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
EOT
sudo apt-get install -y iotop iftop ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 8332/tcp
sudo ufw --force enable
echo "########### Starting full node"
date
bitcoind
