# Parse IOMMU Devices
Go to [README](./README.md)

## To Do:
- [ ] XML file support
  - add the following to README.

```
    - [6.3. XML file](#63-xml-file)

#### 6.1. Install
Log and XML files will be generated in `/usr/local/etc/`.

```

```
#### 6.2. Executable
```
```
    -x, --xml, --xml=FILE     Query an XML file for device drivers
                            should none be found or any devices
                            are binded to VFIO;
                            FILE is the XML file name as text.
                            Leave FILE empty to use default file
                            name
                            ("/usr/local/etc/parse-iommu-devices.
                            xml").
```

```
#### 6.3. XML file
Regardless of an existing VFIO setup, the script will output lists of hardware
IDs and **valid** drivers, *if* a known good XML file is present.

##### An XML file may be generated on a known good system:
1. No VFIO drivers present
2. Drivers are installed for all relevant devices.

You may backup the default XML file (`/usr/local/etc/parse-iommu-devices.xml`).

Please feel free to share your XML file with other VFIO users and enthusiasts.
```
  - get Driver from XML file by Hardware ID.
    - prioritize this action before parsing `lspci` ?
  - write Hardware ID and Driver to XML file.

- [ ] log file
  - do I really need this?
