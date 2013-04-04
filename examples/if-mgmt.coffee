interfaces = require '../lib/interface-management'
exec = require('child_process').exec

oldName="wan0"
newName="eth0"
splitname="wan"
found=0
interfacesInfo = new interfaces
#check if any interface with eth*"
interfaces = interfacesInfo.listInterfaces()
console.log "Following are the interfaces present before modification"
console.log interfaces

# check if the interface to rename exists
for interface in interfaces
    name = interface.split("#{splitname}")[0]
    found=1
    break

# Now rename the interface
if found
    interfacesInfo.renameInterface oldName, newName, (result) ->
        console.log result if result

#Wait a while or force restart the network
exec "/etc/init.d/networking restart"


        



    

