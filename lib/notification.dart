import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    _firebaseMessaging.requestPermission();
    final fcmToken = await FirebaseMessaging.instance.getToken();
          print("FCM Token: $fcmToken");

    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message: ${message.notification!.title}");
      // Display notification using Flutter local notifications or show a custom dialog
    });
  }
}