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
10.30.72.19   fedscale-server server\n
10.30.72.9    fedscale-agent1 agent1\n
10.30.72.29   fedscale-agent2 agent2\n
10.30.72.30   fedscale-agent3 agent3\n
10.30.72.31   fedscale-agent4 agent4\n
10.30.72.32   fedscale-agent5 agent5\n
10.30.72.33   fedscale-agent6 agent6\n
10.30.72.34   fedscale-agent7 agent7\n
"

SSH_KEY=`sudo cat ~/.ssh/id_rsa.pub`

ssh -i ~/.ssh/id_rsa_client1 -oStrictHostKeyChecking=no -p$PORT \
        ubuntu@$IP "bash -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
                    echo $SSH_KEY | tee -a ~/.ssh/authorized_keys > /dev/null'"

green "\nAdding hosts to /etc/hosts"
echo -e $HOSTS | ssh -oStrictHostKeyChecking=no -p$PORT ubuntu@$IP "sudo bash -c 'cat | tee /etc/hosts > /dev/null'"

green "\nRuuning batch commands"
scp -P$PORT -oStrictHostKeyChecking=no ntp.patch ubuntu@$IP:/tmp
scp -P$PORT -oStrictHostKeyChecking=no ~/Anaconda3-2020.11-Linux-x86_64.sh ubuntu@$IP:~
ssh -oStrictHostKeyChecking=no -p$PORT \
        ubuntu@$IP "sudo bash -c 'apt-get update && apt-get install ntp python3-pip -yqq && 
                patch -u /etc/ntp.conf -i /tmp/ntp.patch && \
                sudo service ntp restart && \
                git clone -b feature/savi https://github.com/etesami/FedScale.git && \
                cd ~/FedScale && chmod +x ./install.sh && ./install.sh
                '"
                
ssh -oStrictHostKeyChecking=no -p$PORT \
        ubuntu@$IP "sudo bash -c '
                cd ~/FedScale && chmod +x ./install-create-env.sh && ./install-create-env.sh
                '"


# docker build /home/ubuntu/examples/mnist-pytorch/ -t mnist-client:latest
 
# sudo docker-compose -f docker-compose.yaml -f extra-hosts.yaml up --build