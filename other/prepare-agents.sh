#!/usr/bin/env bash

help="Usage: 
    ./this_script IP"
eval "$(docopts -A args -h "$help" : "$@")"
source ~/.colors
PORT=22
IP=${args[IP]}

# for ii in {8..40}; do echo "10.30.72.$(( $ii+30 ))   fedscale-agent$ii agent$ii\n" >> hosts-fedscale; done

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
10.30.72.38   fedscale-agent8 agent8\n
10.30.72.39   fedscale-agent9 agent9\n
10.30.72.40   fedscale-agent10 agent10\n
10.30.72.41   fedscale-agent11 agent11\n
10.30.72.42   fedscale-agent12 agent12\n
10.30.72.43   fedscale-agent13 agent13\n
10.30.72.44   fedscale-agent14 agent14\n
10.30.72.45   fedscale-agent15 agent15\n
10.30.72.46   fedscale-agent16 agent16\n
10.30.72.47   fedscale-agent17 agent17\n
10.30.72.48   fedscale-agent18 agent18\n
10.30.72.49   fedscale-agent19 agent19\n
10.30.72.50   fedscale-agent20 agent20\n
10.30.72.51   fedscale-agent21 agent21\n
10.30.72.52   fedscale-agent22 agent22\n
10.30.72.53   fedscale-agent23 agent23\n
10.30.72.54   fedscale-agent24 agent24\n
10.30.72.55   fedscale-agent25 agent25\n
10.30.72.56   fedscale-agent26 agent26\n
10.30.72.57   fedscale-agent27 agent27\n
10.30.72.58   fedscale-agent28 agent28\n
10.30.72.59   fedscale-agent29 agent29\n
10.30.72.60   fedscale-agent30 agent30\n
10.30.72.61   fedscale-agent31 agent31\n
10.30.72.62   fedscale-agent32 agent32\n
10.30.72.63   fedscale-agent33 agent33\n
10.30.72.64   fedscale-agent34 agent34\n
10.30.72.65   fedscale-agent35 agent35\n
10.30.72.66   fedscale-agent36 agent36\n
10.30.72.67   fedscale-agent37 agent37\n
10.30.72.68   fedscale-agent38 agent38\n
10.30.72.69   fedscale-agent39 agent39\n
10.30.72.70   fedscale-agent40 agent40\n
"

SSH_KEY=`sudo cat ~/.ssh/id_rsa.pub`

ssh -i ~/.ssh/id_rsa_client1 -oStrictHostKeyChecking=no -p$PORT \
        ubuntu@$IP "bash -c 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && \
                    echo $SSH_KEY | tee -a ~/.ssh/authorized_keys > /dev/null'"

green "\nAdding hosts to /etc/hosts"
echo -e $HOSTS | ssh -oStrictHostKeyChecking=no -p$PORT ubuntu@$IP "sudo bash -c 'cat | tee /etc/hosts > /dev/null'"

green "\nRuuning batch commands and install conda"
scp -P$PORT -oStrictHostKeyChecking=no ntp.patch ubuntu@$IP:/tmp
scp -P$PORT -oStrictHostKeyChecking=no ~/Anaconda3-2020.11-Linux-x86_64.sh ubuntu@$IP:~
# ssh -oStrictHostKeyChecking=no -p$PORT \
#         ubuntu@$IP "sudo bash -c 'cd ~/FedScale && git reset --hard && git pull
#                 '"
ssh -oStrictHostKeyChecking=no -p$PORT \
        ubuntu@$IP "sudo bash -c 'apt-get update && apt-get install ntp python3-pip -yqq && 
                patch -u /etc/ntp.conf -i /tmp/ntp.patch && \
                sudo service ntp restart && \
                git clone -b feature/savi https://github.com/etesami/FedScale.git && \
                cd ~/FedScale && chmod +x ./install.sh && ./install.sh
                '"
ssh -oStrictHostKeyChecking=no -p$PORT \
        ubuntu@$IP "sudo bash -c 'chown -Rf ubuntu:ubuntu /home/ubuntu/*
                '"

# docker build /home/ubuntu/examples/mnist-pytorch/ -t mnist-client:latest
 
# sudo docker-compose -f docker-compose.yaml -f extra-hosts.yaml up --build