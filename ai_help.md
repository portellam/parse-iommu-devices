https://workik.com/ai-powered-xml-generator

# Query:

Given the following example XML, generate the script to append, insert, update, and delete attributes and values at each level. The script must use "xmlstarlet" and run in Bash terminal.

<devices>
    <hardware id="1">
        <driver>ExampleDriver</driver>
    </hardware>
</devices>

# Answer

bash
#!/bin/bash

# Original XML data
XML_DATA='<devices>
    <hardware id="1">
        <driver>ExampleDriver</driver>
    </hardware>
</devices>'

# Create a temporary XML file
echo "$XML_DATA" > devices.xml

# Function to append a new hardware element
append_hardware() {
    xmlstarlet ed -s /devices -t -n hardware -v "" \
    -i /devices/hardware[last()] -t -n driver -v "NewDriver" \
    -a /devices/hardware[last()] -i @id -v "$1" devices.xml
}

# Function to insert a new attribute to existing hardware
insert_attribute_to_hardware() {
    xmlstarlet ed -u "/devices/hardware[@id='$1']" -i @version -v "$2" devices.xml
}

# Function to update the driver value of a specific hardware
update_driver_value() {
    xmlstarlet ed -u "/devices/hardware[@id='$1']/driver" -v "$2" devices.xml
}

# Function to delete a hardware element by id
delete_hardware() {
    xmlstarlet ed -d "/devices/hardware[@id='$1']" devices.xml
}

# Example usage:
# Append a new hardware with ID "2"
append_hardware "2"

# Insert a new attribute to existing hardware with ID "1"
insert_attribute_to_hardware "1" "1.0"

# Update the driver value of hardware with ID "1"
update_driver_value "1" "UpdatedDriver"

# Delete the hardware element with ID "2"
delete_hardware "2"

# Print the modified XML
xmlstarlet fo devices.xml

### Explanation of Commands:
1. **append_hardware**: 
   - `xmlstarlet ed -s /devices -t -n hardware -v ""` creates a new `hardware` element under the `devices` root.
   - `-i /devices/hardware[last()] -t -n driver -v "NewDriver"` adds a `driver` child element to the newly created `hardware`.
   - `-a /devices/hardware[last()] -i @id -v "$1"` sets the `id` attribute for the new `hardware`.

2. **insert_attribute_to_hardware**: 
   - `xmlstarlet ed -u "/devices/hardware[@id='$1']" -i @version -v "$2"` inserts a new attribute `version` with the specified value into the `hardware` element with the given `id`.

3. **update_driver_value**: 
   - `xmlstarlet ed -u "/devices/hardware[@id='$1']/driver" -v "$2"` updates the `driver` element text for the specified `hardware`.

4. **delete_hardware**: 
   - `xmlstarlet ed -d "/devices/hardware[@id='$1']"` deletes the `hardware` element with the specified `id`.

### Final Output:
- The modified XML is printed using `xmlstarlet fo devices.xml`, formatting the XML for readability.

Make sure to give the script executable permissions using `chmod +x script_name.sh` before running it. You can run the script in the terminal with `./script_name.sh`.