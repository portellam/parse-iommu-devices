# Parse IOMMU Devices
### v1.0.2
Bash script to parse, sort, and display hardware devices by IOMMU group,
and return the device drivers and hardware IDs as output.

### [Download](#5-download)

## Table of Contents
- [1. Why?](#1-why)
- [2. Related Projects](#2-related-projects)
- [3. Documentation](#3-documentation)
- [4. Host Requirements](#4-host-requirements)
- [5. Download](#5-download)
- [6. Usage](#6-usage)
    - [6.1. Install](#61-install)
    - [6.2. Executable](#62-executable)
    - [6.3. XML file](#63-xml-file)
- [7. Contact](#7-contact)
- [8. References](#8-references)
- [9. Special Thanks](#9-special-thanks)

## Contents
### 1. Why?
If you wish to determine if your current machine's hardware specifications are
able to support VFIO, then this script is for you. The script allows one to
query exactly what hardware you wish to allocate for a VFIO setup, and returns
the relevant output. The output may then be used for kernel command line arguments, for example.

#### Disclaimer
For first-time use, the script must be run **without** a VFIO setup present.

VFIO setup will cause selected devices to use the VFIO driver
(`vfio-pci` or sometimes `pci-stub`). The script will skip any IOMMU groups with at least one device binded to VFIO.

For a solution to this issue, please see below for [XML file](#63-xml-file) usage.

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
Installer will copy the script file to `/usr/local/bin/`, and source files to
`/usr/local/bin/parse-iommu-devices.d/`.

Log and XML files will be generated in `/usr/local/etc/`, w

```bash
sudo bash installer.sh
```

#### 6.2. Executable
- From anywhere, execute: `parse-iommu-devices`

```
  -h, --help                Print this help and exit.
  -v, --verbose             Show more output including query
                            output and IOMMU groups.

  -vv                       Show all output.
  -g, --group=GROUPS        Match IOMMU group ID(s);
                            GROUPS is a comma delimited list of
                            positive numbers.

  --ignore-group=GROUPS     Reverse match IOMMU group ID(s),
                            overrides "--group";
                            GROUPS is a comma delimited list of
                            positive numbers.

  -H, --host                Match IOMMU groups with at least one
                            (1) or more Host devices.

  -n, --name=NAME           Match IOMMU group(s) with device
                            name;
                            NAME is a comma delimited list of
                            text.

  --ignore-name=NAME        Match IOMMU group(s) without device
                            name, overrides "--name";
                            NAME is a comma delimited list of
                            text.

  -t, --type=TYPE           Match IOMMU group(s) with device
                            type;
                            TYPE is a comma delimited list of
                            text.

  --ignore-type=TYPE        Match IOMMU group(s) without device
                            type, overrides "--type";
                            TYPE is a comma delimited list of
                            text.

  -V, --vendor=VENDOR       Match IOMMU group(s) with device
                            vendor;
                            VENDOR is a comma delimited list of
                            text.

  --ignore-vendor=VENDOR    Match IOMMU group(s) without device
                            vendor, overrides "--vendor";
                            VENDOR is a comma delimited list of
                            text.

  -p, --pci, --pcie         Match IOMMU groups with at least one
                            (1) or more PCI/PCIe bus devices.

  --vga-index=INDEX         Match all IOMMU groups without VGA,
                            and any with VGA which match the
                            index value(s) (not an IOMMU group
                            ID);
                            INDEX is a comma delimited list of
                            postive non-zero numbers.

  -x, --xml, --xml=FILE     Query an XML file for device drivers
                            should none be found or any devices
                            are binded to VFIO;
                            FILE is the XML file name as text.
                            Leave FILE empty to use default file
                            name
                            ("/usr/local/etc/parse-iommu-devices.
                            xml").

Examples:
  parse-iommu-devices --ignore-name ether --pcie --vga-index 2
                            Standard output of comma-delimited
                            lists hardware IDs and drivers (of
                            IOMMU groups with PCI/e devices),
                            exclude IOMMU groups with VGA
                            device(s) before and after the
                            second matched group, and exclude
                            any wired ethernet devices (Host and
                            PCI/e).
```

#### 6.3. XML file
Regardless of an existing VFIO setup, the script will output lists of hardware
IDs and **valid** drivers, *if* a known good XML file is present.

##### An XML file may be generated on a known good system:
1. No VFIO drivers present
2. Drivers are installed for all relevant devices.

You may backup the default XML file (`/usr/local/etc/parse-iommu-devices.xml`).

Please feel free to share your XML file with other VFIO users and enthusiasts.

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

### 9. Special Thanks
- Peer Reviewers:
  - `u/psyblade42`
