#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

source scriptUtils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/ca.crt

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/ordererOrganizations/amandigital.net/users/Admin@amandigital.net/msp
}

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.amandigital.net/users/Admin@org1.amandigital.net/msp
    export CORE_PEER_ADDRESS=peer0.org1.amandigital.net:7051
    export CORE_PEER_TLS_CERT_FILE=${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/server.crt
    export CORE_PEER_TLS_KEY_FILE=${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/server.key
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.amandigital.net/users/Admin@org2.amandigital.net/msp
    export CORE_PEER_ADDRESS=peer0.org2.amandigital.net:9051
    export CORE_PEER_TLS_CERT_FILE=${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/server.crt
    export CORE_PEER_TLS_KEY_FILE=${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/server.key
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.amandigital.net/users/Admin@org3.amandigital.net/msp
    export CORE_PEER_ADDRESS=peer0.org3.amandigital.net:11051
    export CORE_PEER_TLS_CERT_FILE=${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/server.crt
    export CORE_PEER_TLS_KEY_FILE=${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/server.key
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_ORG$1_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}