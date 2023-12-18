import 'package:flutter/material.dart';

class SingleChatWidget extends StatelessWidget {
  //  String? chatMessage;
  //  String? chatTitle;
  Color? seenStatusColor;
  String? imageUrl;
  String lastMessageSenderId;
  String? lastMessageText;
  String? userid;

  SingleChatWidget({
    Key? key,
    //  required this.chatMessage,
    //  required this.chatTitle,
    required this.seenStatusColor,
    required this.imageUrl,
    required this.lastMessageSenderId,
    required this.lastMessageText,
    required this.userid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl!),
        ),
        Expanded(
          child: ListTile(
            title: Text('$userid',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Row(children: [
              Icon(
                seenStatusColor == Colors.blue ? Icons.done_all : Icons.done,
                size: 15,
                color: seenStatusColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    '$lastMessageText',
                    style: const TextStyle(overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
