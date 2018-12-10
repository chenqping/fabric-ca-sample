#!/bin/bash

#set -x

#echo $@

if [ $# -ne 3 -a $# -ne 4 ]; then
   echo -e "Usage:./generate-cert-with-fabric-ca.sh <OrgName> <OrgType> <nodeNum> [<caServerIP:caServerPort>] \nFor example: ./generate-cert-with-fabric-ca.sh grg peer 2 [localhost:7054]"
   exit 1
fi

orgName=$1
orgType=$2
nodeNum=$3

if [ $# -eq 4 ]; then
   caServerIP="$(cut -d':' -f1 <<<"$4")"
   caServerPort="$(cut -d':' -f2 <<<"$4")"
else
   echo "Starting fabric-ca-server natively for ${orgName}..."
   caVersion=`fabric-ca-server version | awk '/Version:/{print $2}'`
   if [ "$caVersion" != "1.1.0" ]; then
      echo "Only support 1.1.0 version, please upgrade your fabric-ca-server"
      exit 1  
   fi
   currentDir=$PWD
   if [ -d fabric-ca-server-${orgName} ]; then
      echo "remove existing directory fabric-ca-server-${orgName}"
      rm -rf fabric-ca-server-${orgName}
   fi
   mkdir fabric-ca-server-${orgName}
   cd fabric-ca-server-${orgName}
   nohup fabric-ca-server start -b admin:adminpw > fabric-ca-server.log 2>&1 &
   sleep 10
   cd $currentDir
   caServerIP="localhost"
   caServerPort="7054"
fi

if [ -d fabric-ca-client-${orgName} ]; then
   echo "remove existing directory fabric-ca-client-${orgName}"
   rm -rf fabric-ca-client-${orgName}
fi
mkdir fabric-ca-client-${orgName}
export FABRIC_CA_CLIENT_HOME=$PWD/fabric-ca-client-${orgName}
cd fabric-ca-client-${orgName}
fabric-ca-client enroll -u http://admin:adminpw@$caServerIP:$caServerPort

fabric-ca-client register --id.name admin-$orgName --id.secret admin-${orgName}pw --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"
mkdir -p users/admin/msp
fabric-ca-client enroll -u http://admin-${orgName}:admin-${orgName}pw@$caServerIP:$caServerPort -M users/admin/msp
mkdir users/admin/msp/admincerts
cp users/admin/msp/signcerts/cert.pem users/admin/msp/admincerts/

mkdir -p channel/msp
fabric-ca-client getcacert -u http://$caServerIP:$caServerPort -M channel/msp
mkdir channel/msp/admincerts
cp users/admin/msp/signcerts/cert.pem  channel/msp/admincerts/

for ((i=1; i<=$nodeNum; i=i+1))
do
   fabric-ca-client register --id.name ${orgType}${i}-$orgName --id.secret ${orgType}${i}-${orgName}pw --id.type ${orgType}
   mkdir -p ${orgType}s/${orgType}${i}/msp
   fabric-ca-client enroll -u http://${orgType}${i}-${orgName}:${orgType}${i}-${orgName}pw@$caServerIP:$caServerPort -M ${orgType}s/${orgType}${i}/msp/
   mkdir ${orgType}s/${orgType}${i}/msp/admincerts
   cp users/admin/msp/signcerts/cert.pem ${orgType}s/${orgType}${i}/msp/admincerts

   test -d tls && rm -rf tls/*
   fabric-ca-client enroll --enrollment.profile tls -u http://${orgType}${i}-${orgName}:${orgType}${i}-${orgName}pw@$caServerIP:$caServerPort -M tls --csr.hosts ${orgType}${i}-${orgName}
   mkdir ${orgType}s/${orgType}${i}/tls 
   cp tls/signcerts/cert.pem ${orgType}s/${orgType}${i}/tls/server.crt
   cp tls/keystore/*_sk ${orgType}s/${orgType}${i}/tls/server.key
   cp tls/tlscacerts/*.pem ${orgType}s/${orgType}${i}/tls/ca.crt
done

if [ $orgType == "peer" ]; then
   fabric-ca-client register --id.name user0-$orgName --id.secret user0-${orgName}pw
   mkdir -p users/user0/msp
   fabric-ca-client enroll -u http://user0-$orgName:user0-${orgName}pw@$caServerIP:$caServerPort -M users/user0/msp
   mkdir users/user0/msp/admincerts
   cp users/admin/msp/signcerts/cert.pem users/user0/msp/admincerts/
fi

caServerPID=`pidof fabric-ca-server`
test -z $caServerPID || kill -9 $caServerPID
