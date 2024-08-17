export ORG1_MSPKEY=$(cd ../test-network/organizations/peerOrganizations/org1.amandigital.net/users/Admin@org1.amandigital.net/msp/keystore && ls *_sk) 


sed -i  "s/ORG1_MSPKEY/$ORG1_MSPKEY/g" first-network.json 