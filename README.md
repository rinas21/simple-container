# Simple Container Implementation

## Tested environment
Ubuntu 2024.04

#### Enter the container's namespace and execute a shell.
Run the following command, replacing `1234` with your container's PID:
```console
sudo nsenter -t 1234 --uts --pid --mount --net -- sh
```

#### Set up virtual ethernet nets and peer them in the host machine
``` console
sudo ip link add veth0 type veth peer name veth1
```
#### Move veth1 into a container (or isolated process) using the netns of its PID
```console
sudo ip link set veth1 netns 1678
```
#### Add IPs to the virtual ethernet devices created in the host machine and the container. 

#### Use ifconfig command to set the IPs in the container.
In the host machine
```console
ifconfig  veth0 192.168.1.1
```
In the container
```console
ifconfig  veth1 192.168.1.2
````

