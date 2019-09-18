package com.decodedhealth.flutter_zoom_plugin;

import android.content.Context;
import android.view.View;
import android.widget.TextView;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import us.zoom.sdk.JoinMeetingOptions;
import us.zoom.sdk.JoinMeetingParams;
import us.zoom.sdk.MeetingService;
import us.zoom.sdk.MeetingServiceListener;
import us.zoom.sdk.MeetingStatus;
import us.zoom.sdk.ZoomSDK;
import us.zoom.sdk.ZoomSDKAuthenticationListener;
import us.zoom.sdk.ZoomSDKInitializeListener;

public class ZoomView  implements PlatformView,
        MethodChannel.MethodCallHandler,
        MeetingServiceListener,
        ZoomSDKAuthenticationListener
{

    private final TextView textView;
    private final MethodChannel methodChannel;
    private final Context context;

    ZoomView(Context context, BinaryMessenger messenger, int id) {
        textView = new TextView(context);
        this.context = context;

        methodChannel = new MethodChannel(messenger, "flutter_zoom_plugin");
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public View getView() {
        return textView;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "init":
                init(methodCall, result);
                break;
            case "join":
                joinMeeting(methodCall, result);
                break;
            default:
                result.notImplemented();
        }

    }

    private void init(final MethodCall methodCall, final MethodChannel.Result result) {

        Map<String, String> options = methodCall.arguments();

        ZoomSDK zoomSDK = ZoomSDK.getInstance();

        if(zoomSDK.isInitialized()) {
            List<Integer> response = Arrays.asList(0, 0);
            result.success(response);
            return;
        }

        zoomSDK.initialize(
                context,
                options.get("appKey"),
                options.get("appSecret"),
                options.get("domain"),
                new ZoomSDKInitializeListener() {
                    @Override
                    public void onZoomSDKInitializeResult(int errorCode, int internalErrorCode) {

                        List<Integer> response = Arrays.asList(errorCode, internalErrorCode);
                        result.success(response);
                    }
                }
        );
    }

    private void joinMeeting(MethodCall methodCall, MethodChannel.Result result) {

        // Step 1: Get meeting number from input field.
        Map<String, String> options = methodCall.arguments();

        // Step 2: Get Zoom SDK instance.
        ZoomSDK zoomSDK = ZoomSDK.getInstance();

        // Check if the zoom SDK is initialized
        if(!zoomSDK.isInitialized()) {
            System.out.println("Not initialized!!!!!!");
            result.success(false);
            return;
        }

        // Step 3: Get meeting service from zoom SDK instance.
        MeetingService meetingService = zoomSDK.getMeetingService();

        // Step 4: Configure meeting options.
        JoinMeetingOptions opts = new JoinMeetingOptions();

        // Step 5: Setup join meeting parameters
        JoinMeetingParams params = new JoinMeetingParams();

        params.displayName = options.get("userId");
        params.meetingNo = options.get("meetingId");
        params.password = options.get("meetingPassword");

        // Step 6: Call meeting service to join meeting
        meetingService.joinMeetingWithParams(context, params, opts);

        result.success(true);
    }

    @Override
    public void dispose() {}


    @Override
    public void onMeetingStatusChanged(MeetingStatus meetingStatus, int errorCode, int internalErrorCode) {

    }

    @Override
    public void onZoomSDKLoginResult(long result) {

    }

    @Override
    public void onZoomSDKLogoutResult(long result) {

    }

    @Override
    public void onZoomIdentityExpired() {

    }
}