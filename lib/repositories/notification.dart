import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

String key =
    'AAAAWJ7tNfM:APA91bGuaAuArRzEceFc8pZNy0Qb23nM35oSJ84q3jzQarwz8WC8ynuWUelD98-zLNCw7GXLcT-f9jQflYCCPCqqmdiqn4xlrsZlXoaUsWC1N2-wZ_pAzcYhTbfeCKlo1TCe8t8XrJcd';

Future<void> sendNotification(
  String topic,
  String title,
  dynamic message,
  String summary
) async {
  try {
    http
        .post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$key',
          },
          body: jsonEncode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'title': title,
                'body': message,
              },
              'priority': 'high',
              'data': <String, dynamic>{'summary':summary,'dateTime':DateTime.now().toString()},
              'to': '/topics/$topic',
            },
          ),
        )
        .then((value) => log(value.body.toString()))
        .onError((error, stackTrace) => log(error.toString()));
    log('Notification sent');
  } catch (err) {
    log('Unable to send notification: $err');
  }
}

Future getSubscribedTopic(token) async {
  try {
    final response = await http.get(
      Uri.parse('https://iid.googleapis.com/iid/info/$token?details=true'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$key',
      },
    );
    if (response.statusCode == 200) {
      final topics = jsonDecode(response.body)['rel']['topics'] as Map;
      final a = topics.keys.toList();
      return a;
    } else {
      print('Failed to get subscribed topics: ${response.statusCode}');
    }
    log('successful');
  } catch (err) {
    log('unable');
  }
}

Future subscribeToTopic(List<String> token, String topic) async {
  try {
    final url = Uri.parse('https://iid.googleapis.com/iid/v1:batchAdd');

    await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$key',
        },
        body:
            jsonEncode({'to': '/topics/$topic', 'registration_tokens': token}));
    return {'success': true};
  } catch (e) {
    return {'error': e};
  }
}
//Unsubscribe and subscribe on changing semester from profile
Future unsubscribeToTopic(List<String> token, String topic) async {
  try {
    final url = Uri.parse('https://iid.googleapis.com/iid/v1:batchRemove');

    await http.post(url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$key',
        },
        body:
            jsonEncode({'to': '/topics/$topic', 'registration_tokens': token}));

    return {'success': true};
  } catch (e) {
    return {'error': e};
  }
}

// Future changeTopic() async {
//   DatabaseReference a = FirebaseDatabase.instance.ref('users');
//   final snapshot = await a.orderByChild('semester').equalTo("Semester 1").get();
//   // final data = (snapshot.value as Map).values.toList();
  

// }
