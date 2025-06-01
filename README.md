# FRI OS/161 Docker Environment

This documentation provides instructions for setting up and using the FRI OS/161 Docker environment.

This project is a part of the Bachelor Thesis titled **Instructional Operating Systems** by Dejan Jarc from the Faculty of Computer Science and Informatics (University of Ljubljana, Slovenia). It is meant to serve as a pedagogical tool for OS courses, but can also be used by any OS enthusiast.

> The base system we are using in this project is **Ubuntu 20.04**.

## Prerequisites

Before proceeding, ensure you have the following prerequisites set up:

1. **Install Docker and Docker Compose**:
    Make sure Docker and Docker Compose are installed on your system. You can download and install them from the [Docker website](https://www.docker.com/). **The best way is to setup [Docker Desktop](https://www.docker.com/products/docker-desktop/).**
    

    > For Windows users, it is recommended to enable *Windows Subsystem for Linux (WSL)* within Docker Desktop for better compatibility.

2. **Verify Docker Installation**:
    Confirm that Docker is installed and running by executing:
    ```bash
    docker --version
    docker-compose --version
    ```
---

## Getting Started

You can setup the Docker environment using Docker Hub. The image is built for the `linux/amd64` architecture (i.e. 64-bit Intel/AMD CPUs). If your machine uses this architecture, you can **directly pull the image from Docker Hub** and run it without issues.

**Warning :** If you are using **a non-`amd64` platform** (like Apple M1/M2/M3 or ARM-based systems, Docker may attempt to emulate the architecture which can be slower or unsupported. You can build the image yourself by following the steps [**here**](#alternative-for-getting-started).

1. **Pull the image from Docker Hub**
    ```bash
    docker pull dejanjarc/fri-os161
    ```
    or (when in the directory of the Docker Compose file):
    ```bash
    docker compose pull
    ```

2. **Run a named container**
    ```bash
    docker run --name <CONTAINER_NAME> -itd dejanjarc/fri-os161
    ```
  Replace `<CONTAINER_NAME>` with the name of your OS/161 container. You can choose your own name.
  The flag `-d` is there so that we run the container detached. 

3. **Connect to the Running Container**
    Once the containers are running, you can connect to the OS/161 container by executing:
    ```bash
    docker exec -it <CONTAINER_NAME> /bin/bash
    ```
    Replace `<CONTAINER_NAME>` with the name or ID of the OS/161 container. To find the container name or ID, run:
    
    ```bash
    docker ps
    ```

    Alternatively, you can attach to the container using:
    ```bash
    docker attach <CONTAINER_NAME>
    ```
    If you detach, restart the container with:
    ```bash
    docker start <CONTAINER_NAME>
    ```
    > It is recommended to use `docker exec` so your container doesn't stop after detaching.

You are now ready to use the FRI OS/161 Docker environment.

#### **Alternative for getting started**

You may want to build your own Docker image, either because you are using a non-`amd64` platform or because you made custom changes to the setup process.

1. **Clone the Repository**:
    Begin by cloning the repository from GitHub to your local machine:
    
    ```bash
    git clone https://github.com/dejanjarc/fri-os161.git
    cd fri-os161
    ```

2. **Build and Start the Docker Environment**:
    Build and start the Docker containers using the following command:
    ```bash
    docker-compose up --build
    ```
    or
    ```bash
    docker-compose build
    docker-compose up -d    
    ```

3. **Connect to the Running Container**:
    Once the containers are running, you can connect to the OS/161 container by executing:
    ```bash
    docker exec -it <CONTAINER_NAME> /bin/bash
    ```
    Replace `<CONTAINER_NAME>` with the name or ID of the OS/161 container. Default value for `CONTAINER_NAME` is `fri-os161` To find the container name or ID, run:
    ```bash
    docker ps
    ```

    Alternatively, you can attach to the container using:
    ```bash
    docker attach <container_name>
    ```
    You need to run this commant to start the container again if you detach:
    ```bash
    docker start <CONTAINER_NAME>
    ``` 
    > It is recommended to use the `docker exec` instead so that your container doesn't always stop after you detach from it.

---

## Container Overview

The container home directory contains the following OS/161 subdirectories:

- the **source code directory** of OS/161 (`src`)
- the **root directory** for running OS/161 (`root`)
- the **tools directory** for OS/161 (`tools`)


## Setting up and Running OS/161

Below are steps to build and run OS/161 inside the container, as described in the official OS/161 [building](http://www.os161.org/resources/building.html) and [running](http://www.os161.org/resources/running.html) guides.

> **Warning**: Our home directory is equal to the OS/161 directory and our source tree is located directly at **`~/src`**. 
These guides assume your OS/161 directory as **`~/os161`** and that you have your source tree in  **`~/os161/src`**. *Make sure to make the appropriate substitution when following these guides*.

The credentials for the system withing the container are: 
Username = **os161**, password = **os161** 
> If needed, you can freely install any packages you may require. If admin rights are needed, use the mentioned credentials.


### Running OS/161

To run OS/161 inside the container:

1. Change to the root directory:
    ```bash
    cd ~/root
    ```
2. Start System/161 with the installed kernel:
    ```bash
    sys161 kernel
    ```
    > The `sys161.conf` config file is needed to run System/161. Luckly, it is already set up for this environment. 

3. To shut down System/161 you can 
  - enter **`q`** into the menu or
  - run the **`poweroff`** utility with `p /sbin/poweroff`. 

### Building OS/161

If you want to rebuild the OS/161 kernel from source, follow these steps:

1. Change to the OS/161 source directory:
    ```bash
    cd ~/src
    ```
2. Configure the source tree (run this if you haven't already, or if you moved the source tree):
    ```bash
    ./configure --ostree=$HOME/root
    ```

3. Build the userland:
    ```bash
    cd ~/src
    bmake
    bmake install
    ```
    > You can compile a single program by typing `bmake` in its source directory and then `bmake install` to install it in its place at `~/root`.

    > For other `bmake` rules (e.g. `bmake depend`), see [OS/161 Building](http://www.os161.org/resources/building.html).

4. Configure the kernel (replace `DUMBVM` with your configuration if needed):
    ```bash
    cd kern/conf
    ./config DUMBVM
    ```
5. Change to the kernel build directory:
    ```bash
    cd ../compile/DUMBVM
    ```
6. Build and install the kernel:
    ```bash
    bmake depend
    bmake
    bmake install
    ```
  This will build and install the kernel as `~/root/kernel-DUMBVM`. You can now run this kernel following [the previous](#running-os161) step.

> For more details, see the [OS/161 Building](http://www.os161.org/resources/building.html) and [Running](http://www.os161.org/resources/running.html) documentation.

---
## Resources
- [System/161 2.x Software and Hardware Manual](http://www.os161.org/documentation/sys161/)
- [OS/161 Guides and Resources](http://www.os161.org/resources/)
- *A New Instructional Operating System* by David A. Holland, Ada T. Lim, and Margo I. Seltzer. Proceedings of the 2002 ACM SIGCSE Conference on Computer Science Education, March 2002.

---
## Credits

- The FRI OS/161 Docker environment setup was inspired by [this](https://github.com/marcopalena/polito-os161-docker) Github repository by Marco Palena. 

---
## Notes

- Ensure Docker and Docker Compose are installed before proceeding.
- If there are any bugs you wish to report, [open an issue](https://github.com/dejanjarc/fri-os161/issues) or do a [pull request with your solution](https://github.com/dejanjarc/fri-os161/pulls).
