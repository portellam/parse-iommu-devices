# Parse IOMMU Devices
### v1.0.3
Bash script to parse, sort, and display hardware devices by IOMMU group,
and return the device drivers and hardware IDs as output.

### [Download](#5-download)
#### View this repository on [Codeberg][01] or [GitHub][02].
[01]: https://codeberg.org/portellam/parse-iommu-devices
[02]: https://github.com/portellam/parse-iommu-devices
##

## Table of Contents
- [1. Why?](#1-why)
- [2. Related Projects](#2-related-projects)
- [3. Documentation](#3-documentation)
- [4. Host Requirements](#4-host-requirements)
- [5. Download](#5-download)
- [6. Usage](#6-usage)
    - [6.1. Install](#61-install)
    - [6.2. Executable](#62-executable)
    - [6.3 Parse standard output for automation or other scripts](#63-parse-standard-output-for-automation-or-other-scripts)
- [7. Contact](#7-contact)
- [8. References](#8-references)
- [9. Planned Features](#9-planned-features)

## Contents
### 1. Why?
**Do you want to know if your current machine is able to support VFIO?** then you
need *Parse IOMMU Devices*.

The script allows the user to query the exact hardware the user wishes to allocate
for a VFIO setup. After which, the script returns the relevant standard output.

The standard output may be used for kernel command line arguments, for example.
See [6. Usage](#6-usage) for details on how to best use standard output.

#### Disclaimer
For first-time use, the script must be run **without** a VFIO setup present.

An existing VFIO setup will cause selected devices to use the VFIO driver
(`vfio-pci` or sometimes `pci-stub`). **The script will skip any IOMMU groups**
**with at least one (1) device binded to VFIO.**

### 2. Related Projects
To view other relevant projects, visit [Codeberg][21]
or [GitHub][22].

[21]: https://codeberg.org/portellam/vfio-collection
[22]: https://github.com/portellam/vfio-collection

### 3. Documentation
- What is VFIO?[<sup>[2]</sup>](#2)
- VFIO Discussion and Support[<sup>[3]</sup>](#3)
- Hardware-Passthrough Guide[<sup>[1]</sup>](#1)
- Virtual Machine XML Format Guide[<sup>[4]</sup>](#4)

### 4. Host Requirements
Linux.

## 5. Download
- Download the Latest Release:&ensp;[Codeberg][51] or [GitHub][52].

- Download the `.zip` file:
    1. Viewing from the top of the repository's (current) webpage, click the
        drop-down icon:
        - `···` on Codeberg.
        - `<> Code ` on GitHub.
    2. Click `Download ZIP` and save.
    3. Open the `.zip` file, then extract its contents.

- Clone the repository:
    1. Open a Command Line Interface (CLI) or Terminal.
        - Open a console emulator (for Debian systems: Konsole).
        - **Linux only:** Open an existing console: press `CTRL` + `ALT` + `F2`,
        `F3`, `F4`, `F5`, or `F6`.
            - **To return to the desktop,** press `CTRL` + `ALT` + `F7`.
            - `F1` is reserved for debug output of the Linux kernel.
            - `F7` is reserved for video output of the desktop environment.
            - `F8` and above are unused.
    2. Change your directory to your home folder or anywhere safe:
        - `cd ~`
    3. Clone the repository:
        - `git clone https://www.codeberg.org/portellam/parse-iommu-devices`
        - `git clone https://www.github.com/portellam/parse-iommu-devices`

[51]: https://codeberg.org/portellam/parse-iommu-devices/releases/latest
[52]: https://github.com/portellam/parse-iommu-devices/releases/latest

### 6. Usage
#### 6.1. Install
Installer will copy the script file to `/usr/local/bin/`, and source files to
`/usr/local/bin/parse-iommu-devices.d/`.

```bash
sudo bash installer.sh
```

#### 6.2. Executable
- From anywhere, execute: `parse-iommu-devices`

```
  -h, --help                Print this help and exit.
  -v, --verbose             Show more output including queries and IOMMU
                            groups.

  -vv                       Show all output.
  -g, --group=GROUPS        Match IOMMU group ID(s);
                            GROUPS is a comma delimited list of positive
                            numbers.

  --ignore-group=GROUPS     Reverse match IOMMU group ID(s);
                            GROUPS is a comma delimited list of positive
                            numbers.

  -G, --graphics=INDEX      Match all IOMMU groups without a graphics
                            device, and any IOMMU group (with a graphics
                            device) whose INDEX matches the expected
                            INDEX value(s). INDEX is not an IOMMU group
                            ID;
                            INDEX is a comma delimited list of postive
                            non-zero numbers.

  -H, --host                Match IOMMU groups with at least one (1) or
                            more Host devices.

  -n, --name=NAME           Match IOMMU group(s) with device name;
                            NAME is a comma delimited list of text.

  --ignore-name=NAME        Reverse match IOMMU group(s) with device name;
                            NAME is a comma delimited list of text.

  -t, --type=TYPE           Match IOMMU group(s) with device type;
                            TYPE is a comma delimited list of text.

  --ignore-type=TYPE        Reverse match IOMMU group(s) with device type;
                            TYPE is a comma delimited list of text.

  -V, --vendor=VENDOR       Match IOMMU group(s) with device vendor;
                            VENDOR is a comma delimited list of text.

  --ignore-vendor=VENDOR    Reverse match IOMMU group(s) with device vendor;

Examples:
  parse-iommu-devices --graphics 2,3
                            Exclude the second and third matched IOMMU
                            groups with graphics device(s). Standard
                            output includes: comma-delimited lists of
                            selected hardware IDs, drivers, and IOMMU
                            group IDs.

  parse-iommu-devices -vv --ignore-name ether --pcie
                            Match output of IOMMU groups with PCI/e
                            devices, and exclude any wired ethernet
                            devices. Verbose output includes:
                            comma-delimited lists of selected hardware
                            IDs, drivers, and IOMMU group IDs; details of
                            all IOMMU groups; and telemetry.
```

### 6.3 Parse standard output for automation or other scripts
To retrieve standard output, execute the following with the options of your choice,
but **without** a verbose flag.

1. **Hardware ID** list:
```bash
  parse-iommu-devices | sed --quiet 1p
```

2. **Driver** list:
```bash
  parse-iommu-devices | sed --quiet 2p
```

3. **IOMMU group ID** list:
```bash
  parse-iommu-devices | sed --quiet 3p
```

### 7. Contact
Do you need help? Please visit the [Issues][71] page.

[71]: https://github.com/portellam/parse-iommu-devices/issues

### 8. References
#### 1.
&nbsp;&nbsp;**PCI passthrough via OVMF**. ArchWiki. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF.</sup>

#### 2.
&nbsp;&nbsp;**VFIO - ‘Virtual Function I/O’ - The Linux Kernel Documentation**.
The linux kernel. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://www.kernel.org/doc/html/latest/driver-api/vfio.html.</sup>

#### 3.
&nbsp;&nbsp;**VFIO Discussion and Support**. Reddit. Accessed June 14, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://www.reddit.com/r/VFIO/.</sup>

#### 4.
&nbsp;&nbsp;**XML Design Format** GitHub - libvirt/libvirt. Accessed June 18, 2024.

&nbsp;&nbsp;&nbsp;&nbsp;<sup>https://github.com/libvirt/libvirt/blob/master/docs/formatdomain.rst.</sup>

### 9. Planned Features
- XML file support.
  - useful for systems which have VFIO setups, but do not necessarily change
  hardware often.
##

#### Click [here](#parse-iommu-devices) to return to the top of this document.