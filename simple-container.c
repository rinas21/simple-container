#define _GNU_SOURCE
#include <sched.h>      // For clone() and namespace flags
#include <stdio.h>      // For printf()
#include <stdlib.h>     // For exit()
#include <unistd.h>     // For sethostname(), chroot(), chdir(), execv()
#include <sys/mount.h>  // For mount()
#include <signal.h>     // For SIGCHLD

#define STACK_SIZE (1024 * 1024) // Define the stack size for the child process
char child_stack[STACK_SIZE];   // Allocate memory for the child process stack

// Function executed in the child process (containerized environment)
int child_func(void *arg) {
    (void)arg;  // Suppress unused warning if not using arg

    printf("=> Inside demo container!\n");

    // Step 1: Make the mount namespace private
    if (mount(NULL, "/", NULL, MS_REC | MS_PRIVATE, NULL) != 0) {
        perror("mount: make / private");
        exit(EXIT_FAILURE);
    }

    // Set the hostname for the container (UTS namespace)
    sethostname("mycontainer", 10);

    // Change the root directory of the container (chroot jail)
    // This isolates the filesystem of the container
    chroot("/tmp/mycontainer_root");
    chdir("/"); // Change the working directory to the new root

    // Mount the proc filesystem inside the container
    // This is required for commands like `ps` to work properly
    mount("proc", "/proc", "proc", 0, NULL);

    // 🚨 Environment cleanup
    // Clear the environment variables to avoid leaking host environment
    clearenv();

    // Set minimal environment variables for the container
    setenv("PATH", "/bin", 1); // Set executable search paths
    setenv("HOME", "/", 1);  // Set home directory
    setenv("TERM", "/bin/sh", 1);  // Set terminal type

    // Execute a shell inside the container
    char *const args[] = { "/bin/sh", NULL };
    
    // Launch the container's init process (/bin/sh)
    // This replaces the current process image with the shell
    // It's essential because after setting up namespaces, chroot, etc.,
    // we want to execute the actual container workload
    execv(args[0], args);

    // If execv fails, print an error message and exit
    perror("execv failed");
    return 1;
}

int main() {
    printf("=> Starting the container lanuncher\n");

    // Define the namespaces to isolate
    // CLONE_NEWUTS: Isolate hostname and domain name
    // CLONE_NEWPID: Isolate process IDs (PID namespace)
    // CLONE_NEWNS: Isolate mount points (mount namespace)
    // CLONE_NEWNET: Isolate network (netwrok namespace)
    // SIGCHLD: Ensure the parent process is notified when the child exits
    int flags = CLONE_NEWUTS | CLONE_NEWPID | CLONE_NEWNS | CLONE_NEWUTS | SIGCHLD | CLONE_NEWNET;

    // Create a new process with the specified namespaces
    pid_t pid = clone(child_func, child_stack + STACK_SIZE, flags, NULL);

    // Check if clone() failed
    if (pid == -1) {
        perror("clone");
        exit(1);
    }

    // Wait for the child process (container) to finish
    waitpid(pid, NULL, 0);
    printf("=> Container exited\n");
    return 0;
}