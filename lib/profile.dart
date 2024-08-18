import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saadoun/localStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final List<String> _choices = ['TU', 'RS', 'FCR', 'DOUANE', 'ETAT', 'AUTRES'];
  late String? _selectedChoice = 'TU';
  //String? _selectedChoice=storedData?.MatType.toString();
  LStorage lStorage = LStorage();
  UserData? storedData;
  final _auth = FirebaseAuth.instance;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _errorMessage = '';
  late String? _Plate3 = storedData?.Plate3; //
  late String? _Plate4 = storedData?.Plate4; //
  late String? _eemail = storedData?.Email; //
  late String? _uuserName = storedData?.UserName; //
  late String? _Tel = storedData?.Tel;

  late String Plate = storedData!.Plate;
  User? user = FirebaseAuth.instance.currentUser;

//user?.uid
  Future<void> updateMapInLocalStorage(Map<String, dynamic> newData) async {
    try {
      // Retrieve the map from local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonDataString = prefs.getString('userData');

      // Parse the JSON string to a map
      Map<String, dynamic> existingData =
          jsonDataString != null ? jsonDecode(jsonDataString) : {};

      // Update the existing data with the new data
      existingData.addAll(newData);

      // Convert the updated map to JSON
      String updatedJsonString = jsonEncode(existingData);

      // Save the updated map back to local storage
      await prefs.setString('userData', updatedJsonString);

      print('Map updated in local storage successfully.');
    } catch (e) {
      print('Error updating map in local storage: $e');
    }
  }

  Future<void> updateUserData(String userId) async {
    try {
      // Reference to the document of the user in Firestore
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      print('User idddd: $userId');
      // Update the user data
      Map<String, String?> newData;
      newData = {
        'UserName': _uuserName,
        'Email': _eemail,
        'Tel': _Tel,
        'Plate': Plate,
        'Plate3': _Plate3,
        'Plate4': _Plate4,
        'MatType': _selectedChoice,
      };
      await userDocRef.update(newData).then((value) async => {
            print('User data updated successfullyyyyyyy.'),
            await _auth.currentUser!
                .updatePassword(_eemail!)
                .onError((error, stackTrace) => print(error)),
            updateMapInLocalStorage(newData)
          });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Padding(
            padding: EdgeInsets.only(bottom: 10), // Add bottom margin here
            child: Text(
              "User data updated successfully.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ), // Change font size here
            ),
          ),
          backgroundColor:
              Color.fromARGB(255, 0, 184, 3), // Change background color here
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Change shape here
          ),
        ),
      );
      print('User data updated successfully.');
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  Map<String, dynamic>? mapData;
  Future<void> loadData() async {
    mapData = await lStorage.getStoredData('userData');
    if (mapData != null) {
      storedData = UserMapper.mapToUserData(mapData!);
      print('Stored Map Data: $storedData');
      // You can use storedData as needed in your widget
      setState(() {}); // Trigger a rebuild to update the UI
    }
    print('Stored Map Data: $storedData');
    // You can use storedData as needed in your widget
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('settings and privacy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            leading: Icon(Icons.settings),
          ),
          ListTile(
            title: Text('personal account information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (String? uuserName) {
                    setState(() {
                      _uuserName = uuserName!;
                    });
                    print('user Name: $uuserName');
                  },
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    icon: Icon(Icons.person),
                    hintText: storedData?.UserName,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  onChanged: (String? eemail) {
                    setState(() {
                      _eemail = eemail!;
                    });
                    print('email: $eemail');
                  },
                  decoration: InputDecoration(
                    labelText: 'Your Email',
                    icon: Icon(Icons.email),
                    hintText: storedData?.Email,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  onChanged: (String? Tel) {
                    setState(() {
                      _Tel = Tel!;
                    });
                    print('Tel: $Tel');
                  },
                  decoration: InputDecoration(
                    labelText: 'TEL',
                    icon: Icon(Icons.phone),
                    hintText: storedData?.Tel,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () {
                updateUserData(user!.uid);
              },
              child: Text('Update'),
            ),
          ),
          ListTile(
            title: Text('password and security',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'old password',
                  ),
                  controller: _oldPasswordController,
                  obscureText: true,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'new password',
                  ),
                  controller: _newPasswordController,
                  obscureText: true,
                ),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'password confirmation',
                  ),
                ),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () async {
                String oldPassword = _oldPasswordController.text;
                String newPassword = _newPasswordController.text;
                String confirmPassword = _confirmPasswordController.text;

                if (newPassword != confirmPassword) {
                  setState(() {
                    _errorMessage = 'Passwords do not match';
                  });
                  return;
                }

                try {
                  // Reauthenticate the user with their old password
                  AuthCredential credential = EmailAuthProvider.credential(
                      email: _auth.currentUser!.email!, password: oldPassword);
                  await _auth.currentUser!
                      .reauthenticateWithCredential(credential);

                  // Update the user's password
                  await _auth.currentUser!.updatePassword(newPassword);

                  // Password updated successfully
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Padding(
                        padding: EdgeInsets.only(
                            bottom: 10), // Add bottom margin here
                        child: Text(
                          "Password changed successfully.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ), // Change font size here
                        ),
                      ),
                      backgroundColor: Color.fromARGB(
                          255, 0, 184, 3), // Change background color here
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Change shape here
                      ),
                    ),
                  );
                } catch (error) {
                  setState(() {
                    _errorMessage = error.toString();
                  });
                }
              },
              child: Text('Update'),
            ),
          ),
        ],
      ),
    );
  }
}
