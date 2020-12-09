import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learning_app/pages/authentication/login_page.dart';
import 'package:learning_app/pages/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

//  FirebaseApp.configure(
//    name: 'db2',
//    options: Platform.isIOS
//        ? const FirebaseOptions(
//            googleAppID: '1:788316081318:ios:56dceb6291f8655a',
//            gcmSenderID: '788316081318',
////      databaseURL: 'https://flutter-chat-f6130.firebaseio.com/',
//          )
//        : const FirebaseOptions(
//            googleAppID: '1:746603307187:android:34db201881034468b850c6',
//            apiKey: 'AIzaSyCGK6K5UyzuVdhG1uG2LxWIrHP7U7qbFcc',
////      databaseURL: 'https://flutter-chat-f6130.firebaseio.com/',
//          ),
//  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Muli',
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.black),
          )),
      home: FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (c, s) {
          if (s.hasError) print('ERROR ${s.error.toString()}');
          if (s.hasData) {
            if (s.data.uid != null && s.data.uid.isNotEmpty) {
              return HomePage();
            } else {
              return LoginPage();
            }
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
