# Parse IOMMU Devices
## TODO
- [ ] XML file support
  - add back this usage
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
"Log and XML files will be generated in `/usr/local/etc/`".

  - get Driver from XML file by Hardware ID.
    - prioritize this action before parsing `lspci` ?
  - write Hardware ID and Driver to XML file.

- [ ] log file
  - do I really need this?
