#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Define the root filesystem for the container
# If no argument is provided, default to /tmp/mycontainer_root
ROOTFS=${1:-/tmp/mycontainer_root}

echo "Creating a minimal /dev directory inside the container root: $ROOTFS"

# Create the /dev directory inside the container's root filesystem
mkdir -p "$ROOTFS"/dev

# Create the /bin and /proc directories inside the container's root filesystem
mkdir -p "$ROOTFS"/{bin,proc}

# Copy the busybox binary to the /bin directory inside the container's root filesystem
cp /usr/bin/busybox "$ROOTFS"/bin/busybox

# Chnage the directory to the /bin directory inside the container's root filesystem
cd "$ROOTFS"/bin

# Create symbolic links for common shell commands using busybox
ln -s busybox sh 

# Create essential device nodes inside the container's /dev directory
# These device nodes are required for basic functionality inside the container

# /dev/null: Discards all data written to it
# Major number: 1 (memory devices), Minor number: 3 (specific to /dev/null)
sudo mknod -m 666 "$ROOTFS"/dev/null c 1 3

# /dev/zero: Produces a stream of null (zero) bytes
# Major number: 1 (memory devices), Minor number: 5 (specific to /dev/zero)
sudo mknod -m 666 "$ROOTFS"/dev/zero c 1 5

# /dev/tty: Represents the controlling terminal for the current process
# Major number: 5 (TTY devices), Minor number: 0 (specific to /dev/tty)
sudo mknod -m 666 "$ROOTFS"/dev/tty c 5 0

# /dev/random: Produces random data (blocking if entropy is low)
# Major number: 1 (memory devices), Minor number: 8 (specific to /dev/random)
sudo mknod -m 666 "$ROOTFS"/dev/random c 1 8

# /dev/urandom: Produces random data (non-blocking, even if entropy is low)
# Major number: 1 (memory devices), Minor number: 9 (specific to /dev/urandom)
sudo mknod -m 666 "$ROOTFS"/dev/urandom c 1 9

echo "✅ Essential device nodes have been created in $ROOTFS/dev"

# Educational Notes:
# - Device nodes are special files that provide an interface to hardware devices or virtual devices.
# - `mknod` is used to create these special files.
# - The `-m` flag sets the permissions for the device node (e.g., 666 for read/write access to all users).
# - The `c` indicates that these are character devices (data is handled as a stream of characters).
# - Major number: Identifies the driver associated with the device (e.g., 1 for memory devices).
# - Minor number: Identifies the specific device handled by the driver (e.g., 3 for /dev/null).

