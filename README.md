# Azure-iot-edge on AXC F 2152 FW 2021.0 LTS

### An 8 gb - PLCnext SD card is nessesary 

## Download and install on target

Alternatively to the download of the installer the bin can be downloaded directly to the target.


### Download the Project
```bash
git clone https://github.com/pxcbe/azure-iot-edge.git
cd azure-iot-edge/install
```

## Create Root user and log in as Root

```
sudo passwd root
su
```
### Modify config file

Please copy paste your connection string to the file config.yaml (line 55)

### modify IoT Parameters and Setup EdgeDevice
```bash
chmod +x SetupEdge.sh
./SetupEdge.sh
```

### Reboot the controller
```bash
reboot
```


# IMPORTANT

Remember to Disable nginx or modify edge* from port 443 -> 44X
If you stop nginx, you'll lose the webbased management

```bash
/etc/init.d/nginx stop
```

# TROUBLESHOOT

To check if the installation was succesfull try this command:
```
iotedge check -v 
```

## Connection Demon

Getting the next error message and just rebooted the controller?
Wait a good minute or two, the problem should resolve itself.

```
× config.yaml has correct URIs for daemon mgmt endpoint - Error
    Error: could not execute list-modules request: an error occurred trying to connect: Connection refused (os error 111)
```


