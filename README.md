# ExpSwift

[![CI Status](http://img.shields.io/travis/Cesar Oyarzun/ExpSwift.svg?style=flat)](https://travis-ci.org/Cesar Oyarzun/ExpSwift)
[![Version](https://img.shields.io/cocoapods/v/ExpSwift.svg?style=flat)](http://cocoapods.org/pods/ExpSwift)
[![License](https://img.shields.io/cocoapods/l/ExpSwift.svg?style=flat)](http://cocoapods.org/pods/ExpSwift)
[![Platform](https://img.shields.io/cocoapods/p/ExpSwift.svg?style=flat)](http://cocoapods.org/pods/ExpSwift)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
CocoaPods (https://cocoapods.org/)
Swift 3 (Xcode 8.0 required)

for IOS 9.0 add Transport Security into info.plist

```xml
<key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
```

## Installation

ExpSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!
pod "ExpSwift"
```

Or to use a specific release:

```ruby
use_frameworks!
pod "ExpSwift", , :git => 'https://github.com/ScalaInc/exp-ios-sdk.git', :tag => 'v1.0.4'
```

# Runtime

## Starting the SDK

**`ExpSwift.start(options)`**

Starts and returns an sdk instance. Can be called multiple times to start multiple independent instances of the sdk. The sdk can be started using user, device, or consumer app credentials. `options` is an object that supports the following properties:

- `username` The username used to log in to EXP. Required user credential.
- `password` The password of the user. Required user credential.
- `organization` The organization of the user. Required user credential.
- `uuid` The uuid of the device or consumer app.
- `secret` The device secret.
- `apiKey` The consumer app api key. Required consumer app credential.
- `host` The api host to authenticate with. Defaults to `https://api.goexp.io`.
- `enableNetwork` Whether or not to establish a socket connection with the EXP network. If `false` you will not be able to listen for broadcasts. Defaults to `true`.


```swift
import ExpSwift

# Init exp connection for device with Host,Uuid,secret. 
  ExpSwift.start(host,"74c05552-5b9f-4d06-a3f8-8299ff1e1e3a","7b674d4ab63e80c62591ef3fcb51da1505f420d2a9ffda8ed5d24aa6384ad1c1f10985a4fc858b046b065bcdacc105dd").then{ result -> Void in
            debugPrint(result)
            }.catch { error in
                debugPrint(error)
            }

# Init exp connection for user with Host,User,Password,Organization.
  ExpSwift.start(host,"cesar.oyarzun@scala.com","Com5715031","scala").then{ result -> Void in
            debugPrint(result)
            }.catch { error in
                debugPrint(error)
            }
            
# Init exp connection for user with options object.
  ExpSwift.start(["host": "https://api.exp.scala.com", "username":"cesar.oyarzun@scala.com", "password":"Com5715031", "organization":"scala").then{ result -> Void in
            debugPrint(result)
            }.catch { error in
                debugPrint(error)
            }
```


## Stopping the SDK

**`ExpSwift.stop()`**

Stops all running instance of the sdk, cancels all listeners and network connections.

```swift
 ExpSwift.stop()
```

## Authentication


**`ExpSwift.auth`**

Returns the current authentication payload. Will be null if not yet authenticated.

```swift
#GET USERNAME
let document = ExpSwift.auth?.getDocument()
debugPrint(document!["identity"]);
debugPrint(document!["identity"]!["username"]);
```

**`ExpSwift.on("update",callback)`** 

Callback is called when authentication payload is updated.


**`ExpSwift.on("error",callback)`**

Register a callback for when the sdk instance encounters a critical error and cannot continue. The callback is called with the error as the first argument. This is generally due to authentication failure.

```swift
ExpSwift.on("error", callback: { obj -> Void in
    debugPrint("Error on EXP SDK")
})
```

# Real Time Communication


## Status


**`ExpSwift.connection(name, callback)`** 

Attaches a listener for connection events. The possible events are `online` (when a connection is established to EXP) and `offline` (when the connection to EXP is lost).


```swift
ExpSwift.connection("online", { obj -> Void in
            debugPrint(obj)
        })
        
ExpSwift.connection("offline", { obj -> Void in
            debugPrint(obj)
        })
```

**`ExpSwift.isConnected()`**

Whether or not you are connected to the network.


## Channels
 
 **`exp.getChannel(name, system, consumerApp)`** 
 
 Returns a channel with the given name with two flags: `consumerApp` and `system`. Consumer devices can only listen and broadcast on consumer channels. System channels are listen only and can receive broadcasts about system events.
 
```swift
    let channel = ExpSwift.getChannel("my-channel",system: false,consumerApp: true)
```

**`channel.broadcast(name, payload, timeout)`** 

Sends a broadcast with given `name` and `payload` on the channel. Waits for responses for `timeout` milliseconds and resolves with an array of responses.

```swift
    var payload:Dictionary<String,Any> = ["opening":"knock knock?"]
    channel.broadcast("hi", payload: payload1, timeout: "2000").then { result -> Void in
        debugPrint(result)
    }
```

**`channel.listen(name, callback)`** 

Registers a [listener](#listeners) callback for events on the channel with the given `name`. Resolves to a [listener](#listeners) when the callback is registered and the network connection has subscribed to the channel.

The callback is called with the broadcast payload as the first argument. Call the `respond` method to send a response back to the broadcaster.

```swift
    channel.listen("myEvent",  callback: { (resultListen) -> Void in
        debugPrint(resultListen)
        //respond to listen method
        ExpSwift.respond(["text":"hi to you too"])
    })
```

**`ExpSwift.respond(payload)`**

Call the `respond` method to send a response back to the broadcaster whith a `payload`.

```swift
    var payload:Dictionary<String,Any> = ["opening":"knock knock?"]
    ExpSwift.respond(payload).then { result -> Void in
        debugPrint(result)
    }
```

**`channel.fling(payload)`** 

Fling an app launch payload on the channel.

```swift
     let payload:Dictionary<String,Any> = ["uuid":"myUuid"]
     channel1.fling(payload)
```

**`channel.identify()`**

Requests that [devices](#devices) listening for this event on this channel visually identify themselves. Implementation is device specific; this is simply a convience method.

```swift
let channel = ExpSwift.getChannel("device uui",system: false,consumerApp: false)
channel1.identify()
```

# API

## Devices

Devices inherit all [common resource methods and attributes](#model).

**`ExpSwift.getDevice(uuid:String)`**

Get a single device by UUID. Resolves to a [Device](#devices).

```swift
ExpSwift.getDevice("8930ff64-1063-4a03-b1bc-33e1ba463d7a").then { (device: Device) -> Void  in
         debugPrint(device.get("name"))
        }.catch { error in
         debugPrint(error)
}
```

**`ExpSwift.findDevices(params:[String:Any])`**

Query for multiple devices. Resolves to an array of [Devices](#devices).

```swift
ExpSwift.findDevices(["limit":10, "skip":0, "sort":"name"]).then { (devices: SearchResults<Device>) -> Void  in
            for device in devices {
                debugPrint(device.get("name"))
            }
        }.catch { error in
            debugPrint(error)
}
```

**`ExpSwift.createDevice(document:[String:Any])`**

Resolves to a device created based on the supplied document.

```swift
ExpSwift.createDevice( ["name":"Device Swift","subtype":"scala:device:player"] ).then { (device: Device) -> Void in
                     debugPrint(device)
        }.catch { error in
            debugPrint(error)
    }
```

**`ExpSwift.deleteDevice(uuid:String)`**


```swift
ExpSwift.deleteDevice(device.getUuid()).then{ () -> Void in
        debugPrint("Device Deleted!")
    }.catch { error in
        debugPrint(error)
}
```

**`device.getLocation()`**

Resolves to the device's [location](#locations) or `null`.

**`device.getZones()`**

Resolves to an array of the device's [zones](#zones).

**`device.getExperience()`**

Resolves to the device's [experience](#experiences) or `null`

**`Device.getCurrentDevice()`**

Resolves to the current Device(#devices) or `null`


## Things

Things inherit all [common resource methods and attributes](#model).

**`ExpSwift.getThing(uuid:String)`**

Get a single thing by UUID. Resolves to a [Thing](#things).

```swift
ExpSwift.getThing("8930ff64-1063-4a03-b1bc-33e1ba463d7a").then { (thing: Thing) -> Void  in
                debugPrint(thing.get("name"))
            }.catch { error in
                debugPrint(error)
}
```

**`ExpSwift.findThings(params:[String:Any])`**

Query for multiple things. Resolves to an array of [Things](#things).

```swift
ExpSwift.findThings(["limit":10, "skip":0, "sort":"name"]).then { (things: SearchResults<Thing>) -> Void  in
    for thing in things {
        debugPrint(thing.get("name"))
    }
}.catch { error in
    debugPrint(error)
}
```

**`Exp.createThing(document:[String:Any])`**

Resolves to a thing created based on the supplied document.

```swift
ExpSwift.createThing( ["name","Rfid Name","subtype":"scala:thing:rfid","id","rfid id"] ).then { (thing: Thing) -> Void in
                     debugPrint(thing)
        }.catch { error in
            debugPrint(error)
    }
```

**`ExpSwift.deleteThing(uuid:String)`**


```swift
ExpSwift.deleteThing(thing.getUuid()).then{ () -> Void in
        debugPrint("Thing Deleted!")
    }.catch { error in
        debugPrint(error)
}
```

**`thing.getLocation()`**

Resolves to the device's [location](#locations) or `null`.

**`thing.getZones()`**

Resolves to an array of the device's [zones](#zones).

**`thing.getExperience()`**

Resolves to the device's [experience](#experiences) or `null`


## Experiences

Experiences inherit all [common resource methods and attributes](#model).

**`ExpSwift.getExperience(uuid:String)`**

Get a single experience by UUID. Resolves to a [Experience](#experiences).

```swift
ExpSwift.getExperience("58dc59e4-a44c-4b6e-902b-e6744c09d933").then { (experience: Experience) -> Void  in
    debugPrint(experience.get("name"))
}.catch { error in
        debugPrint(error)
}
```

**`ExpSwift.findExperiences(params:[String:Any])`**

Query for multiple experiences. Resolves to an array of [Experiences](#experiences).

```swift
ExpSwift.findExperiences(["limit":10, "skip":0, "sort":"name"]).then { (experiences: SearchResults<Experience>) -> Void  in
    for experience in experiences{
        debugPrint(experience.get("name"))
    }
}.catch { error in
        debugPrint(error)
}
```

**`Exp.createExperience(document:[String:Any])`**

Resolves to an experience created based on the supplied document.

```swift
ExpSwift.createExperience( ["name","Experience Name"] ).then { (experience: Experience) -> Void in
                     debugPrint(experience)
        }.catch { error in
            debugPrint(error)
    }
```

**`ExpSwift.deleteExperience(uuid:String)`**


```swift
ExpSwift.deleteExperience(experience.getUuid()).then{ () -> Void in
        debugPrint("Experience Deleted!")
    }.catch { error in
        debugPrint(error)
}
```

**`experience.getDevices()`**

Resolves to an array of [devices](#devices) that are part of this experience.

**`experience.getCurrentExperience()`**

Resolves to the current Experience(#experiences) or `null`


## Locations

Locations inherit all [common resource methods and attributes](#model).

**`ExpSwift.getLocation(uuid:String)`**

Get a single location by UUID. Resolves to a [Location](#locations).

```swift
ExpSwift.getLocation("3e2e25df-8324-4912-91c3-810751f527a4").then { (location: Location) -> Void  in
    debugPrint(location.get("name"))
    }.catch { error in
        debugPrint(error)
}
```

**`ExpSwift.findLocations(params:[String:Any])`**

Query for multiple locations. Resolves to an array of [Locations](#locations).

```swift
ExpSwift.findLocations(["limit":10, "skip":0, "sort":"name"]).then { (locations: SearchResults<Location>) -> Void  in
    for location in locations {
        debugPrint(location.get("name"))
    }
    }.catch { error in
        debugPrint(error)
}
```

**`Exp.createLocation(document:[String:Any])`**

Resolves to a location created based on the supplied document.

```swift
ExpSwift.createLocation( ["name","Location Name"] ).then { (location: Location) -> Void in
                     debugPrint(location)
        }.catch { error in
            debugPrint(error)
    }
```

**`ExpSwift.deleteLocation(uuid:String)`**


```swift
ExpSwift.deleteLocation(location.getUuid()).then{ () -> Void in
        debugPrint("Location Deleted!")
    }.catch { error in
        debugPrint(error)
}
```


**`location.getZones()`**

Resolves to an array of [zones](#zones) that are part of this location.

**`location.getLayoutUrl()`**

Returns a url pointing to the location's layout image.

**`location.getDevices()`**

Resolves to an array of [devices](#devices) that are part of this location.

**`location.getCurrentLocation()`**

Resolves to the current Location(#locations) or `null`

```swift
location.getDevices().then { (devices: SearchResults<Device>) -> Void  in
    for device in devices {
        debugPrint(device.get("name"))
    }
    }.catch { error in
        debugPrint(error)
}
```

**`location.getThings()`**

Resolves to an array of [things](#things) that are part of this location.

```swift
location.getThings().then { (things: SearchResults<Thing>) -> Void  in
    for thing in things {
        debugPrint(thing.get("name"))
    }
    }.catch { error in
        debugPrint(error)
}
```

## Zones

Zones inherit all [common resource methods and attributes](#model).

**`zone.key`**

The zone's key.

**`zone.name`**

The zone's name.

**`zone.getCurrentZones()`**

Resolves to the current zones or an empty array.

**`zone.getDevices()`**

Resolves to an array of [devices](#devices) that are members of this zone.

```swift
zone.getDevices().then { (devices: SearchResults<Device>) -> Void  in
    for device in devices {
        debugPrint(device.get("name"))
    }
    }.catch { error in
        debugPrint(error)
}
```

**`zone.getThings()`**

Resolves to an array of [things](#things) that are members of this zone.

```swift
zone.getThings().then { (things: SearchResults<Thing>) -> Void  in
    for thing in things {
        debugPrint(thing.get("name"))
    }
    }.catch { error in
        debugPrint(error)
}
```

**`zone.getLocation()`**

Resolves to the zone's [location](#locations)

## Feeds

Feeds inherit all [common resource methods and attributes](#model).

**`ExpSwift.getFeed(uuid:String)`**

Get a single feed by UUID. Resolves to a [Feed](#feeds).

```swift
ExpSwift.getFeed("3e2e25df-8324-4912-91c3-810751f527a4").then { (feed: Feed) -> Void  in
        debugPrint(feed.get("name"))
    }.catch { error in
        debugPrint(error)
}
```

**`ExpSwift.findFeeds(params:[String:Any])`**

Query for multiple feeds. Resolves to an array of [Feeds](#feeds).

```swift
ExpSwift.findFeeds(["limit":10, "skip":0, "sort":"name"]).then { (locations: SearchResults<Feed>) -> Void  in
    for feed in feeds {
        debugPrint(feed("name"))
    }
}.catch { error in
    debugPrint(error)
}
```

**`Exp.createFeed(document:[String:Any])`**

Resolves to a feed created based on the supplied document.

```swift
ExpSwift.createFeed( ["name","My Weather Feed","subtype","scala:feed:weather","searchValue","16902"] ).then { (feed: Feed) -> Void in
                     debugPrint(feed)
        }.catch { error in
            debugPrint(error)
    }
```

**`ExpSwift.deleteFeed(uuid:String)`**


```swift
ExpSwift.deleteFeed(feed.getUuid()).then{ () -> Void in
        debugPrint("Feed Deleted!")
    }.catch { error in
        debugPrint(error)
}
```


## Feed Object

**`feed.uuid`**

The feed's UUID

**`feed.getData()`**

Get the feed's data. Resolves to the output of the feed query.
```swift
    feed.getData().then { (data: [Any]) -> Void in
        debugPrint(data)
    }.catch { error in
    debugPrint(error)
    }
```

**`feed.getData(query:[String:Any])`**

Get the feed's dynamic data. Resolves to the output of the feed query, with dynamic parameters.
```swift
    feed.getData(["name":"scala"]).then { (data: [Any]) -> Void in
        debugPrint(data)
    }.catch { error in
    debugPrint(error)
    }
```

## Data

Data inherit all [common resource methods and attributes](#model).There is a limit of 16MB per data document.

**`ExpSwift.getData(group:String, key:String)`**

Get a single data item by group and key. Resolves to a [Data](#data).

```swift
ExpSwift.getData("cats", "fluffbottom").then { (data: Data) -> Void  in
        debugPrint(data.get("value"))
    }.catch { error in
        debugPrint(error)
}
```

**`ExpSwift.findData(params:[String:Any])`**

Query for multiple data items. Resolves to an SearchResults object containing [Data](#data).

```swift
ExpSwift.findData(["limit":10, "skip":0, "sort":"key", "group":"cats"]).then { (data: SearchResults<Data>) -> Void  in
    for dataItem in data {
        debugPrint(dataItem.get("value"))
    }
}.catch { error in
    debugPrint(error)
}
```

**`Exp.createData(group:String, key:String, value:[String,Any])`**

Resolves to a data item created based on the supplied group, key, and value.

```swift
 ExpSwift.createData("test",key: "datatest", document: ["name":"Device Swift","subtype":"scala:device:player"] ).then { (data:ExpSwift.Data) -> Void in
        debugPrint(data)
        }.catch { error in
            debugPrint(error)
    }
```

**`ExpSwift.deleteData(group:String,key:String)`**


```swift
ExpSwift.deleteData("groupname",key: "keyName").then{ () -> Void in
        debugPrint("Data Deleted!")
    }.catch { error in
        debugPrint(error)
}
```

## Content

Content inherit all [common resource methods and attributes](#model) except save().

**`ExpSwift.getContent(uuid)`**

Get a content node by UUID. Resolves to a [Content](#content). Note: The UUID value of 'root' will return the contents of the root folder of the current organization.

```swift
ExpSwift.getContent("root").then { (content: Content) -> Void  in
      debugPrint(content.get("name"))
    }.catch { error in
        debugPrint(error)
    }
```

**`ExpSwift.findContent(params:[String:Any])`**

Query for multiple content . Resolves to a SearchResults object containing [Content](#content).

```swift
ExpSwift.findContent(["limit":10, "skip":0, "sort":"name", "name":"images"]).then { (data: SearchResults<Content>) -> Void  in
    for content in data {
        debugPrint(content.get("name"))
    }
}.catch { error in
    debugPrint(error)
}
```

## Content Object

**`content.uuid`**

The content's UUID.

**`content.getChildren()`**

Get the immediate children of this content node. Resolves to an array of [Content](#content).

```swift
 content.getChildren().then { (children: [Content]) -> Void in
    for child in children{
        debugPrint(child.get("name"))
    }
    }.catch { error in
        debugPrint(error)
    }
```

**`content.getChildren(options)`**

Resolves to a SearchResults object containing children [Content](#content).

```swift
  content.getChildren(["id":"123"]]).then { (children: SearchResults<Content>) -> Void in
    for child in children{
        debugPrint(child.get("name"))
    }
    }.catch { error in
    debugPrint(error)
    }
```

**`content.getUrl()`**

Get the absolute url to the content node data. Useful for image/video tags or to download a content file. Returns empty String for folders

```swift
let url = content.getUrl();
```

**`content.getVariantUrl(name:String)`**

Get the absolute url to the content node's variant data. Useful for image/video thumbnails or transcoded videos. Returns empty String for folders or if content does not contain the variant

```swift
let url = content.getVariantUrl("320.png");
```

## Model

These methods and attributes are shared by many of the abstract API resources.

**`getUuid()`**

Returns the uuid of the resource. Cannot be set.

```swift
let uuid:String = data.getUuid()
```

**`get(name:String)`**

Returns an object by the name specify if exist in the properties document.

```swift
let name = data.get("name")
```

**`getChannel()`**

Returns the channel whose name is contextually associated with this resource.

```swift
let channel = data.getChannel();
```

**`getChannel(system:Bool,consumer:Bool)`**

Returns the channel whose name is contextually associated with this resource, with the options for system and consumer .

```swift
let channel = data.getChannel(false,true);
```

**`getDocument()`**

The resource’s underlying document.

```swift
let document = data.getDocument();
```

**`setProperty(name:String,value:Any)`**

Set a new property with name and value to the resource.

```java
device.setProperty(name: "name", value: "Device Updated")
```

**`save()`**

Saves the resource and updates the document in place. Returns a promise to the save operation.

```swift
ExpSwift.getDevice("8930ff64-1063-4a03-b1bc-33e1ba463d7a").then { (device: Device) -> Void in
    device.setProperty(name: "name", value: "Device Updated SDK")
    device.save().then{(device: Device) -> Void in
        }.catch { error in
           debugPrint(error)
    }
}.catch { error in
    debugPrint(error)
}
```

**`refresh()`**

Refreshes the resource’s underlying document in place. Returns a promise to refresh operation.

```swift
ExpSwift.getDevice("8930ff64-1063-4a03-b1bc-33e1ba463d7a").then { (device: Device) -> Void in
    device.setProperty(name: "name", value: "Device Updated SDK")
    device.save().then{(device: Device) -> Void in
        device.refresh().then { (device: Device) -> Void in
            debugPrint("Device Refresh")
            }.catch { error in
                debugPrint(error)
            }
        }.catch { error in
           debugPrint(error)
    }
}.catch { error in
    debugPrint(error)
}
```

# LOGGING

If you want to see the ExpSwift logs you need to Click on the POD project name at the top of the File Navigator at the left of the Xcode project window. Choose the Build Settings tab and scroll down to the "Swift Compiler - Custom Flags" section near the bottom. Click the Down Arrow next to Other Flags to expand the section.
Click on the Debug line to select it. Place your mouse cursor over the right side of the line and double-click. A list view will appear. Click the + button at the lower left of the list view to add a value. A text field will become active.
In the text field, enter the text **-D DEBUG** and press Return to commit the line.

![alt tag](https://github.com/ScalaInc/exp-ios-sdk/blob/feature/logging/debuggFlag.png)

## Author

Cesar Oyarzun, cesar.oyarzun@scala.com

## License

ExpSwift is available under the MIT license. See the LICENSE file for more info.
