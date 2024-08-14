# Parse IOMMU Devices
### v1.0.0
Bash script to parse, sort, and display hardware devices by IOMMU group,
and return the device drivers and hardware IDs as output.

**[Latest release](https://github.com/portellam/parse-iommu-devices/releases/latest)**

## Table of Contents
- [1. Why?](#1-why)
- [2. Related Projects](#2-related-projects)
- [3. Documentation](#3-documentation)
- [4. Host Requirements](#4-host-requirements)
- [5. Download](#5-download)
- [6. Usage](#6-usage)
    - [6.1. Install](#61-install)
    - [6.2. Executable](#62-executable)
- [7. Contact](#7-contact)
- [8. References](#8-references)

## Contents
### 1. Why?
If you wish to determine if your current machine's hardware specifications are able to support VFIO, this script is for you. The script allows one to query exactly what hardware you wish to allocate for a VFIO setup, and returns the relevant output to deploy a VFIO setup.

### 2. Related Projects
| Project                             | Codeberg          | GitHub          |
| :---                                | :---:             | :---:           |
| Deploy VFIO                         | [link][codeberg1] | [link][github1] |
| Auto X.Org                          | [link][codeberg2] | [link][github2] |
| Generate Evdev                      | [link][codeberg3] | [link][github3] |
| Guest Machine Guide                 | [link][codeberg4] | [link][github4] |
| Libvirt Hooks                       | [link][codeberg5] | [link][github5] |
| **Parse IOMMU Devices**             | [link][codeberg6] | [link][github6] |
| Power State Virtual Machine Manager | [link][codeberg7] | [link][github7] |

[codeberg1]: https://codeberg.org/portellam/deploy-VFIO
[github1]:   https://github.com/portellam/deploy-VFIO
[codeberg2]: https://codeberg.org/portellam/auto-xorg
[github2]:   https://github.com/portellam/auto-xorg
[codeberg3]: https://codeberg.org/portellam/generate-evdev
[github3]:   https://github.com/portellam/generate-evdev
[codeberg4]: https://codeberg.org/portellam/guest-machine-guide
[github4]:   https://github.com/portellam/guest-machine-guide
[codeberg5]: https://codeberg.org/portellam/libvirt-hooks
[github5]:   https://github.com/portellam/libvirt-hooks
[codeberg6]: https://codeberg.org/portellam/parse-iommu-devices
[github6]:   https://github.com/portellam/parse-iommu-devices
[codeberg7]: https://codeberg.org/portellam/powerstate-virtmanager
[github7]:   https://github.com/portellam/powerstate-virtmanager

### 3. Documentation
- [What is VFIO?](#2)
- [VFIO Discussion and Support](#3)
- [Hardware-Passthrough Guide](#1)
- [Virtual Machine XML Format Guide](#4)

### 4. Host Requirements
Linux.

### 5. Download
- Download the Latest Release:&ensp;[Codeberg][codeberg-releases],
[GitHub][github-releases]

- Download the `.zip` file:
    1. Viewing from the top of the repository's (current) webpage, click the
        drop-down icon:
        - `···` on Codeberg.
        - `<> Code ` on GitHub.
    2. Click `Download ZIP` and save.
    3. Open the `.zip` file, then extract its contents.

- Clone the repository:
    1. Open a Command Line Interface (CLI).
        - Open a console emulator (for Debian systems: Konsole).
        - Open a existing console: press `CTRL` + `ALT` + `F2`, `F3`, `F4`, `F5`,  or
        `F6`.
            - **To return to the desktop,** press `CTRL` + `ALT` + `F7`.
            - `F1` is reserved for debug output of the Linux kernel.
            - `F7` is reserved for video output of the desktop environment.
            - `F8` and above are unused.
    2. Change your directory to your home folder or anywhere safe:
        - `cd ~`
    3. Clone the repository:
        - `git clone https://www.codeberg.org/portellam/parse-iommu-devices`
        - `git clone https://www.github.com/portellam/parse-iommu-devices`

[codeberg-releases]: https://codeberg.org/portellam/parse-iommu-devices/releases/latest
[github-releases]:   https://github.com/portellam/parse-iommu-devices/releases/latest

### 6. Usage
#### 6.1. Install
Installer will copy required files to `/usr/bin/local/`.

```bash
sudo bash installer.sh
```

#### 6.2. Executable
- From anywhere, execute: `parse-iommu-devices`

```
  -h, --help                    Print this help and exit.
  -q, --quiet                   Quiet all output except for comma delimited lists
                                of device drivers and hardware IDs.
  -e, --external                Match IOMMU groups without only internal devices.
  -g, --group [OPTION]          Match IOMMU group ID(s). Comma delimited.
  -i, --internal                Match IOMMU groups without only external devices.
  -n, --name [OPTION]           Match IOMMU group(s) with device name.
                                Comma delimited.
  --reverse-name [OPTION]       Match IOMMU group(s) without device name.
                                Comma delimited.
  -v, --vga-index [OPTION]      Match all IOMMU groups without VGA, and any with
                                VGA which match the index value(s)
                                (not an IOMMU group ID). Comma delimited.

Examples:
  parse-iommu-devices -eq -v 2  Quiet output except for drivers and hardware IDs,
                                of IOMMU groups with external devices, and exclude
                                IOMMU groups with VGA device(s) before and after
                                the second found group.
```

### 7. Contact
Did you encounter a bug? Do you need help? Please visit the
**Issues page** ([Codeberg][codeberg-issues], [GitHub][github-issues]).

[codeberg-issues]: https://codeberg.org/portellam/parse-iommu-devices/issues
[github-issues]:   https://github.com/portellam/parse-iommu-devices/issues

### 8. References
#### 1.
**PCI passthrough via OVMF**. ArchWiki. Accessed June 14, 2024.
<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF.</sup>

#### 2.
**VFIO - ‘Virtual Function I/O’ - The Linux Kernel Documentation**.
The linux kernel. Accessed June 14, 2024.
<sup>https://www.kernel.org/doc/html/latest/driver-api/vfio.html.</sup>

#### 3.
**VFIO Discussion and Support**. Reddit. Accessed June 14, 2024.
<sup>https://www.reddit.com/r/VFIO/.</sup>

#### 4.
**XML Design Format** GitHub - libvirt/libvirt. Accessed June 18, 2024.
<sup>https://github.com/libvirt/libvirt/blob/master/docs/formatdomain.rst.</sup>

# TODO
- [ ] finish v1 of script.
  - [x] flesh out README.
  - [x] allow combined single-char arguments
  - [ ] add installer.
    - [ ] `chmod u+x name_of_script`

  - [x] add delimited output
    - hardware ids
    - drivers

  - [ ] sort by iommu groups which exclusively include
    - [ ] driver?
    - [ ] external devices
    - [ ] hardware id?
    - [ ] internal devices
    - [x] name
    - [x] type
    - [ ] vga

  - [ ] sort by iommu groups which have
    - [ ] driver?
    - [x] external devices
    - [ ] hardware id?
    - [ ] internal devices
    - [ ] name
    - [ ] type
    - [x] vga

- [ ] add to `deploy-vfio`?
- [ ] pin to profile?
- [ ] advertise to `r/vfio`?