package com.decodedhealth.flutter_zoom_plugin_example;

import us.zoom.sdk.MeetingActivity;

public class FlutterMeetingActivity extends MeetingActivity {

    @Override
    public void onBackPressed() {
        super.onClickLeave();
    }
}
