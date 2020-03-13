package com.decodedhealth.flutter_zoom_plugin;

import java.util.Arrays;
import java.util.List;

import io.flutter.plugin.common.EventChannel;
import us.zoom.sdk.MeetingError;
import us.zoom.sdk.MeetingService;
import us.zoom.sdk.MeetingServiceListener;
import us.zoom.sdk.MeetingStatus;

/**
 * This class implements the handler for the Zoom meeting event in the flutter event channel
 */
public class StatusStreamHandler implements EventChannel.StreamHandler {
    private MeetingService meetingService;
    private MeetingServiceListener statusListener;

    public StatusStreamHandler(MeetingService meetingService) {
        this.meetingService = meetingService;
    }

    @Override
    public void onListen(Object arguments, final EventChannel.EventSink events) {
        statusListener = new MeetingServiceListener() {
            @Override
            public void onMeetingStatusChanged(MeetingStatus meetingStatus, int errorCode, int internalErrorCode) {

                if(meetingStatus == MeetingStatus.MEETING_STATUS_FAILED &&
                        errorCode == MeetingError.MEETING_ERROR_CLIENT_INCOMPATIBLE) {
                    events.success(Arrays.asList("MEETING_STATUS_UNKNOWN", "Version of ZoomSDK is too low"));
                    return;
                }

                events.success(getMeetingStatusMessage(meetingStatus));
            }
        };

        this.meetingService.addListener(statusListener);
    }

    @Override
    public void onCancel(Object arguments) {
        this.meetingService.removeListener(statusListener);

    }

    private List<String> getMeetingStatusMessage(MeetingStatus meetingStatus) {
        String[] message = new String[2];

        message[0] = meetingStatus != null ? meetingStatus.name() : "";

        switch (meetingStatus) {
            case MEETING_STATUS_CONNECTING:
                message[1] = "Connect to the meeting server.";
                break;
            case MEETING_STATUS_DISCONNECTING:
                message[1] = "Disconnect the meeting server, user leaves meeting.";
                break;
            case MEETING_STATUS_FAILED:
                message[1] = "Failed to connect the meeting server.";
                break;
            case MEETING_STATUS_IDLE:
                message[1] = "No meeting is running";
                break;
            case MEETING_STATUS_IN_WAITING_ROOM:
                message[1] = "Participants who join the meeting before the start are in the waiting room.";
                break;
            case MEETING_STATUS_INMEETING:
                message[1] = "Meeting is ready and in process.";
                break;
            case MEETING_STATUS_RECONNECTING:
                message[1] = "Reconnecting meeting server.";
                break;
            case MEETING_STATUS_UNKNOWN:
                message[1] = "Unknown status.";
                break;
            case MEETING_STATUS_WAITINGFORHOST:
                message[1] = "Waiting for the host to start the meeting.";
                break;
            case MEETING_STATUS_WEBINAR_DEPROMOTE:
                message[1] = "Demote the attendees from the panelist.";
                break;
            case MEETING_STATUS_WEBINAR_PROMOTE:
                message[1] = "Upgrade the attendees to panelist in webinar.";
                break;
            default:
                message[1] = "No status available.";
                break;
        }

        return Arrays.asList(message);
    }

}
