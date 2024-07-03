import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'messages_page.dart';
import 'new_message_page.dart'; // التأكد من استيراد الصفحة بشكل صحيح

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? FirebaseOptions(
      apiKey: 'API_KEY',
      authDomain: 'AUTH_DOMAIN',
      projectId: 'PROJECT_ID',
      storageBucket: 'STORAGE_BUCKET',
      messagingSenderId: 'MESSAGING_SENDER_ID',
      appId: 'APP_ID',
      measurementId: 'MEASUREMENT_ID',
    )
        : null,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomePage(),
      routes: {
        '/messages': (context) => MessagesPage(),
        '/new_message': (context) => NewMessagePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isConnected = false;
  final String documentId = 'JzB67SilOS2rSerzyhOL';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getStatus();
    initNotification();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      toggleConnection(true);
    } else if (state == AppLifecycleState.paused) {
      toggleConnection(false);
    }
  }

  void getStatus() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('sms reader').doc(documentId).get();
      setState(() {
        isConnected = doc['status'] == 'connected';
      });
    } catch (e) {
      print("Error getting status: $e");
    }
  }

  void toggleConnection(bool connect) async {
    setState(() {
      isConnected = connect;
    });
    try {
      await FirebaseFirestore.instance.collection('sms reader').doc(documentId).update({
        'status': isConnected ? 'connected' : 'disconnected',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  void initNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
          if (notificationResponse.payload != null) {
            print('notification payload: ${notificationResponse.payload}');
          }
          Navigator.pushNamed(context, '/messages');
        });
  }

  void logout() async {
    try {
      await FirebaseFirestore.instance.collection('sms reader').doc(documentId).update({
        'status': 'logged out',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Status App'),
        actions: [
          ElevatedButton(
            onPressed: logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Logout'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => toggleConnection(!isConnected),
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnected ? Colors.green : Colors.red,
                shape: CircleBorder(),
                padding: EdgeInsets.all(24),
              ),
              child: Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Text(
              isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/messages');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(16),
              ),
              child: Text('الرسايل', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
