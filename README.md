# Inventory module for Rex.IO

This module stores the inventory of your hardware.

## API

Add or update an inventory:

```
curl -D- -XPOST -d@inventory.json \
  http://user:password@localhost:5000/1.0/inventory/server
```

### Network

#### Network Adapters

List network adapters of host:

```
curl -D- -XGET \
  http://user:password@localhost:5000/1.0/inventory/host/$host_id/network_adapter
```

Add a new network adapter to host:

```javascript
{
  "proto"             : "static|dhcp",
  "dev"               : "eth1",
  "ip"                : "1.2.3.4",
  "network"           : "1.2.3.255",
  "broadcast"         : "1.2.3.255",
  "gateway"           : "1.2.3.1",
  "netmask"           : "255.255.255.0",
  "mac"               : "ef:11:22:33:44:55",
  "boot"              : "0|1",
  "network_bridge_id" : $id_of_bridge
}
```

```
curl -D- -XPOST -d @iface.json \
  http://user:password@localhost:5000/1.0/inventory/host/$host_id/network_adapter
```

Update a network adapter:

```javascript
{
  "ip"                : "1.2.3.5",
}
```

```
curl -D- -XPOST -d @iface.json \
  http://user:password@localhost:5000/1.0/inventory/host/$host_id/network_adapter/$network_adapter_id
```


Delete a network adapter from a host:

```
curl -D- -XDELETE \
  http://user:password@localhost:5000/1.0/inventory/host/$host_id/network_adapter/$network_adapter_id
```

#### Bridge Adapters

List bridge adapters of host:

```
curl -D- -XGET \
  http://user:password@localhost:5000/1.0/inventory/host/$host_id/bridge
```

Add a new bridge to host:

```javascript
{
  "proto"             : "static|dhcp",
  "dev"               : "br0",
  "ip"                : "1.2.3.4",
  "network"           : "1.2.3.255",
  "broadcast"         : "1.2.3.255",
  "gateway"           : "1.2.3.1",
  "netmask"           : "255.255.255.0",
  "boot"              : "0|1",
}
```

```
curl -D- -XPOST -d @iface.json \
  http://user:password@localhost:5000/1.0/inventory/host/$host_id/bridge
```

Update a bridge:

```javascript
{
  "ip"                : "1.2.3.5",
}
```

```
curl -D- -XPOST -d @iface.json \
  http://user:password@localhost:5000/1.0/inventory/host/$host_id/bridge/$bridge_id
```

Delete a network adapter from a host:

```
curl -D- -XDELETE \
  http://user:password@localhost:5000/1.0/inventory/host/$host_id/bridge/$bridge
```
