
class ZoomOptions {

  String domain;
  String appKey;
  String appSecret;

  ZoomOptions({
    this.domain,
    this.appKey,
    this.appSecret,
  });
}

class ZoomMeetingOptions {

  String userId;
  String meetingId;
  String meetingPassword;

  ZoomMeetingOptions({
    this.userId,
    this.meetingId,
    this.meetingPassword,
  });
}
