
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
  String disableDialIn;
  String disableDrive;
  String disableInvite;
  String disableShare;

  ZoomMeetingOptions({
    this.userId,
    this.meetingId,
    this.meetingPassword,
    this.disableDialIn,
    this.disableDrive,
    this.disableInvite,
    this.disableShare
  });
}
