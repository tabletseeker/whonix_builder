![o,age](https://i.postimg.cc/qRdx2Hdz/background.png)

Utilizes a debian:bookworm Docker Container that automatically verifies and builds Whonix/Kicksecure images, incorporating the official derivative-maker build script, while including environment variables to customize every available build option and generating log files of the entire build process. Additionally, dnscrypt-proxy and the ability to use onion sources with torified apt-cacher-ng offer maximum privacy.
 
## Usage

### Building Docker Image
* Clone whonix_builder repo:
```
git clone https://github.com/tabletseeker/whonix_builder -b main
```
* Enter whonix_builder directory:
```
cd whonix_builder
```
* Make scripts executable:
```
chmod +x *.sh
```
* Start Docker Image creation:
```
docker build .
```
* Restart Docker Daemon:
```
systemctl restart docker
```
### Run whonix_builder without ENV variables:
The Dockerfile already contains default values for all environment variables which will be included in the image.
If you execute `docker run` without assigning new values, the defaults will apply.
```
docker run --name whonix_builder -it --privileged \
	--volume <HOST_DIR>:/home/user --dns 127.0.2.1 <IMAGE_ID> 
```
### Run whonix_builder with ENV variables:
```
docker run --name whonix_builder -it --privileged \
	--env 'WHONIX_TAG=17.2.0.7-stable' \
	--env 'TBB_VERSION=13.5.1' \
	--env 'FLAVOR_GW=whonix-gateway-cli' \
	--env 'FLAVOR_WS=whonix-workstation-cli' \
	--env 'TARGET=raw' \
	--env 'ARCH=amd64' \
	--env 'REPO=true' \
	--env 'TYPE=vm' \
	--env 'CLEAN=true' \
	--env 'APT_ONION=false' \
	--volume <HOST_DIR>:/home/user \
	--dns 127.0.2.1 <IMAGE_ID> 
```
If you wish to build a single flavor, simply remove the other FLAVOR ENV entry:
```
docker run --name whonix_builder -it --privileged \
	--env 'WHONIX_TAG=17.2.0.7-stable' \
	--env 'TBB_VERSION=13.5.1' \
	--env 'FLAVOR_GW=whonix-gateway-cli' \
	--env 'TARGET=raw' \
	--env 'ARCH=amd64' \
	--env 'REPO=true' \
	--env 'TYPE=vm' \
	--env 'CLEAN=true' \
	--env 'APT_ONION=false' \
	--volume <HOST_DIR>:/home/user \
	--dns 127.0.2.1 <IMAGE_ID> 
```
- Containers can be restarted indefinitely
- Repeating builds with the same tag simply updates the local repo and deletes
  existing ~/derivative-binary if `--env 'CLEAN=true'`
- Additional build arguments can be added to `--env 'OPTS='`
<details>
  <summary>
	 Full Options List
  </summary>
  
```
Flavors:
  --flavor [flavor_option]
  Options:
    whonix-gateway-xfce         : Builds Whonix-Gateway Xfce VM.
    whonix-gateway-rpi          : Builds Whonix-Gateway CLI RPi 3 VM.
    whonix-gateway-cli          : Builds Whonix-Gateway CLI VM.
    whonix-workstation-xfce     : Builds Whonix-Workstation Xfce VM.
    whonix-workstation-cli      : Builds Whonix-Workstation CLI VM.
    whonix-custom-workstation   : Builds Whonix-Custom-Workstation VM.
    whonix-host-cli             : Builds Whonix-Host CLI.
    whonix-host-xfce            : Builds Whonix-Host Xfce.
    kicksecure-cli              : Builds Kicksecure VM CLI VM.
    kicksecure-xfce             : Builds Kicksecure VM Xfce VM.

Targets:
  --target [target_option]
  Options:
    virtualbox              : Builds VirtualBox .ova files.
    qcow2                   : Builds qcow2 images.
    utm                     : Builds UTM images.
    iso                     : Builds ISO images.
    raw                     : Builds raw disk images.
    dist-installer-cli      : Builds dist-installer-cli.
    windows                 : Builds the Windows Installer.
    root                    : Builds for physical installations.
    source                  : Builds a xz source archive.

Types:
  --type [type_option]
  Options:
    host                    : Specifies that the build is for a host system.
    vm                      : Specifies that the build is for a virtual machine.

Optional Parameters:
  --vmram [size]           : Set VM RAM size (e.g., --vmram 128).
  --vram [size]            : Set VM video RAM size (e.g., --vram 12).
  --vmsize [size]          : Set VM disk size (e.g., --vmsize 200G).

  --freshness [option]     : Choose between 'frozen' (frozen sources) or 'current' (current sources).
  --connection [option]    : Select 'clearnet' for clearnet apt sources or 'onion' for onion apt sources.
  --repo [true|false]      : Enable or disable derivative remote repository (default: false).

Environment Variables:
  - flavor_meta_packages_to_install: Define meta packages to be installed.
    Examples:
      flavor_meta_packages_to_install='none'
      flavor_meta_packages_to_install='non-qubes-vm-enhancements-cli kicksecure-dependencies-cli whonix-shared-packages-dependencies-cli whonix-gateway-packages-dependencies-cli'

  - install_package_list: Specify additional custom packages for installation.
    Examples:
      install_package_list='gparted'
      install_package_list='gparted gedit'

  - DERIVATIVE_APT_REPOSITORY_OPTS: Set options for the Derivative APT Repository.
    Examples:
      DERIVATIVE_APT_REPOSITORY_OPTS='--enable --repository stable'
      DERIVATIVE_APT_REPOSITORY_OPTS='--enable --repository testers'
      DERIVATIVE_APT_REPOSITORY_OPTS='--enable --repository developers'
      DERIVATIVE_APT_REPOSITORY_OPTS='--enable --codename bookworm'

Advanced Options:
  --report [true|false]           : Enable or disable build reports (default: false).
  --verifiable [true|false]       : Toggle file deletion in cleanup script for verifiable builds (default: false).
  --sanity-tests [true|false]     : Enable or disable chroot script sanity tests for faster build speed (default: false).
  --retry-max [attempts]          : Set maximum retry attempts. (default: 2)
  --retry-wait [seconds]          : Set wait time between retry attempts.
  --retry-before [script]         : Specify a script to run before retry. [default: none)
  --retry-after [script]          : Specify a script to run after retry. [default: none)
  --allow-uncommitted [true|false]: Permit builds with uncommitted changes (default: false).
  --allow-untagged [true|false]   : Permit builds from non-tagged sources (default: false).
  --kernel [packages]             : Specify kernel packages (e.g., 'linux-image-amd64' or 'none').
  --headers [packages]            : Specify kernel header packages.
  --remote-derivative-packages    : Choose to use remote derivative packages instead of building derivative packages from source code. (default: false).
  --release [unsupported_option]  : Set release option (unsupported). (bookworm|xenial|bionic)
  --arch [architecture]           : Set architecture (e.g., i386, amd64, kfreebsd-i386, kfreebsd-amd64) (default: amd64).
  (Note: amd64 also works with most Intel CPUs.)

For VMs only:
  --initramfs [packages]          : Specify initramfs packages. (none, initramfs-tools) (default: $BUILD_INITRAMFS_PKGS)

Configuration Files:
  --confdir [/path/to/config/dir] : Specify an additional configuration directory.
  --conffile [/path/to/config/file]: Specify an additional configuration file.
  --grmlbin [/path/to/grml-debootstrap]: Set the grml-debootstrap path (default: grml-debootstrap).

Miscellaneous:
  --unsafe-io [true|false]        : Toggle unsafe IO options (default: false).
  --freedom [true|false]          : Choose between pure or impure builds (required for host builds).
  --tb [none|closed|open]         : Configure Tor Browser installation options (default: open).
  none: Do not install Tor Browser.
  closed: Abort build, fail closed if Tor Browser cannot be installed.
  open: Do not abort build, fail open if Tor Browser cannot and installed.


```
</details>

### Environment Variables

|  Variable                                             | Values                                                                                          
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------|
| WHONIX_TAG        | Any available git tag on the [official derivative-maker repository](https://github.com/Whonix/derivative-maker/tags)  		 |
| TBB_VERSION       | Latest Tor Browser version indicated in [downloads.json]( https://aus1.torproject.org/torbrowser/update_3/release/downloads.json)  |
| FLAVOR_GW         | `whonix-gateway-cli` `whonix-gateway-xfce`                                |
| FLAVOR_WS         | `whonix-workstation-cli` `whonix-workstation-xfce`                   |
| TARGET 	    | `virtualbox` `qcow2` `raw` `utm`                                           			 |
| ARCH              | `amd64` `arm64` `i386`               								 |
| REPO              | `true` `false` 											 |
| TYPE              | `vm` `host` 											 |
| CLEAN             | `true` `false` 											 |
| APT_ONION         | `true` `false` 											 |

### Volume
The container's home directory is mounted as a volume which can be bound to any location of your choosing.
Example: `--volume /home/user/shared:/home/user` would bind a folder named shared in the host's home directory
to the container's home directory, which is where all build files will be located.

### DNSCrypt
dnscrypt-proxy is listening @ 127.0.2.1:53 using default resolver cloudflare @ 1.0.0.1
* server settings can be changed in `dnscrypt-proxy.toml`
* resolver data and minisig can be updated in `public-resolvers.md` and `public-resolvers.md.minisig`

### APT Onion Sources & Torified apt-cacher-ng
Assigning the value `true` to environment variable `APT_ONION` triggers a set of commands
that add `--connection onion` to the derivative-maker arguments during build and appends the following entries to 
`/etc/apt-cacher-ng/acng.conf`, which will enable torified apt-cacher:
```
PassThroughPattern: .*
BindAddress: localhost
SocketPath: /run/apt-cacher-ng/socket
Port:3142
Proxy: http://127.0.0.1:3142
```
* https://www.whonix.org/wiki/Build_Configuration#APT_Onion_Build_Sources

### Log Files
Can be found in the volume which mounts the container's home directory.
* DNSCrypt: `query.log` `nx.log` `dnscrypt-proxy.log`
* Build: `key.log` `git.log` `build_ws.log` `build_gw.log`

### Systemd
systemd_init achieves a full integration of systemd for the purpose of enabling apt-cacher-ng.
You can add additional services at will, such as for example dnscrypt.  

## Useful Links
* https://www.whonix.org/wiki/Dev/Build_Documentation/VM
* https://www.whonix.org/wiki/Dev/Source_Code_Intro

## Special Thanks
* [Whonix Team](https://www.whonix.org/)
* [@Patrick - Whonix Forums](https://forums.whonix.org/)
* [@adrelanos - Whonix Github](https://github.com/Whonix/derivative-maker)
