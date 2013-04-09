
os = require 'os'
fileops = require 'fileops'
exec = require('child_process').exec
macRegex = /(?:[a-z0-9]{1,2}[:\-]){5}[a-z0-9]{1,2}/i

class interfaces
    constructor: ->

    listInterfaces: ->
        @interfaceList = os.networkInterfaces()
        interfaces =[]
        for interfaceName,interfaceInfo of @interfaceList
            interfaces.push interfaceName
        return interfaces

    getMacAddress: (interfaceName, callback) ->
       exec "ifconfig #{interfaceName}", (err, stdout, stderr) ->
           return new Error "#{err}" if err
           macAddress = stdout.match(macRegex)[0]
           callback(macAddress)


    renameInterface: (oldName, newName, callback) ->
        @getMacAddress oldName, (macAddress) =>
            return new Error "Unable to fetch MAC address. Error is #{macAddress}" if macAddress instanceof Error
            fileops.createFile "/etc/udev/rules.d/71-cloudflash.rules", (result) =>
                return new Error  "Unable rename #{oldName} to #{newName}" if result instanceof Error
                params = "KERNEL==\"#{oldName}\", ACTION==\"add\", ATTR{address}==\"#{macAddress}\", NAME=\"#{newName}\"\n"
                fileops.updateFile "/etc/udev/rules.d/71-cloudflash.rules", params
                exec "ifconfig #{oldName} down"
                exec "/sbin/udevadm control --reload"
                exec "/sbin/udevadm trigger --subsystem-match=net --action=add --verbose", (err, stdout, stderr) =>
                    callback(err)

module.exports = interfaces

