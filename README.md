
#### setup viertual eather nets and peer them in the host machine
``` console
sudo ip link add veth0 type veth peer name veth1
```
#### Move veth1 into a container (or isolated process) using the netns of its PID
```console
sudo ip link set veth1 netns 1678
```
#### Add IP to the veth created in the host machine and the container. 

#### Use ifconfig command to set the ip in the container.
