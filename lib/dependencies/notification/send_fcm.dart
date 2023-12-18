
import 'package:http/http.dart' as http;

class SendFCM {
  Future<void> sendFcmMessage(String topic, String title, String body) async {
    var url = Uri.parse(
        'https://whatsyapp-notifications-cf0a7cf44082.herokuapp.com/sendNotification');

    try {
      var response = await http.get(
        url,
        headers: {
          'topic': topic,
          'title': title,
          'body': body,
        },
      );

      print('Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
