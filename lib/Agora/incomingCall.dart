import 'package:agora_rtm/agora_rtm.dart';

class AgoraRTMManager {
  AgoraRtmClient? _rtmClient;
  AgoraRtmCallManager? _callManager;
  LocalInvitation? _localInvitation;
  RemoteInvitation? _remoteInvitation;

  Future<void> initializeRTM(String appId, String userId) async {
    _rtmClient = await AgoraRtmClient.createInstance(appId);
    await _rtmClient?.login(null, userId);
    _callManager = await _rtmClient?.getRtmCallManager();
    setupCallEventHandlers();
  }

  void setupCallEventHandlers() {
    _callManager?.onLocalInvitationReceivedByPeer =
        (AgoraRtmLocalInvitation invitation) {
      // Handle local invitation received by peer
    };

    _callManager?.onLocalInvitationAccepted =
        (AgoraRtmLocalInvitation invitation, String response) {
      // Handle local invitation accepted
    };

    // Add more event handlers as needed
  }

  Future<void> sendCallInvitation(String peerId, String channelId) async {
    LocalInvitation? invitation =
        await _rtmClient?.getRtmCallManager().createLocalInvitation(peerId);

    invitation!.content = channelId;
    await _callManager?.sendLocalInvitation(invitation);
    _callManager?.onRemoteInvitationReceived =
        (RemoteInvitation remoteInvitation) {
      print(
          'Remote invitation received by peer: ${remoteInvitation.callerId}, content: ${remoteInvitation.content}');
      // setState(() {
      //   _remoteInvitation = remoteInvitation;
      // });
    };
  }

  Future<void> acceptCallInvitation(AgoraRtmRemoteInvitation invitation) async {
    await _callManager?.acceptRemoteInvitation(invitation);
  }

  Future<void> refuseCallInvitation(AgoraRtmRemoteInvitation invitation) async {
    await _callManager?.refuseRemoteInvitation(invitation);
  }

  Future<void> cancelCallInvitation(AgoraRtmLocalInvitation invitation) async {
    await _callManager?.cancelLocalInvitation(invitation);
  }

  void _acceptRemoteInvitation() async {
    if (_remoteInvitation == null) {
      print('No remote invitation');
      return;
    }

    try {
      await _rtmClient
          ?.getRtmCallManager()
          .acceptRemoteInvitation(_remoteInvitation!);
      print('Accept remote invitation success');
    } catch (errorCode) {
      print('Accept remote invitation error: $errorCode');
    }
  }

  Future<void> logout() async {
    await _rtmClient?.logout();
  }

  void dispose() {
    _rtmClient?.destroy();
  }
}
