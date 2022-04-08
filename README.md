# epos2_printer

This project is a support plugin for the printer TM-M30

## Getting Started

### How to setup project
1. Select the project in the root location from the Project Navigation
2. Select Build Phase from Targets.
3. Expand Link Binary With Libraries and the click "+".
4. Select libxml2.2.* and ExternalAccessory.framework and then click Add.
5. Set the protocol name according to the following procedure.
    1. In Project Navigator, select *.plist. (The file name will be Project name-info.)
    2. In the pop-up menu, select Add Row.
    3. Select "Supported external accessory protocols".
    4. Expand the items added in Step 3.
    5. Enter com.epson.escpos as the Value for Item 0.

