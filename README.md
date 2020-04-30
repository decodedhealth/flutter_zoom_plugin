# Flutter Zoom Plugin

A Flutter plugin for the Zoom SDK.

*Note*: This plugin is still under active development, and some Zoom features might not be available yet. We are working to add more features.
Feedback and Pull Requests are always welcome.

## Zoom SDK Versions

Android: https://github.com/zoom/zoom-sdk-android/releases/tag/v4.6.15086.0209
 
iOS: https://github.com/zoom/zoom-sdk-ios/releases/tag/v4.6.15084.0206

## Installation

First, add `flutter_zoom_plugin` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

Use the git tags for deployments as milestones as the master branch is considered active development.

```yaml
    flutter_zoom_plugin:
       git:
         url: git://github.com/decodedhealth/flutter_zoom_plugin.git
         ref: 0.0.4
```

Please use `master` for Apple app store build deployments. To test on an iOS simulator please use branch `master_dev`

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