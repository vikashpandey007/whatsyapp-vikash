import 'package:firebase_database/firebase_database.dart';

class ChatModel {
  String name;
  String icon;
  bool isGroup;
  String time;
  String currentMessage;
  String status;
  bool select = false;
  int id;
  ChatModel({
    required this.name,
    required this.icon,
    required this.isGroup,
    required this.time,
    required this.currentMessage,
    required this.status,
    this.select = false,
    required this.id,
  });
}

class Users {
  String? id;
  String? email;
  String? name;
  String? phone;

  Users({this.id, this.email, this.name, this.phone});


  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    email = (dataSnapshot.child("email").value.toString());
    name =  (dataSnapshot.child("name").value.toString());
    phone =  (dataSnapshot.child("phone").value.toString());
  }
}
