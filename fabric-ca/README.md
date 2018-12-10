# fabric-ca-sample
A repo  for fabric network cooperating with fabric-ca to  exemplify the production environment deployment.
This repo takes three organizations grg, gfb and orderer for example.

If you want to use the fabric-ca tools natively, you can copy the fabric-ca-client and fabric-ca-server binaries under tools to your PATH env. You can also get the lates releases using the following commands:
```
go get -u github.com/hyperledger/fabric-ca/cmd/fabric-ca-client
go get -u github.com/hyperledger/fabric-ca/cmd/fabric-ca-server
```
This will download the binaries into your $GOPATH/bin/.

Also later I will support generating the certificates in fabric-ca docker containers.


Script usage:
./generate-cert-with-fabric-ca.sh OrgName OrgType nodeNum [<caServerIP:caServerPort>].
  
 For example:
./generate-cert-with-fabric-ca.sh grg peer 2 [localhost:7054]"
