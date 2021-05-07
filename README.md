# iOSVoIPLib

This library is an opinionated VoIP wrapper for iOS applications. It currently uses Linphone as the underlying SIP library.

## Installation

Install using [Cocoa Pods](https://cocoapods.org).

## Registration

Step 1: Create a Config object . This object contains all the possible configuration options, however the auth parameter is the only one that is required, the rest will use sensible defaults.

```
let config = Config(auth: Auth(name: "username", password: "password", domain: "domain", port: "port"),
                    callDelegate: callManager)

```

Step 2: Get an instance of the VoIPLib and initialise it with the config

```
let voipLib = VoIPLib.shared
voipLib.initialize(config: config)
```

Step 3: Call `register` to register with the authentication information provided in the config

```
voipLib.register { state in
    if state == .registered {
        print("Registration was successful.")
    }
}
```

To `unregister` use:

```
voipLib.unregister {
    print("Unregistering.")
}
```

## Calling

To receive events you must provide an object that implements the CallDelegate protocol. This provides a handful of simple methods that will allow your application to update based on the current state of the call. There is further documentation within the CallDelegate protocol as to what each callback method does.

Once created this object should be provided in the config provided.

The CallDelegate listens for the following events:

 - incomingCallReceived
 - outgoingCallCreated
 - callConnected
 - callEnded
 - callUpdated
 - error

All of these methods will provide a Call object, listening to these methods is the only way to obtain a call object so actions can be performed on it.

### Outgoing call

Once registered you can make a call as follows:

```
voipLib.call(to: "0612345678")
```

If setup successfully this will be followed shortly by a call to the outgoingCallCreated method which will provide a Call object.

### Incoming call

When successfully registered, the library will be listening for incoming calls. If one is received the incomingCallReceived callback method will be triggered.

Answering or declining an incoming call are considered actions, you can perform an action on a call as follows:

    voipLib.actions(call: call).accept()

or

    voipLib.actions(call: call).end()

There are many more actions available for calls, please inspect the Actions class to see what more can be done to active calls.

 ## Basic Example

The library contains an example app that shows more clearly how to use the library but the following is a very basic example for making an outgoing call.

    let config = Config(
      auth: Auth(name:"my username", password: "my password", domain: "sip.com", port: 5061),
      callDelegate: myCallManager,
      encryption: true,
      stun: "mystunserver.com",
      codecs: [Codec.OPUS]
    )

    let voipLib = VoIPLib.shared
    voipLib.initialize(config: config)

    voipLib.register { state in
        if state == .registered {
            voipLib.call(to: "0612345678")
        }
    }

 ## Notes

### Background Incoming Calls

Incoming calls on mobile devices typically use push notifications to trigger a registration, this is the our recommendation but implementing it is out of scope for this library.

### Recommended Usage

Although other use-cases are supported, we suggest performing a full initialisation before each call, and completely destroying the library after the call has completed.

 ## Pull Requests

This library is designed to simplify using VoIP in an iOS application and as such must be somewhat opinionated. This means the library will not support every possible situation.

Any pull requests should keep this in-mind as they will not be approved if they add a significant amount of complexity.

## Other
If you have any question please let us know via `opensource@wearespindle.com` or by opening an issue.
