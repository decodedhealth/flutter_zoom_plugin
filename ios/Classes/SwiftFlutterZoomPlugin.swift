import Flutter
import UIKit
import MobileRTC

public class SwiftFlutterZoomPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let factory = ZoomViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "flutter_zoom_plugin")
    }
}


public class ZoomViewFactory: NSObject, FlutterPlatformViewFactory {
    
    private weak var messenger: (NSObjectProtocol & FlutterBinaryMessenger)?
    
    init(messenger: (NSObjectProtocol & FlutterBinaryMessenger)?) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(
        withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
    ) -> FlutterPlatformView {
        return ZoomView(frame, viewId: viewId, messenger: messenger, args: args)
    }
}

public class AuthenticationDelegate: NSObject, MobileRTCAuthDelegate {
    
    private var result: FlutterResult?
    
    
    public func onAuth(_ result: FlutterResult?) -> AuthenticationDelegate {
        self.result = result
        return self
    }
    
    
    public func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {

        if returnValue == MobileRTCAuthError_Success {
            self.result?([0, 0])
        } else {
            self.result?([1, 0])
        }
        
        self.result = nil
    }
    
    public func onMobileRTCLoginReturn(_ returnValue: Int) {
        
    }
    
    public func onMobileRTCLogoutReturn(_ returnValue: Int) {
        
    }
    
    public func getAuthErrorMessage(_ errorCode: MobileRTCAuthError) -> String {
        
        let message = ""
        
        // switch (errorCode) {
        //     case MobileRTCMeetError_Success:
        //         message = "Successfully start/join meeting."
        //         break
        //     case MobileRTCMeetError_NetworkError:
        //         message = "Network issue, please check your network connection."
        //         break
        //     case MobileRTCMeetError_ReconnectError:
        //         message = "Failed to reconnect to meeting."
        //         break
        //     case MobileRTCMeetError_MMRError:
        //         message = "MMR issue, please check mmr configruation."
        //         break
        //     case MobileRTCMeetError_PasswordError:
        //         message = "Meeting password incorrect."
        //         break
        //     case MobileRTCMeetError_SessionError:
        //         message = "Failed to create a session with our sever."
        //         break
        //     case MobileRTCMeetError_MeetingOver:
        //         message = "The meeting is over."
        //         break
        //     case MobileRTCMeetError_MeetingNotStart:
        //         message = "The meeting does not start."
        //         break
        //     case MobileRTCMeetError_MeetingNotExist:
        //         message = "The meeting does not exist."
        //         break
        //     case MobileRTCMeetError_MeetingUserFull:
        //         message = "The meeting has reached a maximum of participants."
        //         break
        //     case MobileRTCMeetError_MeetingClientIncompatible:
        //         message = "The Zoom SDK version is incompatible."
        //         break
        //     case MobileRTCMeetError_NoMMR:
        //         message = "No mmr is available at this point."
        //         break
        //     case MobileRTCMeetError_MeetingLocked:
        //         message = "The meeting is locked by the host."
        //         break
        //     case MobileRTCMeetError_MeetingRestricted:
        //         message = "The meeting is restricted."
        //         break
        //     case MobileRTCMeetError_MeetingRestrictedJBH:
        //         message = "The meeting does not allow join before host. Please try again later."
        //         break
        //     case MobileRTCMeetError_CannotEmitWebRequest:
        //         message = "Failed to send create meeting request to server."
        //         break
        //     case MobileRTCMeetError_CannotStartTokenExpire:
        //         message = "Failed to start meeting due to token exipred."
        //         break
        //     case MobileRTCMeetError_VideoError:
        //         message = "The user's video cannot work."
        //         break
        //     case MobileRTCMeetError_AudioAutoStartError:
        //         message = "The user's audio cannot auto start."
        //         break
        //     case MobileRTCMeetError_RegisterWebinarFull:
        //         message = "The webinar has reached its maximum allowed participants."
        //         break
        //     case MobileRTCMeetError_RegisterWebinarHostRegister:
        //         message = "Sign in to start the webinar."
        //         break
        //     case MobileRTCMeetError_RegisterWebinarPanelistRegister:
        //         message = "Join the webinar from the link"
        //         break
        //     case MobileRTCMeetError_RegisterWebinarDeniedEmail:
        //         message = "The host has denied your webinar registration."
        //         break
        //     case MobileRTCMeetError_RegisterWebinarEnforceLogin:
        //         message = "The webinar requires sign-in with specific account to join."
        //         break
        //     case MobileRTCMeetError_ZCCertificateChanged:
        //         message = "The certificate of ZC has been changed. Please contact Zoom for further support."
        //         break
        //     case MobileRTCMeetError_VanityNotExist:
        //         message = "The vanity does not exist"
        //         break
        //     case MobileRTCMeetError_JoinWebinarWithSameEmail:
        //         message = "The email address has already been register in this webinar."
        //         break
        //     case MobileRTCMeetError_WriteConfigFile:
        //         message = "Failed to write config file."
        //         break
        //     case MobileRTCMeetError_RemovedByHost:
        //         message = "You have been removed by the host."
        //         break
        //     case MobileRTCMeetError_InvalidArguments:
        //         message = "Invalid arguments."
        //         break
        //     case MobileRTCMeetError_InvalidUserType:
        //         message = "Invalid user type."
        //         break
        //     case MobileRTCMeetError_InAnotherMeeting:
        //         message = "Already in another ongoing meeting."
        //         break
        //     case MobileRTCMeetError_Unknown:
        //         message = "Unknown error."
        //         break
        //     default:
        //         message = "Unknown error."
        //         break
        // }
        return message
    }
}

public class ZoomView: NSObject, FlutterPlatformView, MobileRTCMeetingServiceDelegate, FlutterStreamHandler {
    let frame: CGRect
    let viewId: Int64
    var channel: FlutterMethodChannel
    var authenticationDelegate: AuthenticationDelegate
    
    var statusEventChannel: FlutterEventChannel
    var eventSink: FlutterEventSink?
    
    init(_ frame: CGRect, viewId: Int64, messenger: (NSObjectProtocol & FlutterBinaryMessenger)?, args: Any?) {
        self.frame = frame
        self.viewId = viewId
        self.channel = FlutterMethodChannel(name: "com.decodedhealth/flutter_zoom_plugin", binaryMessenger: messenger!)
        self.authenticationDelegate = AuthenticationDelegate()
        self.statusEventChannel = FlutterEventChannel(name: "com.decodedhealth/zoom_event_stream", binaryMessenger: messenger!)

        super.init()
        
        self.statusEventChannel.setStreamHandler(self)
        self.channel.setMethodCallHandler(self.onMethodCall)
    }
    
    public func view() -> UIView {
        
        let label = UILabel(frame: frame)
        label.text = "Zoom"
        return label
    }
    
    public func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        switch call.method {
        case "init":
            self.initZoom(call: call, result: result)
        case "join":
            self.joinMeeting(call: call, result: result)
        case "start":
            self.startMeeting(call: call, result: result)
        case "meeting_status":
            self.meetingStatus(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func initZoom(call: FlutterMethodCall, result: @escaping FlutterResult)  {
        
        let pluginBundle = Bundle(for: type(of: self))
        let pluginBundlePath = pluginBundle.bundlePath
        let arguments = call.arguments as! Dictionary<String, String>
        
        let context = MobileRTCSDKInitContext()
        context.domain = arguments["domain"]!
        context.enableLog = true
        context.bundleResPath = pluginBundlePath
        MobileRTC.shared().initialize(context)
        
        let auth = MobileRTC.shared().getAuthService()
        auth?.delegate = self.authenticationDelegate.onAuth(result)
        auth?.clientKey = arguments["appKey"]!
        auth?.clientSecret = arguments["appSecret"]!
        auth?.sdkAuth()
    }
    
    public func meetingStatus(call: FlutterMethodCall, result: FlutterResult) {
        
        let meetingService = MobileRTC.shared().getMeetingService()
        if meetingService != nil {
            
            let meetingState = meetingService?.getMeetingState()
            result(getStateMessage(meetingState))
        } else {
            result(["MEETING_STATUS_UNKNOWN", ""])
        }
    }
    
    public func joinMeeting(call: FlutterMethodCall, result: FlutterResult) {
        
        let meetingService = MobileRTC.shared().getMeetingService()
        let meetingSettings = MobileRTC.shared().getMeetingSettings()
        
        if meetingService != nil {
            
            let arguments = call.arguments as! Dictionary<String, String?>
            
            meetingSettings?.disableDriveMode(parseBoolean(data: arguments["disableDrive"]!, defaultValue: false))
            meetingSettings?.disableCall(in: parseBoolean(data: arguments["disableDialIn"]!, defaultValue: false))
            meetingSettings?.setAutoConnectInternetAudio(parseBoolean(data: arguments["noDisconnectAudio"]!, defaultValue: false))
            meetingSettings?.setMuteAudioWhenJoinMeeting(parseBoolean(data: arguments["noAudio"]!, defaultValue: false))
            meetingSettings?.meetingShareHidden = parseBoolean(data: arguments["disableShare"]!, defaultValue: false)
            meetingSettings?.meetingInviteHidden = parseBoolean(data: arguments["disableDrive"]!, defaultValue: false)
       
            var params = [
                kMeetingParam_Username: arguments["userId"]!!,
                kMeetingParam_MeetingNumber: arguments["meetingId"]!!
            ]
            
            let hasPassword = arguments["meetingPassword"]! != nil
            if hasPassword {
                params[kMeetingParam_MeetingPassword] = arguments["meetingPassword"]!!
            }
            
            let response = meetingService?.joinMeeting(with: params)
            
            if let response = response {
                print("Got response from join: \(response)")
            }
            result(true)
        } else {
            result(false)
        }
    }

    public func startMeeting(call: FlutterMethodCall, result: FlutterResult) {
        
        let meetingService = MobileRTC.shared().getMeetingService()
        let meetingSettings = MobileRTC.shared().getMeetingSettings()
        
        if meetingService != nil {
            
            let arguments = call.arguments as! Dictionary<String, String?>
            
            meetingSettings?.disableDriveMode(parseBoolean(data: arguments["disableDrive"]!, defaultValue: false))
            meetingSettings?.disableCall(in: parseBoolean(data: arguments["disableDialIn"]!, defaultValue: false))
            meetingSettings?.setAutoConnectInternetAudio(parseBoolean(data: arguments["noDisconnectAudio"]!, defaultValue: false))
            meetingSettings?.setMuteAudioWhenJoinMeeting(parseBoolean(data: arguments["noAudio"]!, defaultValue: false))
            meetingSettings?.meetingShareHidden = parseBoolean(data: arguments["disableShare"]!, defaultValue: false)
            meetingSettings?.meetingInviteHidden = parseBoolean(data: arguments["disableDrive"]!, defaultValue: false)

            let user: MobileRTCMeetingStartParam4WithoutLoginUser = MobileRTCMeetingStartParam4WithoutLoginUser.init()
            
            user.userType = MobileRTCUserType_APIUser
            user.meetingNumber = arguments["meetingId"]!!
            user.userName = arguments["displayName"]!!
            user.userToken = arguments["zoomToken"]!!
            user.userID = arguments["userId"]!!
            user.zak = arguments["zoomAccessToken"]!!

            let param: MobileRTCMeetingStartParam = user
            
            let response = meetingService?.startMeeting(with: param)
            
            if let response = response {
                print("Got response from start: \(response)")
            }
            result(true)
        } else {
            result(false)
        }
    }
    
    private func parseBoolean(data: String?, defaultValue: Bool) -> Bool {
        var result: Bool
        
        if let unwrappeData = data {
            result = NSString(string: unwrappeData).boolValue
        } else {
            result = defaultValue
        }
        return result
    }
    
    
    
    
    public func onMeetingError(_ error: MobileRTCMeetError, message: String?) {
        
    }
    
    public func getMeetErrorMessage(_ errorCode: MobileRTCMeetError) -> String {
        
        let message = ""
        // switch (errorCode) {
        //     case MobileRTCAuthError_Success:
        //         message = "Authentication success."
        //         break
        //     case MobileRTCAuthError_KeyOrSecretEmpty:
        //         message = "SDK key or secret is empty."
        //         break
        //     case MobileRTCAuthError_KeyOrSecretWrong:
        //         message = "SDK key or secret is wrong."
        //         break
        //     case MobileRTCAuthError_AccountNotSupport:
        //         message = "Your account does not support SDK."
        //         break
        //     case MobileRTCAuthError_AccountNotEnableSDK:
        //         message = "Your account does not support SDK."
        //         break
        //     case MobileRTCAuthError_Unknown:
        //         message = "Unknown error.Please try again."
        //         break
        //     default:
        //         message = "Unknown error.Please try again."
        //         break
        // }
        return message
    }
    
    public func onMeetingStateChange(_ state: MobileRTCMeetingState) {
        
        guard let eventSink = eventSink else {
            return
        }
        
        eventSink(getStateMessage(state))
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        let meetingService = MobileRTC.shared().getMeetingService()
        if meetingService == nil {
            return FlutterError(code: "Zoom SDK error", message: "ZoomSDK is not initialized", details: nil)
        }
        meetingService?.delegate = self
        
        return nil
    }
     
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    private func getStateMessage(_ state: MobileRTCMeetingState?) -> [String] {
        
        var message: [String]
        
        switch state {
        case MobileRTCMeetingState_Idle:
            message = ["MEETING_STATUS_IDLE", "No meeting is running"]
            break
        case MobileRTCMeetingState_Connecting:
            message = ["MEETING_STATUS_CONNECTING", "Connect to the meeting server"]
            break
        case MobileRTCMeetingState_InMeeting:
            message = ["MEETING_STATUS_INMEETING", "Meeting is ready and in process"]
            break
        case MobileRTCMeetingState_WebinarPromote:
            message = ["MEETING_STATUS_WEBINAR_PROMOTE", "Upgrade the attendees to panelist in webinar"]
            break
        case MobileRTCMeetingState_WebinarDePromote:
            message = ["MEETING_STATUS_WEBINAR_DEPROMOTE", "Demote the attendees from the panelist"]
            break
        default:
            message = ["MEETING_STATUS_UNKNOWN", "Unknown error"]
        }
        
        return message
    }
    
}
