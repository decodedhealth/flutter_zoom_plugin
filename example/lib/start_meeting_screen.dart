import 'dart:async';
import 'dart:io';

import 'package:flutter_zoom_plugin/zoom_view.dart';
import 'package:flutter_zoom_plugin/zoom_options.dart';

import 'package:flutter/material.dart';

class StartMeetingWidget extends StatelessWidget {

  ZoomOptions zoomOptions;
  ZoomMeetingOptions meetingOptions;

  Timer timer;

  StartMeetingWidget({Key key, meetingId}) : super(key: key) {
    this.zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      jwtToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBLZXkiOiJ6OGphNWtDUldJUDBYQVJpUzU5MjJBczN3R3VXbGdMd0VwTmciLCJpYXQiOjE2MTc1OTE1NzEsImV4cCI6MTkzMzA5NTU3MSwidG9rZW5FeHAiOjE5MzMwOTU1NzF9.a4xWGF5DVsxqm2kbn2-npzQbJ5_GBvkO30VEnzyUuqk",
    );
    this.meetingOptions = new ZoomMeetingOptions(
        userId: 'Y174389107@gmail.com',
        displayName: 'Example display Name',
        meetingId: meetingId,
        zoomAccessToken: "eyJ6bV9za20iOiJ6bV9vMm0iLCJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJjbGllbnQiLCJ1aWQiOiJCZTlpeDg0LVJyR0Q2VDF5Y21hNUVBIiwiaXNzIjoid2ViIiwic3R5IjoxMDAsIndjZCI6InVzMDUiLCJjbHQiOjAsInN0ayI6IktGRS1vSlJPUVVtNUVFZzRiRmJSSXhvMVNoRVBYT1R0YkpIbXo0R2Y5bHMuQmdZZ1ZWQndVWFpoZVUxd2NXRktUbFo2TTNZemJ6TnBWVFozYnpOSlRETXpiMFpBWmpOaE1UY3daVEpsTkRRM05qYzJZVE15TnpZMFpUWTVObUUxTWpNeE1qUXlZVFl5TURZMk9HTTJNVFUzTURZeE56ZzFNRFZsTVdVeE4yUmhNV0k1WmdBZ1VtbExRemcyUzFwRk1ISnBPR3RtVW1seFYxSnlWemxRV1VabmVIbFNTRmNBQkhWek1EVUFBQUY0b0FWZmNRQVNkUUFBQUEiLCJleHAiOjE2MTc1OTk2MDksImlhdCI6MTYxNzU5MjQwOSwiYWlkIjoiNGV5cGViaVRSZmFSang4dGx3dDFBUSIsImNpZCI6IiJ9.o26-wTAsF5O8tOBiIXZqnFQXbNvUfwewLYzdYW3_Cqo",
        zoomToken: "<user_token>",
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true",
        noAudio: "false",
        noDisconnectAudio: "false"
    );
  }

  bool _isMeetingEnded(String status) {
    if (Platform.isAndroid)
        return status == "MEETING_STATUS_DISCONNECTING" || status == "MEETING_STATUS_FAILED";
    return status == "MEETING_STATUS_ENDED";
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
