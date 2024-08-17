#!/bin/bash

source scriptUtils.sh
export PATH=${PWD}/../bin:$PATH
function createOrg1() {
  mkdir channel-artifacts
  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/peerOrganizations/org1.amandigital.net/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.amandigital.net/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org1.amandigital.net/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/org1.amandigital.net/peers
  mkdir -p organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/msp --csr.hosts peer0.org1.amandigital.net --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.amandigital.net/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls --enrollment.profile tls --csr.hosts peer0.org1.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/keystore/* ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.amandigital.net/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.amandigital.net/tlsca
  cp ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org1.amandigital.net/tlsca/tlsca.org1.amandigital.net-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org1.amandigital.net/ca
  cp ${PWD}/organizations/peerOrganizations/org1.amandigital.net/peers/peer0.org1.amandigital.net/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org1.amandigital.net/ca/ca.org1.amandigital.net-cert.pem

  mkdir -p organizations/peerOrganizations/org1.amandigital.net/users
  mkdir -p organizations/peerOrganizations/org1.amandigital.net/users/User1@org1.amandigital.net

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.amandigital.net/users/User1@org1.amandigital.net/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.amandigital.net/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.amandigital.net/users/User1@org1.amandigital.net/msp/config.yaml

  mkdir -p organizations/peerOrganizations/org1.amandigital.net/users/Admin@org1.amandigital.net

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M ${PWD}/organizations/peerOrganizations/org1.amandigital.net/users/Admin@org1.amandigital.net/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org1/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org1.amandigital.net/msp/config.yaml ${PWD}/organizations/peerOrganizations/org1.amandigital.net/users/Admin@org1.amandigital.net/msp/config.yaml

}

function createOrg2() {
  mkdir channel-artifacts
  mkdir -p organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/msp/tlscacerts/
  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/peerOrganizations/org2.amandigital.net/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org2.amandigital.net/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-org2 --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org2.amandigital.net/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-org2 --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/org2.amandigital.net/peers
  mkdir -p organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/msp --csr.hosts peer0.org2.amandigital.net --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.amandigital.net/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls --enrollment.profile tls --csr.hosts peer0.org2.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/keystore/* ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.amandigital.net/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.amandigital.net/tlsca
  cp ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org2.amandigital.net/tlsca/tlsca.org2.amandigital.net-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org2.amandigital.net/ca
  cp ${PWD}/organizations/peerOrganizations/org2.amandigital.net/peers/peer0.org2.amandigital.net/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org2.amandigital.net/ca/ca.org2.amandigital.net-cert.pem

  mkdir -p organizations/peerOrganizations/org2.amandigital.net/users
  mkdir -p organizations/peerOrganizations/org2.amandigital.net/users/User1@org2.amandigital.net

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.amandigital.net/users/User1@org2.amandigital.net/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.amandigital.net/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.amandigital.net/users/User1@org2.amandigital.net/msp/config.yaml

  mkdir -p organizations/peerOrganizations/org2.amandigital.net/users/Admin@org2.amandigital.net

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8054 --caname ca-org2 -M ${PWD}/organizations/peerOrganizations/org2.amandigital.net/users/Admin@org2.amandigital.net/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org2/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org2.amandigital.net/msp/config.yaml ${PWD}/organizations/peerOrganizations/org2.amandigital.net/users/Admin@org2.amandigital.net/msp/config.yaml

}



function createOrg3() {
  mkdir channel-artifacts
  mkdir -p organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/msp/tlscacerts/
  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/peerOrganizations/org3.amandigital.net/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org3.amandigital.net/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-org3 --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-org3.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-org3.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-org3.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-org3.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/org3.amandigital.net/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-org3 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-org3 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-org3 --id.name org3admin --id.secret org3adminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/org3.amandigital.net/peers
  mkdir -p organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/msp --csr.hosts peer0.org3.amandigital.net --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org3.amandigital.net/msp/config.yaml ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls --enrollment.profile tls --csr.hosts peer0.org3.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/signcerts/* ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/keystore/* ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/org3.amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org3.amandigital.net/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/org3.amandigital.net/tlsca
  cp ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/org3.amandigital.net/tlsca/tlsca.org3.amandigital.net-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/org3.amandigital.net/ca
  cp ${PWD}/organizations/peerOrganizations/org3.amandigital.net/peers/peer0.org3.amandigital.net/msp/cacerts/* ${PWD}/organizations/peerOrganizations/org3.amandigital.net/ca/ca.org3.amandigital.net-cert.pem

  mkdir -p organizations/peerOrganizations/org3.amandigital.net/users
  mkdir -p organizations/peerOrganizations/org3.amandigital.net/users/User1@org3.amandigital.net

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.amandigital.net/users/User1@org3.amandigital.net/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org3.amandigital.net/msp/config.yaml ${PWD}/organizations/peerOrganizations/org3.amandigital.net/users/User1@org3.amandigital.net/msp/config.yaml

  mkdir -p organizations/peerOrganizations/org3.amandigital.net/users/Admin@org3.amandigital.net

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://org3admin:org3adminpw@localhost:9054 --caname ca-org3 -M ${PWD}/organizations/peerOrganizations/org3.amandigital.net/users/Admin@org3.amandigital.net/msp --tls.certfiles ${PWD}/organizations/fabric-ca/org3/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/org3.amandigital.net/msp/config.yaml ${PWD}/organizations/peerOrganizations/org3.amandigital.net/users/Admin@org3.amandigital.net/msp/config.yaml

}




function createOrderer() {

  infoln "Enroll the CA admin"
  sleep 2
  mkdir -p organizations/ordererOrganizations/amandigital.net

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/amandigital.net
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/amandigital.net/msp/config.yaml

  infoln "Register orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null


  infoln "Register orderer2"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles  ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register orderer3"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles  ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null


  infoln "Register orderer4"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer4 --id.secret ordererpw --id.type orderer --tls.certfiles  ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register orderer5"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer5 --id.secret ordererpw --id.type orderer --tls.certfiles  ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null




  infoln "Register the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/ordererOrganizations/amandigital.net/orderers
  mkdir -p organizations/ordererOrganizations/amandigital.net/orderers/amandigital.net

  mkdir -p organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net

  infoln "Generate the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/msp --csr.hosts orderer.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/config.yaml ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/msp/config.yaml

  infoln "Generate the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/tls --enrollment.profile tls --csr.hosts orderer.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/tls/keystore/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem

  mkdir -p organizations/ordererOrganizations/amandigital.net/users
  mkdir -p organizations/ordererOrganizations/amandigital.net/users/Admin@amandigital.net


  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net

  infoln "Generate the orderer2 msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/msp --csr.hosts orderer2.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/config.yaml ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/msp/config.yaml

  infoln "Generate the orderer2-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/tls --enrollment.profile tls --csr.hosts orderer2.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/tls/keystore/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer2.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem



  # -----------------------------------------------------------------------
  #  Orderer 3

  mkdir -p organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net

  infoln "Generate the orderer3 msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/msp --csr.hosts orderer3.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/config.yaml ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/msp/config.yaml

  infoln "Generate the orderer3-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/tls --enrollment.profile tls --csr.hosts orderer3.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/tls/keystore/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer3.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem




  # -----------------------------------------------------------------------
  #  Orderer 4

  mkdir -p organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net

  infoln "Generate the orderer4 msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/msp --csr.hosts orderer4.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/config.yaml ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/msp/config.yaml

  infoln "Generate the orderer4-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/tls --enrollment.profile tls --csr.hosts orderer4.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/tls/keystore/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer4.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem




  # -----------------------------------------------------------------------
  #  Orderer 5

  mkdir -p organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net

  infoln "Generate the orderer5 msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/msp --csr.hosts orderer5.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/config.yaml ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/msp/config.yaml

  infoln "Generate the orderer5-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/tls --enrollment.profile tls --csr.hosts orderer5.amandigital.net --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/tls/keystore/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/orderers/orderer5.amandigital.net/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/tlscacerts/tlsca.amandigital.net-cert.pem



  infoln "Generate the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:10054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/amandigital.net/users/Admin@amandigital.net/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/amandigital.net/msp/config.yaml ${PWD}/organizations/ordererOrganizations/amandigital.net/users/Admin@amandigital.net/msp/config.yaml

}
