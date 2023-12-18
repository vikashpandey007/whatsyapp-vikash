import 'package:WhatsYapp/dependencies/utils/utils_colours.dart';
import 'package:flutter/material.dart';
import 'package:WhatsYapp/Dependencies/helper/theme_extension.dart';

showLoadingDialog({
  required BuildContext context,
  required String message,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircularProgressIndicator(
                  color: Coloors.greenDark,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Coloors.backgroundDark,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
