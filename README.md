![o,age](https://i.postimg.cc/C5Jhp2WW/derivative-logo.png)

Utilizes a debian:bookworm Docker Container that automatically verifies and builds Whonix/Kicksecure images, incorporating the official derivative-maker build script, while including environment variables to customize every available build option and generating log files of the entire build process. Additionally, dnscrypt-proxy and the ability to use onion sources with torified apt-cacher-ng offer maximum privacy.
 
## Dependencies
* `jq`
* `curl`
* `docker`  

## Pulling Docker Image
* Pull the latest tag:
```
docker pull tabletseeker/whonix_builder:latest
```
## Building Docker Image
* Clone repo:
```
git clone https://github.com/tabletseeker/whonix_builder -b master
```
* Enter whonix_builder directory:
```
cd whonix_builder
```
* Run Docker build script:
```
./build.sh
```
## Usage
* Build with the latest tag and tor version:
```
./run.sh
```
* Build with specifc tag number:
```
./run.sh -t 17.3.9.1-developers-only
```
* Build with specifc tor version:
```
./run.sh -o 14.2.1
```
* Build with specifc tag and tor version:
```
./run.sh -t 17.3.9.9-developers-only -o 14.2.1
```
|  Arguments                                             | Value                                                                                          
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------|
| -t\|--tag           | Choose a specific tag	 |
| -o\|--onion  	      | Choose a specifc tor version |


### Environment Variables

|  Variable                                             | Values                                                                                          
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------|
| TAG        		| Any available git tag on the [official derivative-maker repository](https://github.com/Whonix/derivative-maker/tags)  		 |
| TOR 		     | Tor version indicated in [downloads.json]( https://aus1.torproject.org/torbrowser/update_3/release/downloads.json)  |
| FLAVOR             | `whonix-gateway-xfce` `whonix-workstation-xfce` `kicksecure` etc.				         |
| TARGET 	    | `virtualbox` `qcow2` `raw` `utm`                                           			 |
| ARCH              | `amd64` `arm64` `i386`               								 |
| CONNECTION         | `clearnet` `onion` 											 |
| REPO              | `true` `false` 											 |
| TYPE              | `vm` `host` 											 |
| APT_CACHER_ARGS    | Additional apt-cacher-ng options 											 |
| OPTS         		| Additional derivative-maker options		
| tbb_version         | Tor version 											 |

### Volumes
Directories for the build and apt-cacher files are automatically created with necessary permissions.
You can change the directory locations by modifying the following variables in `whonix_builder/run.sh`:
```
BUILDER_VOLUME="$HOME/whonix_builder_mnt"
CACHER_VOLUME="$HOME/apt_cacher_mnt"
```

### DNSCrypt
dnscrypt-proxy is listening @ 127.0.2.1:53 using default resolver cloudflare @ 1.0.0.1
* server settings can be changed in `dnscrypt-proxy.toml`
* resolver data and minisig can be updated in `public-resolvers.md` and `public-resolvers.md.minisig`

### APT Onion Sources & Torified apt-cacher-ng
Enable onion sources with `--env 'CONNECTION=onion` in `whonix_builder/run.sh` \
Default `acng.conf` Config Options
```
BindAddress: localhost
SocketPath: /run/apt-cacher-ng/socket
Port:3142
ForeGround: 1
AllowUserPorts: 0
PassThroughPattern: .*
```
* https://www.whonix.org/wiki/Build_Configuration#APT_Onion_Build_Sources

### Log Files
Can be found in the volume which mounts the container's home directory.
* DNSCrypt: `query.log` `nx.log` `dnscrypt-proxy.log`
* Build: `key.log` `git.log` `build.log`


## Tips
* Source: `whonix_builder/run.sh`
* Multiple flavors can be built via `--env 'FLAVOR=<flavor> <flavor> <flavor>'`
* Clone and build from master branch with: `./run.sh -t master`
* Additional apt-cacher-ng arguments can be added to `APT_CACHER_ARGS` via `--env 'APT_CACHER_ARGS=Foreground=1 AllowUserPorts=0'`
* Additional build arguments can be added to `OPTS` via `--env 'OPTS=--allow-uncommitted true --vmsize 10G'`
<details>
  <summary>
	 Full Derivative-Maker Options List
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

## Useful Links
* https://www.whonix.org/wiki/Dev/Build_Documentation/VM
* https://www.whonix.org/wiki/Dev/Source_Code_Intro

## Special Thanks
* [Whonix Team](https://www.whonix.org/)
* [@Patrick - Whonix Forums](https://forums.whonix.org/)
* [@adrelanos - Whonix Github](https://github.com/Whonix/derivative-maker)
