# Flutter Zoom Plugin

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A Flutter plugin for the Zoom SDK.

*Note*: This plugin is still under active development, and some Zoom features might not be available yet. We are working to add more features.
Feedback and Pull Requests are always welcome.

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
        ref: 0.0.5
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

If you want to test the iOS Simulator you will need to ensure you have the iOS dev sdk as a dependency. To do this you will need to
run the following command.

Steps to use the master_dev.

1. Run the following
    ```shell script
    flutter pub run bin/unzip_zoom_sdk dev
    ```
To switch back simply run

```shell script
flutter pub run bin/unzip_zoom_sdk dev
```

### Android

Change the minimum Android sdk version to at the minimum 21 in your `android/app/build.gradle` file.

```
minSdkVersion 21
```

## Example

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

                if (status[0] == "MEETING_STATUS_IDLE" ||
                    status[0] == "MEETING_STATUS_FAILED") {
                  Navigator.of(context).pop();
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

There are 2 ways to obtains the Zoom meeting status
- Listen to Zoom Status Event stream (1) or
- Polling the Zoom status using a `Timer` (2)


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
