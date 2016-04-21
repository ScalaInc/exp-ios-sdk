# ExpSwift

[![CI Status](http://img.shields.io/travis/Cesar Oyarzun/ExpSwift.svg?style=flat)](https://travis-ci.org/Cesar Oyarzun/ExpSwift)
[![Version](https://img.shields.io/cocoapods/v/ExpSwift.svg?style=flat)](http://cocoapods.org/pods/ExpSwift)
[![License](https://img.shields.io/cocoapods/l/ExpSwift.svg?style=flat)](http://cocoapods.org/pods/ExpSwift)
[![Platform](https://img.shields.io/cocoapods/p/ExpSwift.svg?style=flat)](http://cocoapods.org/pods/ExpSwift)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
CocoaPods (https://cocoapods.org/)
Swift 2 (Xcode 7.x required)

Note: Xcode 7.x uses Swift 2 and is will not work with Swift 1.2 projects

This project now supports Swift 2, if you still require Swift 1.2 you can use the `swift-1.2` branch in your Podfile

You can download Xcode 6.4 and install it outside of Applications, if you have already upgraded to Xcode 7.x
http://developer.apple.com/devcenter/download.action?path=/Developer_Tools/Xcode_6.4/Xcode_6.4.dmg

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
the development branch, add the following line to your Podfile:

```ruby
use_frameworks!

pod "ExpSwift", :git => 'https://github.com/ScalaInc/exp-ios-sdk.git', :branch => 'develop'
```

Or to use a specific release:
```ruby
use_frameworks!

pod "ExpSwift", :git => 'https://github.com/ScalaInc/exp-ios-sdk.git', :tag => 'v0.0.1'
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
- `api_key` The consumer app api key. Required consumer app credential.
- `host` The api host to authenticate with. Defaults to `https://api.goexp.io`.
- `enableNetwork` Whether or not to establish a socket connection with the EXP network. If `false` you will not be able to listen for broadcasts. Defaults to `true`.


```swift
import ExpSwift

# Init exp connection for device with Host,Uuid,secret. 
  ExpSwift.start(host,"74c05552-5b9f-4d06-a3f8-8299ff1e1e3a","7b674d4ab63e80c62591ef3fcb51da1505f420d2a9ffda8ed5d24aa6384ad1c1f10985a4fc858b046b065bcdacc105dd").then{ result -> Void in
            debugPrint(result)
            }.error { error in
                debugPrint(error)
            }

# Init exp connection for user with Host,User,Password,Organization.
  ExpSwift.start(host,"cesar.oyarzun@scala.com","Com5715031","scala").then{ result -> Void in
            debugPrint(result)
            }.error { error in
                debugPrint(error)
            }
            
# Init exp connection for user with options object.
  ExpSwift.start(["host": "https://api.exp.scala.com", "username":"cesar.oyarzun@scala.com", "password":"Com5715031", "organization":"scala").then{ result -> Void in
            debugPrint(result)
            }.error { error in
                debugPrint(error)
            }

```
## Stopping the SDK

**`ExpSwift.stop()`**

Stops all running instance of the sdk, cancels all listeners and network connections.

```swift
 ExpSwift.stop()

```

# Network

##Status

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
    var payload:Dictionary<String,AnyObject> = ["opening":"knock knock?"]
    channel.broadcast("hi", payload: payload1, timeout: "2000").then { result -> Void in
        debugPrint(result)
    }

```

**`channel.listen(name, callback)`** 

Registers a [listener](#listeners) callback for events on the channel with the given `name`. Resolves to a [listener](#listeners) when the callback is registered and the network connection has subscribed to the channel.

The callback is called with the broadcast payload as the first argument and a `respond` method as the second argument. Call the `respond` method to send a response back to the broadcaster.

```swift
    channel.listen("myEvent",  callback: { (resultListen) -> Void in
        debugPrint(resultListen)
    })
```


**`channel.fling(payload)`** 

Fling an app launch payload on the channel.
```swift
     let payload:Dictionary<String,AnyObject> = ["uuid":"myUuid"]
     channel1.fling(payload)
```


# API

## Devices

Devices inherit all [common resource methods and attributes](#resources).

**`ExpSwift.getDevice(uuid:String)`**

Get a single device by UUID. Resolves to a [Device Object](#device-object).

```swift
    ExpSwift.getDevice("8930ff64-1063-4a03-b1bc-33e1ba463d7a").then { (device: Device) -> Void  in
         debugPrint(device.get("name"))
        }.error { error in
         debugPrint(error)
    }
```

**`ExpSwift.findDevices(params:[String:AnyObject])`**

Query for multiple devices. Resolves to an array of [Device Objects](#device-object).

```swift
 //GET DEVICES
        ExpSwift.findDevices(["limit":10, "skip":0, "sort":"name"]).then { (devices: SearchResults<Device>) -> Void  in
            for device in devices.getResults() {
                debugPrint(device.get("name"))
            }
        }.error { error in
            debugPrint(error)
        }
```
## Things

**`ExpSwift.getThing(uuid:String)`**

Get a single thing by UUID. Resolves to a [Thing Object](#thing-object).

```swift
 //GET THING
        ExpSwift.getThing("8930ff64-1063-4a03-b1bc-33e1ba463d7a").then { (thing: Thing) -> Void  in
                debugPrint(thing.get("name"))
            }.error { error in
                debugPrint(error)
        }
```

**`ExpSwift.findThings(params:[String:AnyObject])`**

Query for multiple things. Resolves to an array of [Thing Objects](#thing-object).

```swift
 //FIND THINGS
        ExpSwift.findThings(["limit":10, "skip":0, "sort":"name"]).then { (things: SearchResults<Thing>) -> Void  in
            for thing in things.getResults() {
                debugPrint(thing.get("name"))
            }
        }.error { error in
            debugPrint(error)
        }
```

## Experiences

**`ExpSwift.getCurrentExperience()`**

Get the current experience. Resolves to an [Experience Object](#experience-object).

```swift
//GET CURRENT EXPERIENCE
        ExpSwift.getCurrentExperience().then { experience -> Void  in
            debugPrint(experience.get("name"))
            }.error { error in
                debugPrint(error)
        }
```

**`ExpSwift.getExperience(uuid:String)`**

Get a single experience by UUID. Resolves to a [Experience Object](#experience-object).

```swift
//GET EXPERIENCE
        ExpSwift.getExperience("58dc59e4-a44c-4b6e-902b-e6744c09d933").then { (experience: Experience) -> Void  in
            debugPrint(experience.get("name"))
        }.error { error in
                debugPrint(error)
        }
```

**`ExpSwift.findExperiences(params:[String:AnyObject])`**

Query for multiple experiences. Resolves to an array of [Experience Objects](#experience-object).

```swift
 //GET EXPERIENCES
        ExpSwift.findExperiences(["limit":10, "skip":0, "sort":"name"]).then { (experiences: SearchResults<Experience>) -> Void  in
            for experience in experiences.getResults() {
                debugPrint(experience.get("name"))
            }
        }.error { error in
                debugPrint(error)
        }

```
## Locations

**`ExpSwift.getLocation(uuid:String)`**

Get a single location by UUID. Resolves to a [Location Object](#location-object).

```swift
 //GET LOCATION
        ExpSwift.getLocation("3e2e25df-8324-4912-91c3-810751f527a4").then { (location: Location) -> Void  in
            debugPrint(location.get("name"))
            }.error { error in
                debugPrint(error)
        }

```

**`ExpSwift.findLocations(params:[String:AnyObject])`**

Query for multiple locations. Resolves to an array of [Location Objects](#location-object).

```swift
//GET LOCATIONS
        ExpSwift.findLocations(["limit":10, "skip":0, "sort":"name"]).then { (locations: SearchResults<Location>) -> Void  in
            for location in locations.getResults() {
                debugPrint(location.get("name"))
            }
            }.error { error in
                debugPrint(error)
        }

```
**`location.getZones()`**

Resolves to an array of [zones](#zones) that are part of this location.

**`location.getLayoutUrl()`**

Returns a url pointing to the location's layout image.



## Zones

Zones inherit the [common resource methods and attributes](#resources) `save()`, `refresh()`, and `getChannel()`.

**`zone.key`**

The zone's key.

**`zone.name`**

The zone's name.

## Feeds

**`ExpSwift.getFeed(uuid:String)`**

Get a single feed by UUID. Resolves to a [Feed Object](#feed-object).

```swift
//GET FEED
    ExpSwift.getFeed("3e2e25df-8324-4912-91c3-810751f527a4").then { (feed: Feed) -> Void  in
            debugPrint(feed.get("name"))
        }.error { error in
            debugPrint(error)
    }

```

**`ExpSwift.findFeeds(params:[String:AnyObject])`**

Query for multiple feeds. Resolves to an array of [Feed Objects](#feed-object).

```swift

    ExpSwift.findFeeds(["limit":10, "skip":0, "sort":"name"]).then { (locations: SearchResults<Feed>) -> Void  in
        for feed in feeds.getResults() {
            debugPrint(feed("name"))
        }
    }.error { error in
        debugPrint(error)
    }

```
## Feed Object

**`feed.uuid`**

The feed's UUID

**`feed.getData()`**

Get the feed's data. Resolves to the output of the feed query.
```swift
    feed.getData().then { (data: [AnyObject]) -> Void in
        debugPrint(data)
    }.error { error in
    debugPrint(error)
    }

```

## Data

**`ExpSwift.getData(group:String, key:String)`**

Get a single data item by group and key. Resolves to a [Data Object](#data-object).

```swift
//GET DATA
    ExpSwift.getData("cats", "fluffbottom").then { (data: Data) -> Void  in
            debugPrint(data.get("value"))
        }.error { error in
            debugPrint(error)
    }

```

**`ExpSwift.findData(params:[String:AnyObject])`**

Query for multiple data items. Resolves to an SearchResults object containing [Data Objects](#data-object).

```swift
//GET DATA
    ExpSwift.findData(["limit":10, "skip":0, "sort":"key", "group":"cats"]).then { (data: SearchResults<Data>) -> Void  in
        for dataItem in data.getResults() {
            debugPrint(dataItem.get("value"))
        }
    }.error { error in
        debugPrint(error)
    }

```

## Content

**`ExpSwift.getContentNode(uuid)`**

Get a content node by UUID. Resolves to a [ContentNode Object](#content-object). Note: The UUID value of 'root' will return the contents of the root folder of the current organization.

```swift
    ExpSwift.getContentNode("root").then { (content: ContentNode) -> Void  in
                          debugPrint(content.get("name"))
                        }.error { error in
                            debugPrint(error)
                        }
```

**`ExpSwift.findContentNodes(params:[String:AnyObject])`**

Query for multiple content nodes. Resolves to a SearchResults object containing [ContentNode Objects](#content-object).

```swift
//GET CONTENT
    ExpSwift.findContentNodes(["limit":10, "skip":0, "sort":"name", "name":"images"]).then { (data: SearchResults<ContentNode>) -> Void  in
        for contentNode in data.getResults() {
            debugPrint(contentNode.get("name"))
        }
    }.error { error in
        debugPrint(error)
    }

```

## ContentNode Object

**`content.uuid`**

The content's UUID.

**`content.getChildren()`**

Get the immediate children of this content node. Resolves to an array of [ContentNode Objects](#content-object).

```swift
 content.getChildren().then { (children: [ContentNode]) -> Void in
                            for child in children{
                                debugPrint(child.get("name"))
                            }
                            }.error { error in
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

# LOGGING

If you want to see the ExpSwift logs you need to Click on the POD project name at the top of the File Navigator at the left of the Xcode project window. Choose the Build Settings tab and scroll down to the "Swift Compiler - Custom Flags" section near the bottom. Click the Down Arrow next to Other Flags to expand the section.
Click on the Debug line to select it. Place your mouse cursor over the right side of the line and double-click. A list view will appear. Click the + button at the lower left of the list view to add a value. A text field will become active.
In the text field, enter the text **-D DEBUG** and press Return to commit the line.

![alt tag](https://github.com/ScalaInc/exp-ios-sdk/blob/feature/logging/debuggFlag.png)


## Author

Cesar Oyarzun, cesar.oyarzun@scala.com

## License

ExpSwift is available under the MIT license. See the LICENSE file for more info.
