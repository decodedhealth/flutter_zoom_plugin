import 'package:flutter_zoom_plugin/zoom_view.dart';
import 'package:flutter_zoom_plugin/zoom_options.dart';

import 'package:flutter/material.dart';

class MeetingWidget extends StatelessWidget {

  //TODO Implement event stream.
  //static const stream = const EventChannel("com.decodedhealth/zoom_event_stream");

  ZoomOptions zoomOptions;
  ZoomMeetingOptions meetingOptions;

  MeetingWidget({Key key, meetingId, meetingPassword}) : super(key: key) {
    this.zoomOptions = new ZoomOptions(
      domain: "zoom.us",
      appKey: "appKey",
      appSecret: "appSecret",
    );
    this.meetingOptions = new ZoomMeetingOptions(
        userId: 'example',
        meetingId: meetingId,
        meetingPassword: meetingPassword,
        disableDialIn: "true",
        disableDrive: "true",
        disableInvite: "true",
        disableShare: "true"
    );
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
              controller.joinMeeting(this.meetingOptions)
                .then((joinMeetingResult) {

                  controller.meetingStatus(this.meetingOptions.meetingId)
                    .then((status) {
                    print("Meeting Status: " + status[0] + " - " + status[1]);
                  });
                });
            }

          }).catchError((error) {

            print("Error");
            print(error);
          });
        }),
      ),
    );
  }


}
