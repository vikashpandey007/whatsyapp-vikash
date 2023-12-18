import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CallInvitation extends StatefulWidget {
  const CallInvitation({Key? key}) : super(key: key);

  @override
  CallInvitationState createState() => CallInvitationState();
}

class CallInvitationState extends State<CallInvitation> {
  bool _isLogin = false;
  bool _isInChannel = false;
  LocalInvitation? _localInvitation;
  RemoteInvitation? _remoteInvitation;

  final _userNameController = TextEditingController();
  final _peerUserIdController = TextEditingController();
  final _peerMessageController = TextEditingController();
  final _invitationController = TextEditingController();
  final _channelNameController = TextEditingController();
  final _channelMessageController = TextEditingController();

  final _infoStrings = <String>[];

  AgoraRtmClient? _client;
  AgoraRtmChannel? _channel;

  @override
  void initState() {
    super.initState();
    _createClient();
  }

  @override
  void dispose() {
    _client?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Agora Real Time Message'),
          ),
          body: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildLogin(),
                _buildQueryOnlineStatus(),
                _buildSubscribeOnlineStatus(),
                _buildSendPeerMessage(),
                _buildLocalInvitation(),
                _buildRemoteInvitation(),
                _buildJoinChannel(),
                _buildGetMembers(),
                _buildSendChannelMessage(),
                _buildInfoList(),
              ],
            ),
          )),
    );
  }

  void _createClient() async {
    _client =
        await AgoraRtmClient.createInstance('a2c555418b0d49a9984115197de969fe');
    print(await AgoraRtmClient.getSdkVersion());
    await _client?.setParameters('{"rtm.log_filter": 15}');
    await _client?.setLogFile('');
    await _client?.setLogFilter(RtmLogFilter.info);
    await _client?.setLogFileSize(10240);
    _client?.onError = (error) {
      print("Client error: $error");
    };
    _client?.onConnectionStateChanged2 =
        (RtmConnectionState state, RtmConnectionChangeReason reason) {
      print('Connection state changed: $state, reason: $reason');
      if (state == RtmConnectionState.aborted) {
        _client?.logout();
        print('Logout');
        setState(() {
          _isLogin = false;
        });
      }
    };

    _client?.onMessageReceived = (RtmMessage message, String peerId) {
      print("Peer msg: $peerId, msg: ${message.messageType} ${message.text}");
    };
    _client?.onTokenExpired = () {
      print("Token expired");
    };
    _client?.onTokenPrivilegeWillExpire = () {
      print("Token privilege will expire");
    };
    _client?.onPeersOnlineStatusChanged =
        (Map<String, RtmPeerOnlineState> peersStatus) {
      print("Peers online status changed ${peersStatus.toString()}");
    };

    var callManager = _client?.getRtmCallManager();
    callManager?.onError = (error) {
      print('Call manager error: $error');
    };
    callManager?.onLocalInvitationReceivedByPeer =
        (LocalInvitation localInvitation) {
      print(
          'Local invitation received by peer: ${localInvitation.calleeId}, content: ${localInvitation.content}');
    };
    callManager?.onLocalInvitationAccepted =
        (LocalInvitation localInvitation, String response) {
      print(
          'Local invitation accepted by peer: ${localInvitation.calleeId}, response: $response');
      setState(() {
        _localInvitation = null;
      });
    };
    callManager?.onLocalInvitationRefused =
        (LocalInvitation localInvitation, String response) {
      print(
          'Local invitation refused by peer: ${localInvitation.calleeId}, response: $response');
      setState(() {
        _localInvitation = null;
      });
    };
    callManager?.onLocalInvitationCanceled = (LocalInvitation localInvitation) {
      print(
          'Local invitation canceled: ${localInvitation.calleeId}, content: ${localInvitation.content}');
      setState(() {
        _localInvitation = null;
      });
    };
    callManager?.onLocalInvitationFailure =
        (LocalInvitation localInvitation, int errorCode) {
      print(
          'Local invitation failure: ${localInvitation.calleeId}, errorCode: $errorCode');
      setState(() {
        _localInvitation = null;
      });
    };
    callManager?.onRemoteInvitationReceived =
        (RemoteInvitation remoteInvitation) {
      print(
          'Remote invitation received by peer: ${remoteInvitation.callerId}, content: ${remoteInvitation.content}');
      setState(() {
        _remoteInvitation = remoteInvitation;
      });
    };
    callManager?.onRemoteInvitationAccepted =
        (RemoteInvitation remoteInvitation) {
      print(
          'Remote invitation accepted by peer: ${remoteInvitation.callerId}, content: ${remoteInvitation.content}');
      setState(() {
        _remoteInvitation = null;
      });
    };
    callManager?.onRemoteInvitationRefused =
        (RemoteInvitation remoteInvitation) {
      print(
          'Remote invitation refused by peer: ${remoteInvitation.callerId}, content: ${remoteInvitation.content}');
      setState(() {
        _remoteInvitation = null;
      });
    };
    callManager?.onRemoteInvitationCanceled =
        (RemoteInvitation remoteInvitation) {
      print(
          'Remote invitation canceled: ${remoteInvitation.callerId}, content: ${remoteInvitation.content}');
      setState(() {
        _remoteInvitation = null;
      });
    };
    callManager?.onRemoteInvitationFailure =
        (RemoteInvitation remoteInvitation, int errorCode) {
      print(
          'Remote invitation failure: ${remoteInvitation.callerId}, errorCode: $errorCode');
      setState(() {
        _remoteInvitation = null;
      });
    };
  }

  ///

  Future<AgoraRtmChannel?> _createChannel(String name) async {
    AgoraRtmChannel? channel = await _client?.createChannel(name);
    if (channel != null) {
      channel.onError = (error) {
        print("Channel error: $error");
      };
      channel.onMemberCountUpdated = (int memberCount) {
        print("Member count updated: $memberCount");
      };
      channel.onAttributesUpdated = (List<RtmChannelAttribute> attributes) {
        print("Channel attributes updated: ${attributes.toString()}");
      };
      channel.onMessageReceived =
          (RtmMessage message, RtmChannelMember member) {
        print(
            "Channel msg: ${member.userId}, msg: ${message.messageType} ${message.text}");
      };
      channel.onMemberJoined = (RtmChannelMember member) {
        print('Member joined: ${member.userId}, channel: ${member.channelId}');
      };
      channel.onMemberLeft = (RtmChannelMember member) {
        print('Member left: ${member.userId}, channel: ${member.channelId}');
      };
    }
    return channel;
  }

  static TextStyle textStyle =
      const TextStyle(fontSize: 18, color: Colors.blue);

  Widget _buildLogin() {
    return Row(children: <Widget>[
      _isLogin
          ? Expanded(
              child: Text('User Id: ${_userNameController.text}',
                  style: textStyle))
          : Expanded(
              child: TextField(
                  controller: _userNameController,
                  decoration:
                      const InputDecoration(hintText: 'Input your user id'))),
      OutlinedButton(
        onPressed: _toggleLogin,
        child: Text(_isLogin ? 'Logout' : 'Login', style: textStyle),
      )
    ]);
  }

  Widget _buildQueryOnlineStatus() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      Expanded(
          child: TextField(
              controller: _peerUserIdController,
              decoration:
                  const InputDecoration(hintText: 'Input peer user id'))),
      OutlinedButton(
        onPressed: _toggleQueryPeersOnlineStatus,
        child: Text('Query Online', style: textStyle),
      )
    ]);
  }

  Widget _buildSubscribeOnlineStatus() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      OutlinedButton(
        onPressed: _subscribePeersOnlineStatus,
        child: Text('Subscribe Online', style: textStyle),
      ),
      OutlinedButton(
        onPressed: _unsubscribePeersOnlineStatus,
        child: Text('Unsubscribe Online', style: textStyle),
      )
    ]);
  }

  Widget _buildSendPeerMessage() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      Expanded(
          child: TextField(
              controller: _peerMessageController,
              decoration:
                  const InputDecoration(hintText: 'Input peer message'))),
      OutlinedButton(
        onPressed: _sendPeerMessage,
        child: Text('Send to Peer', style: textStyle),
      )
    ]);
  }

  Widget _buildLocalInvitation() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      Expanded(
          child: TextField(
              controller: _invitationController,
              decoration:
                  const InputDecoration(hintText: 'Input invitation content'))),
      OutlinedButton(
        onPressed: _toggleLocalInvitation,
        child: Text(
            '${_localInvitation == null ? 'Send' : 'Cancel'} local invitation',
            style: textStyle),
      )
    ]);
  }

  Widget _buildRemoteInvitation() {
    if (!_isLogin || _remoteInvitation == null) {
      return Container();
    }
    return Row(children: <Widget>[
      OutlinedButton(
        onPressed: _acceptRemoteInvitation,
        child: Text('accept remote invitation', style: textStyle),
      ),
      OutlinedButton(
        onPressed: _refuseRemoteInvitation,
        child: Text('refuse remote invitation', style: textStyle),
      )
    ]);
  }

  Widget _buildJoinChannel() {
    if (!_isLogin) {
      return Container();
    }
    return Row(children: <Widget>[
      _isInChannel
          ? Expanded(
              child: Text('Channel: ${_channelNameController.text}',
                  style: textStyle))
          : Expanded(
              child: TextField(
                  controller: _channelNameController,
                  decoration:
                      const InputDecoration(hintText: 'Input channel id'))),
      OutlinedButton(
        onPressed: _toggleJoinChannel,
        child: Text(_isInChannel ? 'Leave Channel' : 'Join Channel',
            style: textStyle),
      )
    ]);
  }

  Widget _buildSendChannelMessage() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Row(children: <Widget>[
      Expanded(
          child: TextField(
              controller: _channelMessageController,
              decoration:
                  const InputDecoration(hintText: 'Input channel message'))),
      OutlinedButton(
        onPressed: _sendChannelMessage,
        child: Text('Send to Channel', style: textStyle),
      )
    ]);
  }

  Widget _buildGetMembers() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Row(children: <Widget>[
      OutlinedButton(
        onPressed: _getMembers,
        child: Text('Get Members in Channel', style: textStyle),
      ),
      OutlinedButton(
        onPressed: _getMemberCount,
        child: Text('Get Member count in Channel', style: textStyle),
      )
    ]);
  }

  Widget _buildInfoList() {
    return Expanded(
        child: ListView.builder(
      itemExtent: 24,
      itemBuilder: (context, i) {
        return ListTile(
          contentPadding: const EdgeInsets.all(0.0),
          title: Text(_infoStrings[i]),
        );
      },
      itemCount: _infoStrings.length,
    ));
  }

  void _toggleLogin() async {
    if (_isLogin) {
      try {
        await _client?.logout();
        print('Logout success');

        setState(() {
          _isLogin = false;
          _isInChannel = false;
        });
      } catch (errorCode) {
        print('Logout error: $errorCode');
      }
    } else {
      String userId = _userNameController.text;
      if (userId.isEmpty) {
        print('Please input your user id to login');
        return;
      }

      try {
        await _client?.login(null, userId);
        print('Login success: $userId');
        setState(() {
          _isLogin = true;
        });
      } catch (errorCode) {
        print('Login error: $errorCode');
      }
    }
  }

  void _toggleQueryPeersOnlineStatus() async {
    String peerUid = _peerUserIdController.text;
    if (peerUid.isEmpty) {
      try {
        List<String>? result = await _client?.queryPeersBySubscriptionOption(
            RtmPeerSubscriptionOption.onlineStatus);
        print('Query result: $result');
      } catch (errorCode) {
        print('Query error: $errorCode');
      }
    } else {
      try {
        Map<dynamic, dynamic>? result =
            await _client?.queryPeersOnlineStatus([peerUid]);
        print('Query result: $result');
      } catch (errorCode) {
        print('Query error: $errorCode');
      }
    }
  }

  void _subscribePeersOnlineStatus() async {
    String peerUid = _peerUserIdController.text;
    if (peerUid.isEmpty) {
      print('Please input peer user id to subscribe');
      return;
    }

    try {
      await _client?.subscribePeersOnlineStatus([peerUid]);
      print('Subscribe success');
    } catch (errorCode) {
      print('Subscribe error: $errorCode');
    }
  }

  void _unsubscribePeersOnlineStatus() async {
    String peerUid = _peerUserIdController.text;
    if (peerUid.isEmpty) {
      print('Please input peer user id to unsubscribe');
      return;
    }

    try {
      await _client?.unsubscribePeersOnlineStatus([peerUid]);
      print('Unsubscribe success');
    } catch (errorCode) {
      print('Unsubscribe error: $errorCode');
    }
  }

  void _sendPeerMessage() async {
    String peerUid = _peerUserIdController.text;
    if (peerUid.isEmpty) {
      print('Please input peer user id to send message');
      return;
    }

    String text = _peerMessageController.text;
    if (text.isEmpty) {
      print('Please input text to send');
      return;
    }

    try {
      RtmMessage? message = _client?.createTextMessage(text);
      if (message != null) {
        print(message.text);
        await _client?.sendMessageToPeer2(peerUid, message);
        print('Send peer message success');
      }
    } catch (errorCode) {
      print('Send peer message error: $errorCode');
    }
  }

  void _toggleLocalInvitation() async {
    String peerUid = _peerUserIdController.text;
    if (peerUid.isEmpty) {
      print('Please input peer user id to send invitation');
      return;
    }

    String text = _invitationController.text;
    if (text.isEmpty) {
      print('Please input content to send');
      return;
    }

    if (_localInvitation == null) {
      try {
        LocalInvitation? invitation =
            await _client?.getRtmCallManager().createLocalInvitation(peerUid);
        if (invitation != null) {
          invitation.content = text;
          print(invitation.content ?? '');
          await _client?.getRtmCallManager().sendLocalInvitation(invitation);
          setState(() {
            _localInvitation = invitation;
          });
          print('Send local invitation success');
        }
      } catch (errorCode) {
        print('Send local invitation error: $errorCode');
      }
    } else {
      try {
        await _client
            ?.getRtmCallManager()
            .cancelLocalInvitation(_localInvitation!);
        print('Cancel local invitation success');
      } catch (errorCode) {
        print('Cancel local invitation error: $errorCode');
      }
    }
  }

  void _acceptRemoteInvitation() async {
    if (_remoteInvitation == null) {
      print('No remote invitation');
      return;
    }

    try {
      await _client
          ?.getRtmCallManager()
          .acceptRemoteInvitation(_remoteInvitation!);
      print('Accept remote invitation success');
    } catch (errorCode) {
      print('Accept remote invitation error: $errorCode');
    }
  }

  void _refuseRemoteInvitation() async {
    if (_remoteInvitation == null) {
      print('No remote invitation');
      return;
    }

    try {
      await _client
          ?.getRtmCallManager()
          .refuseRemoteInvitation(_remoteInvitation!);
      print('Refuse remote invitation success');
    } catch (errorCode) {
      print('Refuse remote invitation error: $errorCode');
    }
  }

  void _toggleJoinChannel() async {
    if (_isInChannel) {
      try {
        await _channel?.leave();
        print('Leave channel success');
        await _channel?.release();
        _channelMessageController.clear();

        setState(() {
          _isInChannel = false;
        });
      } catch (errorCode) {
        print('Leave channel error: $errorCode');
      }
    } else {
      String channelId = _channelNameController.text;
      if (channelId.isEmpty) {
        print('Please input channel id to join');
        return;
      }

      try {
        _channel = await _createChannel(channelId);
        await _channel?.join();
        print('Join channel success');

        setState(() {
          _isInChannel = true;
        });
      } catch (errorCode) {
        print('Join channel error: $errorCode');
      }
    }
  }

  void _getMembers() async {
    try {
      List<RtmChannelMember>? members = await _channel?.getMembers();
      print('Members: ${members.toString()}');
    } catch (errorCode) {
      print('GetMembers failed: $errorCode');
    }
  }

  void _getMemberCount() async {
    String channelId = _channelNameController.text;
    if (channelId.isEmpty) {
      print('Please input channel id to get');
      return;
    }

    try {
      List<RtmChannelMemberCount>? members =
          await _client?.getChannelMemberCount([channelId]);
      print('Members: ${members.toString()}');
    } catch (errorCode) {
      print('GetMembers failed: $errorCode');
    }
  }

  void _sendChannelMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      print('Please input text to send');
      return;
    }

    try {
      RtmMessage? message =
          _client?.createRawMessage(Uint8List.fromList([]), text);
      if (message != null) {
        print(message.text);
        await _channel?.sendMessage2(message);
        print('Send channel message success');
      }
    } catch (errorCode) {
      print('Send channel message error: $errorCode');
    }
  }

  void print(String info) {
    debugPrint(info);
    setState(() {
      _infoStrings.insert(0, info);
    });
  }
}
