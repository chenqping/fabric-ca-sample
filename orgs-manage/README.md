# Fabric organization management

To run this example, you need to build the tools image repesct to the fabric source like the following:
```
make tools-docker
```
This will Guarantee that the cli image be prepared for the config update when joining the org3 in the channel.

Step 1: generate the channel artifacts to set up the e2e network:
```
./byfn.sh generate
```


Step 2: setup the basic e2e network with chaincode instantiated:
```
./byfn.sh up
```

Step 3: generate the org3 artifacts to join the channel and submit the config_update:

```
./eyfn.sh generate
```

Step 4: join the org3 peers in the channel and upgrade the chaincode and verify the addition:
```
./eyfn.sh up
```
