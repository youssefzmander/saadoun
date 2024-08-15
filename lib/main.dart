import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:saadoun/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  runApp(MyApp());
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caffe Saadoun',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}




 class MyHomePage extends StatefulWidget { 
  @override 
  _MyHomePageState createState() => _MyHomePageState(); 
} 

class _MyHomePageState extends State<MyHomePage> { 
  @override 
  void initState() { 
    super.initState(); 
    Timer(Duration(seconds: 3), 
   ()=>Navigator.pushReplacement(context, 
     MaterialPageRoute(builder: 
    (context) =>   SignIn()    ) 
 ) 
         ); 
  } 
  @override 
 Widget build(BuildContext context) {
  return Container(
    color: Color.fromARGB(255, 238, 238, 238),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/BOSCH.png',
          width: double.infinity,
          height: 200,
          //fit: BoxFit.cover,
        ),
        SizedBox(height: 20), // Add space between image and text
        AnimatedTextKit(
  animatedTexts: [
    TypewriterAnimatedText(
      'Sliti Auto Bosch Car Service',
      textStyle: const TextStyle(
        color: Color.fromARGB(255, 38, 149, 241),
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      speed: const Duration(milliseconds: 80),
    ),
  ],
  displayFullTextOnTap: true,
  isRepeatingAnimation: false,
  
  //totalRepeatCount: 4,
  //pause: const Duration(milliseconds: 1000),
  //displayFullTextOnTap: true,
  //stopPauseOnTap: true,
)
      ],
    ),
  );
}
} 