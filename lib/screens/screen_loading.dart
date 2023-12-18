import 'package:WhatsYapp/dependencies/utils/utils_colours.dart';
import 'package:WhatsYapp/screens/Home_pages/home_page.dart';
import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              'Initializing...',
              style: TextStyle(
                color: Coloors.greenDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please wait a moment',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 150),
            Image.asset('assets/intro_circle_emote.png',
                width: 270, height: 270),
            const SizedBox(height: 190),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Coloors.greenDark),
            ),
          ],
        ),
      ),
    );
  }
}


 // var subscription;
  // bool isInternetConnected = false;

  // @override
  // void initState() {
  //   super.initState();
  //   // Start listening to the connectivity changes when the widget is initialized.
  //   subscription = Connectivity().onConnectivityChanged.listen((result) {
  //     setState(() {
  //       isInternetConnected = (result != ConnectivityResult.none);
  //       if (!isInternetConnected) {
  //         // Show a toast message when internet is lost.
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10.0),
  //               ),
  //               contentPadding: EdgeInsets.all(8.0),
  //               title: const Text(''),
  //               content: Column(
  //                 children: [
  //                   Image.asset(
  //                     'assets/no-internet.png',
  //                     height: 100,
  //                     width: 100,
  //                   ),
  //                   SizedBox(height: 25),
  //                   const Text(
  //                     "No Internet!",
  //                     style:
  //                         TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                   ),
  //                   SizedBox(height: 10),
  //                   const Text("Please check internet connection!"),
  //                 ],
  //               ),
  //             );
  //           },
  //         );
  //       }
  //     });
  //   });
  // }

  // @override
  // void dispose() {
  //   // Cancel the subscription when the widget is disposed.
  //   subscription.cancel();
  //   super.dispose();
  // }