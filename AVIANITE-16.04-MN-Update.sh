#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'avianitecoind' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop avianitecoind${NC}"
        avianitecoin-cli stop
        sleep 30
        if pgrep -x 'avianitecoind' > /dev/null; then
            echo -e "${RED}avianitecoind daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 avianitecoind
            sleep 30
            if pgrep -x 'avianitecoind' > /dev/null; then
                echo -e "${RED}Can't stop avianitecoind! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your Avianitecoin Masternode Will be Updated To The Latest Version v3.1.0 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'avianiteauto.sh' | crontab -

#Stop avianitecoind by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/avianite*
mkdir AVIANITE_3.1.0
cd AVIANITE_3.1.0
wget https://github.com/IDCHAINGROUP/AVIANITE/releases/download/v3.1.0/avianite-3.1.0-16.04-ubuntu.tar.gz
tar -xzvf avianite-3.1.0-16.04-ubuntu.tar.gz
mv avianitecoind /usr/local/bin/avianitecoind
mv avianitecoin-cli /usr/local/bin/avianitecoin-cli
chmod +x /usr/local/bin/avianite*
rm -rf ~/.avianitecoin/blocks
rm -rf ~/.avianitecoin/chainstate
rm -rf ~/.avianitecoin/sporks
rm -rf ~/.avianitecoin/peers.dat
cd ~/.avianitecoin/
wget https://github.com/IDCHAINGROUP/AVIANITE/releases/download/v3.1.0/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.avianitecoin/bootstrap.zip ~/AVIANITE_3.1.0

# add new nodes to config file
sed -i '/addnode/d' ~/.avianitecoin/avianitecoin.conf

echo "addnode=108.61.220.138
addnode=207.246.102.131
addnode=45.77.68.89
addnode=45.76.168.47" >> ~/.avianitecoin/avianitecoin.conf

#start avianitecoind
avianitecoind -daemon

printf '#!/bin/bash\nif [ ! -f "~/.avianitecoin/avianitecoind.pid" ]; then /usr/local/bin/avianitecoind -daemon ; fi' > /root/avianiteauto.sh
chmod -R 755 /root/avianiteauto.sh
#Setting auto start cron job for Avianitecoin
if ! crontab -l | grep "avianiteauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/avianiteauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"