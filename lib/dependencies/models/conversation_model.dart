import 'dart:io';

class Conversation {
  String id;
  String user1;
  String user2;
  String lastMessageText;
  String lastMessageTimestamp;
  int unreadCountUser;
  int unreadCountclient;
  File profilePicture;

  Conversation(
      {required this.id,
      required this.user1,
      required this.user2,
      required this.lastMessageText,
      required this.lastMessageTimestamp,
      required this.unreadCountUser,
      required this.unreadCountclient,
      required this.profilePicture});

  factory Conversation.fromMap(Map<dynamic, dynamic> map) {
    return Conversation(
      id: map['id'],
      user1: map['user'],
      user2: map['client'],
      lastMessageText: map['last_message_text'],
      lastMessageTimestamp: map['last_message_timestamp'],
      unreadCountUser: map['unread_count_user'],
      unreadCountclient: map['unread_count_client'],
      profilePicture: map['profile_picture'],
    );
  }
}
