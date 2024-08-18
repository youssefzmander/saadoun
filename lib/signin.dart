import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_application_1/mainHome.dart';
import 'package:saadoun/auth.dart';
import 'package:saadoun/localStorage.dart';
import 'package:saadoun/mainHome.dart';
import 'package:saadoun/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  String? errorMessage = "";

  Future<void> addToLocalStorage(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    print('Data added to local storage');
  }

  LStorage lStorage = LStorage();

  @override
  void initState() {
    super.initState();
    Auth().signOut();
  }

  Future<Map<String, dynamic>> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    print('Userrrrrrrrrr: $user');
    print('UserrrrrrrrrrUID: ${user?.uid}');
    if (user?.uid != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user?.uid)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data()!;
        print("userDataaaaa");
        print(userData);
        return userData;
      } else {
        print('User document does not exist');
        return {};
      }
    } else {
      print('User is not signed in');
      return {};
    }
  }

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    try {
      await Auth()
          .signInWithEmailAndPassword(
            email: _controllerEmail.text,
            password: _controllerPassword.text,
          )
          .then((value) => getUserData().then((userData) async {
                print('User Data: $userData');
                String jsonMap = jsonEncode(userData);
                lStorage
                    .addToLocalStorage('userData', jsonMap)
                    .then((value) => {
                          print('S7iii7'),
                        });
              }).then((value) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BottomNavigation()),
                  )));
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.code;
        // Show SnackBar with error message

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Padding(
              padding: EdgeInsets.only(bottom: 10), // Add bottom margin here
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ), // Change font size here
              ),
            ),
            backgroundColor: const Color.fromARGB(
                255, 207, 62, 52), // Change background color here
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Change shape here
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: 20.0, right: 20.0), // Adjust the left padding as needed
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),
              SizedBox(height: 100),
              TextField(
                controller: _controllerEmail,
                decoration: InputDecoration(
                  labelText: 'Your Email',
                  icon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controllerPassword,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  icon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Auth().resetPassword(_controllerEmail.text);
                    },
                    child: Text(
                      'Forget your Password',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Pass context to signInWithEmailAndPassword function
                      signInWithEmailAndPassword(context);
                    },
                    child: Text('Log In'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                "You don't have an account?",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                },
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
