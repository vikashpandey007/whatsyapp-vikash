import 'package:WhatsYapp/Dependencies/helper/theme_extension.dart';
import 'package:WhatsYapp/dependencies/utils/utils_colours.dart';
import 'package:WhatsYapp/widgets/widget_icon_button.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text(
          '',
          style: TextStyle(color: Color(0xFF017F6A)),
        ),
        actions: [
          CustomIconButton(
            onPressed: () {},
            icon: Icons.more_vert,
            iconColor: Colors.black,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 80.0,
                backgroundImage: AssetImage(
                    'assets/logo_green.png'), // You can replace this with your image
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              '                     Abhishek',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              '                    +91 9897989795',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black.withOpacity(.3),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                iconWithText(icon: Icons.call, text: 'Call'),
                iconWithText(icon: Icons.video_call, text: 'Video'),
                iconWithText(icon: Icons.search, text: 'Search'),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 30),
              title: const Text('Hey there! I am using WhatsApp'),
              subtitle: Text(
                'November 10',
                style: TextStyle(
                  color: context.theme?.greyColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  iconWithText({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: Coloors.greenDark,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(color: Coloors.greenDark),
          ),
        ],
      ),
    );
  }
}
