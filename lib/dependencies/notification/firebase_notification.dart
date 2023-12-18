
import 'package:WhatsYapp/routes/screen_chat_room.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'dart:io' as io;

class LocalNotificationservice {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initNotification(context, RemoteMessage message,client_ref,userPhoneNumber) async {
    //android
    final AndroidInitializationSettings initializationSettingsandroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
// IOs
    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
      onDidReceiveLocalNotification: (id, title, body, payload) {
        handledMessages(context, message,client_ref,userPhoneNumber);
      },
    );
    //InitializationSettings

    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsandroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (io.Platform.isAndroid) {
          handledMessages(context, message,client_ref,userPhoneNumber);
        }
      },
    );
  }

  void display(RemoteMessage message) async {
    try {
      if (message.notification?.android?.imageUrl != "" &&
          message.notification?.android?.imageUrl != null) {
        await showImageNotification(message);
      } else {
        showExpandableNotification(message);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  void showExpandableNotification(RemoteMessage message) async {
   
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    //dev.log("pall  ${message.notification?.android?.imageUrl}");
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('com.tme.whatsyapp', 'whatsyApp',
            importance: Importance.max,
            priority: Priority.high,
            icon: "@mipmap/ic_launcher",
            styleInformation: BigTextStyleInformation(
                '${message.notification!.body}',
                htmlFormatBigText: true));

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      id,
      message.notification!.title,
      message.notification!.body!.length > 40
          ? "${message.notification?.body?.substring(0, 40)} ..."
          : message.notification!.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName.png';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  showImageNotification(RemoteMessage message) async {
    final String largeIconPath = await downloadAndSaveFile(
        '${message.notification?.android?.imageUrl}', 'largeIcon');
    final String bigPicturePath = await downloadAndSaveFile(
        '${message.notification?.android?.imageUrl}', 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
            contentTitle: message.notification!.title,
            htmlFormatContentTitle: true,
            summaryText: message.notification!.body,
            htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('com.tme.whatsyapp', 'Fibob',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: bigPictureStyleInformation,
            largeIcon: FilePathAndroidBitmap(largeIconPath));
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title,
        message.notification!.body!.length > 40
            ? "${message.notification?.body?.substring(0, 40)} ..."
            : message.notification!.body,
        platformChannelSpecifics,
        payload: 'item x');
  }

  static Future<void> setupInteractmessege(BuildContext context,client_ref,userPhoneNumber) async {
    // when app is termineted
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
    handledMessages(context, initialMessage,client_ref,userPhoneNumber);
    }
    
    // when app is in background

    // FirebaseMessaging.onMessageOpenedApp.listen((event) {
    
    //   handledMessages(context, event);
    // });
    //
  }

  static void handledMessages(
      BuildContext context, RemoteMessage message,client_ref,userPhoneNumber) async {
        print("messhandled == $message");
       
      client_ref.onValue.listen((event) {
            print(event.snapshot.value);
            // Handle the real-time data update
            event.snapshot.children.forEach((DataSnapshot snapshot) {
              //  print(snapshot.children.);
              var valueMap = event.snapshot.value as Map<dynamic, dynamic>;
              var profilePic = valueMap['profile_picture'];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenChatRoom(
                    profile: profilePic,
                    user: userPhoneNumber,
                    client: message.notification!.title,
                  ),
                ),
              );
            });
          });
  }
}

