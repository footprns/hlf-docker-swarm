Docker initialize
```
docker swarm init --default-addr-pool 10.0.0.0/8 --default-addr-pool-mask-length 16 --advertise-addr ens5
docker swarm init --advertise-addr ens5
```
output
```
    docker swarm join --token SWMTKN-1-2gk3gx5e371rze3ktf61yooqvnjzwtbxdyaz2zmjuy0qrucmo4-0qn2x6yr80vwk78vtbglqhfdx 192.168.101.25:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```
check `docker node list`

create overlay network
```
docker network create --driver=overlay --attachable test
ilcqd2f6rvuq0bb4fx0btu3jv

docker network create --driver=overlay --subnet 192.168.15.0/24 --attachable test
```

check `docker network ls`

## copy code
```
$ rsync -avh --relative ./hlf-docker-swarm/test-network manager:/home/ubuntu/

then make link 
# ln -s /home/ubuntu/hlf-docker-swarm /root/hlf-docker-swarm
```

## label node
```
sudo docker node update --label-add name=manager ysw70oqlxb1z4y6s5zinslacw
sudo docker node update --label-add name=worker1 j13p1yht2sopek1jenn90o7oo
sudo docker node update --label-add name=worker2 a27ehdcdo25tydnwppruesqvy

# list label
sudo docker node ls -q | sudo xargs docker node inspect \
  -f '{{ .ID }} [{{ .Description.Hostname }}]: {{ .Spec.Labels }}'
```

## run ca
```
docker stack deploy -c docker/docker-compose-ca.yaml  hlf
```

## generate cat
```
servers=("manager" "worker1" "worker2" "worker3")

for server in "${servers[@]}"; do
    echo "Syncing to $server..."
    rsync -avh --relative ./hlf-docker-swarm/test-network "$server:/home/ubuntu/"
    rsync -avh --relative ./hlf-docker-swarm/bin "$server:/home/ubuntu/"
    rsync -avh --relative ./hlf-docker-swarm/chaincode "$server:/home/ubuntu/"
    echo "Sync to $server completed."
done

$ source ./organizations/fabric-ca/registerEnroll.sh
createOrderer
createOrg1
createOrg2
createOrg3
```

## copy org2 and 3 to master node
```
ssh-keygen -t ed25519 -C "iman@amandigital.net"
echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINeKOWL9iT1jkge5ZyA+80z1+kio6iJQWcZiHKAko3ny iman@amandigital.net | tee -a ~/.ssh/authorized_keys 
$ sudo chown -R ubuntu:ubuntu ./

servers=("worker1" "worker2" "worker3")
folders=("org1" "org2" "org3")

for i in "${!servers[@]}"; do
    server="${servers[$i]}"
    folder="${folders[$i]}"
    
    echo "Syncing from $server.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/fabric-ca/$folder/ to ./$folder"
    
    rsync -avh "ubuntu@$server.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/fabric-ca/$folder/" "./$folder"
    
    echo "Sync to ./$folder completed."
done

servers=("worker1" "worker2" "worker3")
orgs=("org1.example.com" "org2.example.com" "org3.example.com")

for i in "${!servers[@]}"; do
    server="${servers[$i]}"
    org="${orgs[$i]}"
    
    rsync -avh "ubuntu@$server.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/peerOrganizations/$org" "./peerOrganizations"
    
    echo "Sync to ./peerOrganizations completed."
done


```
## copy orders to other node
```
servers=("worker1" "worker2" "worker3")

for server in "${servers[@]}"; do
    
    rsync -avh ./ordererOrganizations "ubuntu@$server.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/"
    
    echo "Sync to $server.amandigital.net completed."
done
```

## create genesis block
```
export CHANNEL_NAME=mychannel
./scripts/createGenesis.sh
```

## create channel transaction
```
export CHANNEL_NAME=mychannel
./scripts/createChannelTx.sh

servers=("worker1" "worker2" "worker3")

for server in "${servers[@]}"; do
    
    rsync -avh ./channel-artifacts "ubuntu@$server.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/"
    
    echo "Sync to $server.amandigital.net completed."
done

```

## start container
```
sudo docker stack deploy -c docker/docker-compose-couch.yaml -c docker/docker-compose-test-net.yaml hlf


```

## create channel from cli tool
```
$ sudo docker stack deploy -c docker/docker-compose-cli.yaml  hlf
$ sudo docker exec -it dc8dd7d6502c bash
export CHANNEL_NAME=mychannel
./scripts/create_app_channel.sh # from orderer only
```

## join the channel , copy the block file to other peer
```
servers=("worker1" "worker2" "worker3")

for server in "${servers[@]}"; do
    
    rsync -avh ./channel-artifacts/mychannel.block "ubuntu@$server.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/channel-artifacts"
    
    echo "Sync to $server.amandigital.net completed."
done

$ export CHANNEL_NAME=mychannel
$ peer channel join -b ./channel-artifacts/mychannel.block

check the join
peer channel list
```

## update the anchor peers. for service discovery, cross peer communication
```
./scripts/updateAnchorPeer.sh mychannel Org1MSP # respective node
./scripts/updateAnchorPeer.sh mychannel Org2MSP
./scripts/updateAnchorPeer.sh mychannel Org3MSP
```

## package the chaincode
```

export CC_NAME=basic
./scripts/package_cc.sh

$ scp /home/ubuntu/.ssh/id_ed25519 worker1.amandigital.net:/home/ubuntu/.ssh
$ chmod 600 ~/.ssh/id_ed25519 
$ sudo chown -R ubuntu:ubuntu ./

then copy to other peer
servers=("worker2" "worker3")

for server in "${servers[@]}"; do
    
    rsync -avh ./chaincode/basic.tar.gz "ubuntu@$server.amandigital.net:/home/ubuntu/hlf-docker-swarm/chaincode"
    
    echo "Sync to $server.amandigital.net completed."
done
```

## chain code installation
```
export CC_NAME=basic
export CHANNEL_NAME=mychannel
./scripts/install_cc.sh
```

## approve chaincode
```
export CC_NAME=basic
export CHANNEL_NAME=mychannel
./scripts/approve_cc.sh
```

## check readiness (whether all peer already approve)
```
export CC_NAME=basic
export CHANNEL_NAME=mychannel
./scripts/check_commit.sh
```

## commit the chaincode
```
export CC_NAME=basic
export CHANNEL_NAME=mychannel
./scripts/commit_cc.sh # one time only

check the commited chaincode # from endorser
# peer lifecycle chaincode querycommitted --channelID mychannel --name basic
```

## transaction invocation
```
# source ./scripts/envVar.sh
parsePeerConnectionParameters 1 2 3  # if it from the org2 then parsePeerConnectionParameters 2
echo $PEER_CONN_PARMS
export CHANNEL_NAME=mychannel
export CC_NAME=basic
./scripts/invoke_cc.sh
```

## blockchain explorer
```
rsync -avh ./explorer manager:/home/ubuntu/hlf-docker-swarm/

cd explorer
./setup.sh # change the json

sudo docker stack deploy -c docker-compose.yaml hlf
```