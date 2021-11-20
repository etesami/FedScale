#!/usr/bin/env bash

help="Usage: 
    ./this_script IP"
eval "$(docopts -A args -h "$help" : "$@")"
source ~/.colors
PORT=22
IP=${args[IP]}


HOSTS="
\n
127.0.0.1 localhost\n\n
10.30.72.19   fed-server server\n
10.30.72.9    fed-agent1 agent1\n
10.30.72.29   fed-agent2 agent2\n
10.30.72.30   fed-agent3 agent3\n
10.30.72.31   fed-agent4 agent4\n
10.30.72.32   fed-agent5 agent5\n
10.30.72.33   fed-agent6 agent6\n
10.30.72.34   fed-agent7 agent7\n
"

SSH_KEY=`sudo cat ~/.ssh/id_rsa.pub`

ssh -i ~/.ssh/id_rsa_client1 -oStrictHostKeyChecking=no -p$PORT \
        ubuntu@$IP "bash -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
                    echo $SSH_KEY | tee -a ~/.ssh/authorized_keys > /dev/null'"

echo -e $HOSTS | ssh -oStrictHostKeyChecking=no -p$PORT ubuntu@$IP "sudo bash -c 'cat | tee /etc/hosts > /dev/null'"

echo -e "\n${grn}Ruuning batch commands${noc}"
scp -P$PORT -oStrictHostKeyChecking=no ntp.patch ubuntu@$IP:/tmp
ssh -oStrictHostKeyChecking=no -p$PORT \
        ubuntu@$IP "sudo bash -c 'apt-get update && apt-get install ntp python3-pip -yqq && 
                patch -u /etc/ntp.conf -i /tmp/ntp.patch && \
                sudo service ntp restart && \
                git clone -b feature/savi https://github.com/etesami/FedScale.git && \
                cd ~/FedScale && ./install.sh
                '"


# docker build /home/ubuntu/examples/mnist-pytorch/ -t mnist-client:latest
 
# sudo docker-compose -f docker-compose.yaml -f extra-hosts.yaml up --build