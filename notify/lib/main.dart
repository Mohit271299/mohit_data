import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rxdart/rxdart.dart';

import 'notification_testing.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: FirebaseOptions(
      //     apiKey: "AIzaSyCmOC4dUAznvebLDs7KS8Ao95vQD_4cbZc",
      //     authDomain: "webtesting-b062b.firebaseapp.com",
      //     projectId: "webtesting-b062b",
      //     storageBucket: "webtesting-b062b.appspot.com",
      //     messagingSenderId: "461157598549",
      //     appId: "1:461157598549:web:ef49da3553106782cddbdc",
      //     measurementId: "G-HBQZTRHTVF"
      // )
      );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Notify',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
BehaviorSubject<String?>();

const MethodChannel platform =
MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
class _HomePageState extends State<HomePage> {
  late int _totalNotifications;
  PushNotification? _notificationInfo;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  Future<void> _showNotificationCustomSound() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      channelDescription: 'your other channel description',
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
    );
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
    IOSNotificationDetails(sound: 'slow_spring_board.aiff');
    const MacOSNotificationDetails macOSPlatformChannelSpecifics =
    MacOSNotificationDetails(sound: 'slow_spring_board.aiff');
    final LinuxNotificationDetails linuxPlatformChannelSpecifics =
    LinuxNotificationDetails(
      sound: AssetsLinuxSound('sound/slow_spring_board.mp3'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: macOSPlatformChannelSpecifics,
      linux: linuxPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'custom sound notification title',
      'custom sound notification body',
      platformChannelSpecifics,
    );


  }
  // Future displayNotification() async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'you_can_name_it_whatever',
  //     'flutterfcm',
  //     playSound: true,
  //     sound: RawResourceAndroidNotificationSound('a_old_telephone.mp3'),
  //     importance: Importance.max,
  //   );
  // }


  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,

    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        SecondPage(receivedNotification.payload),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.pushNamed(context, '/secondPage');
    });
  }

  @override
  void initState() {
    _requestPermissions();

    // _requestPermissions();
    // _configureDidReceiveLocalNotificationSubject();
    // _configureSelectNotificationSubject();
    //

    registerNotification();
    _totalNotifications = 0;
    _firebaseMessaging.getToken().then((token) {
      print("token $token");
    });
    // For handling notification when the app is in background
    // but not terminated

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );


      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });
    checkForInitialMessage();
    super.initState();
  }

  late final FirebaseMessaging _messaging;

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();
    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. On iOS, this helps to take the user permissions

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // ...
        if (_notificationInfo != null) {
          // For displaying the notification as an overlay

          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,

            duration: Duration(seconds: 1)

          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }


  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }

  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notify'),
        brightness: Brightness.dark,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
           child: Text('Sound Test'),
            onPressed: () async {
              await _showNotificationCustomSound();
            },
          ),


          //...
          Text(
            'App for capturing Firebase Push Notifications',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 16.0),
          NotificationBadge(totalNotifications: _totalNotifications),
          SizedBox(height: 16.0),

          if (_notificationInfo != null) navigator() else Container(),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(
          //       'TITLE: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}',
          //       style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16.0,
          //       ),
          //     ),
          //     SizedBox(height: 8.0),
          //     Text(
          //       'BODY: ${_notificationInfo!.dataBody ?? _notificationInfo!.body}',
          //       style: TextStyle(
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16.0,
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }

  navigator() {
     SchedulerBinding.instance!.addPostFrameCallback((_) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => notificationTest()));
      // Add Your Code here.
    });
  }
}

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: new BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
    this.sound,
    this.dataTitle,
    this.dataBody,
  });

  String? title;
  String? body;
  String? sound;
  String? dataTitle;
  String? dataBody;
}
class SecondPage extends StatefulWidget {
  const SecondPage(
      this.payload, {
        Key? key,
      }) : super(key: key);

  static const String routeName = '/secondPage';

  final String? payload;

  @override
  State<StatefulWidget> createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  String? _payload;

  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Second Screen with payload: ${_payload ?? ''}'),
    ),
    body: Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Go back!'),
      ),
    ),
  );
}