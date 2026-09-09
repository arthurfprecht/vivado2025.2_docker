# Vivado 2025.2 Docker build script

This repository contains a Xilinx Unified SDI 2025.2 docker image based on Ubuntu 24.04.
It is based on my previous repo (vivado2025.1_docker) and Thierry Delafontaine's (delafthi) repo, original credits to him.
Many upgrades went in to make sure the Vivado and Vitis 2025.2 are installed and work well in Ubuntu 24.04.

## Usage

1. Download the [`Xilinx Unified Installer 2025.2: Linux Self Extracting Web Installer`](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html)
   and place into the directory.
2. Adapt `install_config.txt` to your likings, or regenerate `install_config.txt` by running
   `./FPGAs_AdaptiveSoCs_Unified_SDI_2025.2_0530_0145_Lin64.bin -- --batch ConfigGen` 
   and copying the generated file into the directory. IMPORTANT: The destination now needs to be added manually with the line Destination=/tools/Xilinx
3. Build the docker image by running `./build.sh`.
4. At the beginning of the `./build.sh` script you need to log in with your
   Xilinx credentials in order to create a authenication token for the web
   installer.
5. Adjust the `PROJECT_PATH` variable in `run.sh` to mount your project, 
   workspace and miscelaneous folders, as well as device names (for instance,
   USB to serial adapters, cable devices) and run the docker image with `./run.sh`.
6. Start Vivado from the docker terminal with `vivado`. Vitis can be started using `vitis`
7. The password for sudo is the username that gets registered at the start of the session
8. The root password in the container is root

## Adding Hardware access capabilities

`--privileged` option was removed to make this container more secure. To 
add access to other HW types:
- Use the command `--device-cgroup-rule='c major_number:* rmw'`
on the `run.sh` script
- The major number can be found by issuing `ls -la /dev/`
and noting down the number that appears by the side of the group that the device belongs
- Example for the `ttyACM0`: `crw-rw----+ 1 root plugdev 166, 0 jul 24 22:32  /dev/ttyACM0`
- Then the docker command is `--device-cgroup-rule='c 166:* rmw'`
- Other example for the `ttyUSB0`: `crw-rw----+ 1 root dialout 188, 0 jul 24 22:32 /dev/ttyUSB0`
- Then the docker command for this other example becomes `--device-cgroup-rule='c 188:* rmw'` 
- Note that for hardware access to work, it is necessary that the host has the correct udev rules (or drivers, depending on the hardware) configured on the HOST. For Vivado, for instance, the udev rules from /etc/udev/rules.d from the Docker need to be copied to the equivalent folder on the host.
- IMPORTANT: Every time a new device is connected, the docker needs to be restarted to see the device

## Ubuntu 24.04 fixes

I am adding this list here as it might help other users, even if not using this containerized version
- GID PID conflict blocks the usage of sudo - Ubuntu creates a default 
  GID PID 1000 called "ubuntu" that conflicts with the current user - Fixed 
  by deleting this "ubuntu" user
- Vitis does not open at all - Wrong libstdc++ bundled - Fix discussed in
  [`a post on Xilinx forum`](https://adaptivesupport.amd.com/s/question/0D54U000091FX0XSAW/vitis-no-longer-opening-ubuntu-2404-vitis-20242?language=en_US)
- XSDB crashes upon being launched from Vitis - Wrond rlwrap package version 
  bundled - Fix discussed in [`another post on Xilinx forum`](https://adaptivesupport.amd.com/s/question/0D54U00006alPtOSAU/segmentation-fault-invoking-xsct-indirectly-using-the-xsct-script-in-vitis-bin-folder-resolved?language=en_US)

## Updating device families once image is built

If more other device families need to be added or removed after the image is prepared and one does not want to rebuild:

1. Get the config file of the current installation with `/tools/Xilinx/.xinstall/2025.2/xsetup -b ConfigGen`
2. Modify the install file accordingly with `cp ~/.Xilinx/install_config.txt . && nano install_config.txt`
3. Generate the authentication token with `/tools/Xilinx/.xinstall/2025.2/xsetup -b AuthTokenGen`
4. Copy the authentication token to the correct folder with `sudo cp ~/.Xilinx/wi_authentication_key  /root/.Xilinx/wi_authentication_key`
5. Execute the installation with `sudo /tools/Xilinx/.xinstall/2025.2/xsetup -a XilinxEULA,3rdPartyEULA -b Add -c install_config.txt`
6. Don't forget to commit the changes in docker with `docker ps`, then `docker commit container_ID vivado:2025.2`
