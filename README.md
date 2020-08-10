# Flutter Zoom Plugin

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A Flutter plugin for the Zoom SDK.

*Note*: This plugin is still under active development, and some Zoom features might not be available yet. We are working to add more features.
Feedback and Pull Requests are always welcome.

## Features

- [x] Stream meeting status.
- [x] Join meeting.
- [x] Start an existing meeting for non-login user.
- [ ] Start an existing meeting for logged in user.
- [ ] Start an instant meeting for logged in user.

## Zoom SDK Versions

Android: https://github.com/zoom/zoom-sdk-android/releases/tag/v4.6.21666.0429
 
iOS: https://github.com/zoom/zoom-sdk-ios/releases/tag/v4.6.21666.0428

## Installation

First, add `flutter_zoom_plugin` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

Use the git tags for deployments as milestones as the master branch is considered active development.

```yaml
  flutter_zoom_plugin:
      git:
        url: git://github.com/decodedhealth/flutter_zoom_plugin.git
        ref: 0.0.8
```

Please use `master` for Apple app store build deployments. 

```yaml
  flutter_zoom_plugin:
      git:
        url: git://github.com/decodedhealth/flutter_zoom_plugin.git
        ref: master
```


### iOS

Add two rows to the `ios/Runner/Info.plist`:

- one with the key `Privacy - Camera Usage Description` and a usage description.
- and one with the key `Privacy - Microphone Usage Description` and a usage description.

Or in text format add the key:

```xml
<key>NSCameraUsageDescription</key>
<string>Need to use the camera for call</string>
<key>NSMicrophoneUsageDescription</key>
<string>Need to use the microphone for call</string>
```

**NOTE for testing on the iOS simulator**

If you want to use the iOS Simulator to test your app, you will need to ensure you have the iOS Dev Zoom SDK as a dependency. 

To use the Dev Zoom SDK, run the following
```shell script
flutter pub run flutter_zoom_plugin:unzip_zoom_sdk dev
```
    
To switch back to the normal Zoom SDK, simply run

```shell script
flutter pub run flutter_zoom_plugin:unzip_zoom_sdk
```

### Android

Change the minimum Android sdk version to at the minimum 21 in your `android/app/build.gradle` file.

```
minSdkVersion 21
```

Add the zoom proguard content to your android project: https://github.com/zoom/zoom-sdk-android/blob/master/proguard.cfg

## Examples

### Meeting status

There are 2 ways to obtains the Zoom meeting status
- Listen to Zoom Status Event stream, or
- Polling the Zoom status using a `Timer`


The plugin emits the following Zoom meeting events:

For iOS:
- `MEETING_STATUS_IDLE`
- `MEETING_STATUS_CONNECTING`
- `MEETING_STATUS_INMEETING`
- `MEETING_STATUS_WEBINAR_PROMOTE`
- `MEETING_STATUS_WEBINAR_DEPROMOTE`
- `MEETING_STATUS_UNKNOWN`

For Android:
- `MEETING_STATUS_IDLE`
- `MEETING_STATUS_CONNECTING`
- `MEETING_STATUS_INMEETING`
- `MEETING_STATUS_WEBINAR_PROMOTE`
- `MEETING_STATUS_WEBINAR_DEPROMOTE`
- `MEETING_STATUS_UNKNOWN`
- `MEETING_STATUS_DISCONNECTING`
- `MEETING_STATUS_FAILED`
- `MEETING_STATUS_IN_WAITING_ROOM`
- `MEETING_STATUS_RECONNECTING`
- `MEETING_STATUS_WAITINGFORHOST`

### Join Meeting

```dart
class MeetingWidget extends StatelessWidget {

  ZoomOptions zoomOptions;
  ZoomMeetingOptions meetingOptions;

  Timer timer;

  MeetingWidget({Key key, meetingId, meetingPassword}) : super(key: key) {
    // Setting up the Zoom credentials
    this.zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: "appKey", // Replace with with key got from the Zoom Marketplace
      appSecret: "appSecret", // Replace with with secret got from the Zoom Marketplace
    );

    // Setting Zoom meeting options (default to false if not set)
    this.meetingOptions = new ZoomMeetingOptions(
        userId: 'example',
        meetingId: meetingId,
        meetingPassword: meetingPassword,
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        noAudio: "false",
        noDisconnectAudio: "false"
    );
  }

  bool _isMeetingEnded(String status) {
    var result = false;

    if (Platform.isAndroid)
      result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
    else
      result = status == "MEETING_STATUS_IDLE";

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Loading meeting '),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ZoomView(onViewCreated: (controller) {

          print("Created the view");

          controller.initZoom(this.zoomOptions)
              .then((results) {

            print("initialised");
            print(results);

            if(results[0] == 0) {

              // Listening on the Zoom status stream (1)
              controller.zoomStatusEvents.listen((status) {

                print("Meeting Status Stream: " + status[0] + " - " + status[1]);

                if (_isMeetingEnded(status[0])) {
                  Navigator.pop(context);
                  timer?.cancel();
                }
              });

              print("listen on event channel");

              controller.joinMeeting(this.meetingOptions)
                  .then((joinMeetingResult) {

                    // Polling the Zoom status (2)
                timer = Timer.periodic(new Duration(seconds: 2), (timer) {
                  controller.meetingStatus(this.meetingOptions.meetingId)
                      .then((status) {
                    print("Meeting Status Polling: " + status[0] + " - " + status[1]);
                  });
                });
              });
            }

          }).catchError((error) {
            print(error);
          });
        })
      ),
    );
  }
}
```

### Start a Meeting - Non-login user

You need to obtain the User Token and Zoom Access Token (ZAK) in order to start meetings for a user. They are unique authentication tokens required to host a meeting on behalf of another user.

Example of getting User Token and ZAK [here](https://marketplace.zoom.us/docs/sdk/native-sdks/android/mastering-zoom-sdk/start-join-meeting/api-user/authentication)

More info about the User Token and Zoom Access Token [here](https://marketplace.zoom.us/docs/sdk/native-sdks/credentials).

In order to run the example app:

1. Create an JWT app to get a JWT token using the instructions [here](https://marketplace.zoom.us/docs/guides/build/jwt-app).
2. Create a meeting (with a host of course) then get the Meeting ID (can be a 10 or 11-digit number).
3. Use the Zoom API to obtain the tokens from the host.

    ```shell script
    # User token
    curl --location --request GET 'https://api.zoom.us/v2/users/<zoom_user_id>/token?type=token&access_token=<jwt_token>'
    
    # Access token
    curl --location --request GET 'https://api.zoom.us/v2/users/<zoom_user_id>/token?type=zak&access_token=<jwt_token>'
    ```
    
    **Note for obtaining tokens**: 
    
    The user must log in using their email and password to get the user token. If a user signed into Zoom using Google or Facebook, a null value will be returned for the token.

4. Pass the meeting ID and tokens to the plugin.

```dart
class StartMeetingWidget extends StatelessWidget {

  ZoomOptions zoomOptions;
  ZoomMeetingOptions meetingOptions;

  Timer timer;

  StartMeetingWidget({Key key, meetingId}) : super(key: key) {
    this.zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: "appKey", // Replace with with key got from the Zoom Marketplace
      appSecret: "appSecret", // Replace with with key got from the Zoom Marketplace
    );
    this.meetingOptions = new ZoomMeetingOptions(
        userId: '<zoom_user_id>', // Replace with the user email or Zoom user ID
        displayName: 'Example display Name',
        meetingId: meetingId, 
        zoomAccessToken: "<zak_token>", // Replace with the token obtained from the Zoom API
        zoomToken: "<zoom_token>", // Replace with the token obtained from the Zoom API
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        noAudio: "false",
        noDisconnectAudio: "false"
    );
  }

  bool _isMeetingEnded(String status) {
    var result = false;

    if (Platform.isAndroid)
      result = status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
    else
      result = status == "MEETING_STATUS_IDLE";

    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
          title: Text('Loading meeting '),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ZoomView(onViewCreated: (controller) {

          print("Created the view");

          controller.initZoom(this.zoomOptions)
              .then((results) {

            print("initialised");
            print(results);

            if(results[0] == 0) {

              controller.zoomStatusEvents.listen((status) {
                print("Meeting Status Stream: " + status[0] + " - " + status[1]);
                if (_isMeetingEnded(status[0])) {
                  Navigator.pop(context);
                  timer?.cancel();
                }
              });

              print("listen on event channel");

              controller.startMeeting(this.meetingOptions)
                  .then((joinMeetingResult) {

                timer = Timer.periodic(new Duration(seconds: 2), (timer) {
                  controller.meetingStatus(this.meetingOptions.meetingId)
                      .then((status) {
                    print("Meeting Status Polling: " + status[0] + " - " + status[1]);
                  });
                });

              });
            }

          }).catchError((error) {

            print("Error");
            print(error);
          });
        })
      ),
    );
  }
}
```
