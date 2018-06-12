# fabric-ca-sample
A repo  for fabric network cooperating with fabric-ca to  exemplify the production environment deployment.
This repo takes three organizations grg, gfb and orderer for example.

Script usage:
./generate-cert-with-fabric-ca.sh <OrgName> <OrgType> <nodeNum> [<caServerIP:caServerPort>].
  
 For example:
./generate-cert-with-fabric-ca.sh grg peer 2 [localhost:7054]"
