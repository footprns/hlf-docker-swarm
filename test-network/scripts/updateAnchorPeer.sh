
# NOTE: this must be run in a CLI container
CHANNEL_NAME=$1
CORE_PEER_LOCALMSPID=$2

peer channel update -o orderer.amandigital.net:7050 \
 --ordererTLSHostnameOverride orderer.amandigital.net \
 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls \
 --cafile $ORDERER_CA 