import 'dart:convert';
import 'package:http/http.dart' as http;
class AgoraTokenGenerator {
  String token = "";

  Future<String> buildTokenWithUid(String channel) async {
   
    var url = Uri.parse('https://whatsyapp-notifications-cf0a7cf44082.herokuapp.com/getAgoraToken');

    try {
      var response = await http.get(url, headers: {'channel': channel});
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        token = jsonResponse['token'];
       
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error occurred: $e');
      token = "";
    }

    return token;
  }
}