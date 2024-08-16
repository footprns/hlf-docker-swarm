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
$ rsync -avh ../hlf-docker-swarm/test-network man
ager:/home/ubuntu

then make link 
# ln -s /home/ubuntu/hlf-docker-swarm /root/hlf-docker-swarm
```

## label node
```
docker node update --label-add name=manager 7jcyn7ef6istotpowvd0dtmxw
docker node update --label-add name=worker1 x125ruaxxw1cbp9sn4eg7508e
docker node update --label-add name=worker2 yjlxht0j5pqdzv65nava6k4sq

# list label
docker node ls -q | xargs docker node inspect \
  -f '{{ .ID }} [{{ .Description.Hostname }}]: {{ .Spec.Labels }}'
```

## run ca
```
docker stack deploy -c docker/docker-compose-ca.yaml --network test hlf
```

## generate cat
```
$ source ./organizations/fabric-ca/registerEnroll.sh
createOrderer
createOrg1
createOrg2
createOrt3
```

## copy org2 and 3 to master node
```
$ sudo chown -R ubuntu:ubuntu ./

rsync -avh ubuntu@worker1.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/fabric-ca/org2/ ./org2
rsync -avh ubuntu@worker2.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/fabric-ca/org3/ ./org3

rsync -avh ubuntu@worker1.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/peerOrganizations/org2.example.com ./peerOrganizations

rsync -avh ubuntu@worker2.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/peerOrganizations/org3.example.com ./peerOrganizations

```
## copy orders to other node
```
rsync -avh ./ordererOrganizations ubuntu@worker1.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/

rsync -avh ./ordererOrganizations ubuntu@worker2.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/organizations/
```

## create genesis block
```
./scripts/createGenesis.sh
```

## create channel transaction
```
export CHANNEL_NAME=mychannel
./scripts/createChannelTx.sh

rsync -avh ./channel-artifacts ubuntu@worker1.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/
rsync -avh ./channel-artifacts ubuntu@worker2.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/
```

## start container
```
sudo docker stack deploy -c docker/docker-compose-couch.yaml -c docker/docker-compose-test-net.yaml hlf

mkdir /home/ubuntu/hlf-docker-swarm/chaincode/
```

## create channel from cli tool
```
$ sudo docker exec -it dc8dd7d6502c bash
export CHANNEL_NAME=mychannel
./script/create_app_channel.sh
```

## join the channel , copy the block file to other peer
```
rsync -avh ./channel-artifacts/mychannel.block ubuntu@worker1.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/channel-artifacts
rsync -avh ./channel-artifacts/mychannel.block ubuntu@worker2.amandigital.net:/home/ubuntu/hlf-docker-swarm/test-network/channel-artifacts

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
copy the code
$ rsync -avh ./chaincode manager:/home/ubuntu/hlf-docker-swarm/

export CC_NAME=basic
./scripts/package_cc.sh

then copy to other peer
```

## chain code installation
```
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
./scripts/check_commit.sh
```

## commit the chaincode
```
./scripts/commit_cc.sh

check the commited chaincode
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

./exporer/setup.sh # change the json

sudo docker stack deploy -c docker-compose.yaml hlf
```