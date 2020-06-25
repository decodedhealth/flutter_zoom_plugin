import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_zoom_plugin/zoom_options.dart';

typedef void ZoomViewCreatedCallback(ZoomViewController controller);

class ZoomView extends StatefulWidget {
  const ZoomView({
    Key key,
    this.zoomOptions,
    this.meetingOptions,
    this.onViewCreated,
  }) : super(key: key);

  final ZoomViewCreatedCallback onViewCreated;
  final ZoomOptions zoomOptions;
  final ZoomMeetingOptions meetingOptions;

  @override
  State<StatefulWidget> createState() => _ZoomViewState();
}

class _ZoomViewState extends State<ZoomView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'flutter_zoom_plugin',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'flutter_zoom_plugin',
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the flutter_zoom_plugin plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onViewCreated == null) {
      return;
    }

    var controller = new ZoomViewController._(id);
    widget.onViewCreated(controller);
  }
}

class ZoomViewController {
  ZoomViewController._(int id)
      : _methodChannel =
            new MethodChannel('com.decodedhealth/flutter_zoom_plugin'),
        _zoomStatusEventChannel =
            new EventChannel("com.decodedhealth/zoom_event_stream");

  final MethodChannel _methodChannel;
  final EventChannel _zoomStatusEventChannel;

  Future<List> initZoom(ZoomOptions options) async {
    assert(options != null);

    var optionMap = new Map<String, String>();
    optionMap.putIfAbsent("appKey", () => options.appKey);
    optionMap.putIfAbsent("appSecret", () => options.appSecret);
    optionMap.putIfAbsent("domain", () => options.domain);

    return _methodChannel.invokeMethod('init', optionMap);
  }

  Future<bool> startMeeting(ZoomMeetingOptions options) async {
    assert(options != null);
    var optionMap = new Map<String, String>();
    optionMap.putIfAbsent("userId", () => options.userId);
    optionMap.putIfAbsent("displayName", () => options.displayName);
    optionMap.putIfAbsent("meetingId", () => options.meetingId);
    optionMap.putIfAbsent("meetingPassword", () => options.meetingPassword);
    optionMap.putIfAbsent("zoomToken", () => options.zoomToken);
    optionMap.putIfAbsent("zoomAccessToken", () => options.zoomAccessToken);
    optionMap.putIfAbsent("disableDialIn", () => options.disableDialIn);
    optionMap.putIfAbsent("disableDrive", () => options.disableDrive);
    optionMap.putIfAbsent("disableInvite", () => options.disableInvite);
    optionMap.putIfAbsent("disableShare", () => options.disableShare);
    optionMap.putIfAbsent("noDisconnectAudio", () => options.noDisconnectAudio);
    optionMap.putIfAbsent("noAudio", () => options.noAudio);

    return _methodChannel.invokeMethod('start', optionMap);
  }

  Future<bool> joinMeeting(ZoomMeetingOptions options) async {
    assert(options != null);
    var optionMap = new Map<String, String>();
    optionMap.putIfAbsent("userId", () => options.userId);
    optionMap.putIfAbsent("meetingId", () => options.meetingId);
    optionMap.putIfAbsent("meetingPassword", () => options.meetingPassword);
    optionMap.putIfAbsent("disableDialIn", () => options.disableDialIn);
    optionMap.putIfAbsent("disableDrive", () => options.disableDrive);
    optionMap.putIfAbsent("disableInvite", () => options.disableInvite);
    optionMap.putIfAbsent("disableShare", () => options.disableShare);
    optionMap.putIfAbsent("noDisconnectAudio", () => options.noDisconnectAudio);
    optionMap.putIfAbsent("noAudio", () => options.noAudio);

    return _methodChannel.invokeMethod('join', optionMap);
  }

  Future<List> meetingStatus(String meetingId) async {
    assert(meetingId != null);

    var optionMap = new Map<String, String>();
    optionMap.putIfAbsent("meetingId", () => meetingId);

    return _methodChannel.invokeMethod('meeting_status', optionMap);
  }

  Stream<dynamic> get zoomStatusEvents {
    return _zoomStatusEventChannel.receiveBroadcastStream();
  }
}
