

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LStorage{
//static const String storageKey = 'userData';
Future<void> addToLocalStorage(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
  print('Data added to local storage');
}

  Future<Map<String, dynamic>?> getMapFromLocalStorage(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? jsonString = prefs.getString(key);
  if (jsonString != null) {
    Map<String, dynamic> map = jsonDecode(jsonString);
    return map;
  }
  return null;
}// esm local storage ta3 el data : userData


Future<List<Map<String, dynamic>>> loadFromLocalStorage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('factureData');

      if (jsonString != null) {
        List<dynamic> jsonDataList = jsonDecode(jsonString);
        List<Map<String, dynamic>> factureDataList = jsonDataList
            .map((json) => json as Map<String, dynamic>)
            .toList();
        
        return factureDataList;
      } else {
        print('No data found in local storage.');
        return [];
      }
    } catch (e) {
      print('Error loading data from local storage: $e');
      return [];
    }
  }


  Future<List<Map<String, dynamic>>> loadUniqueFromLocalStorage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('factureUniqueData');

      if (jsonString != null) {
        List<dynamic> jsonDataList = jsonDecode(jsonString);
        List<Map<String, dynamic>> factureDataList = jsonDataList
            .map((json) => json as Map<String, dynamic>)
            .toList();
        
        return factureDataList;
      } else {
        print('No data found in local storage.');
        
        return [];
      }
    } catch (e) {
      print('Error loading data from local storage: $e');
      return [];
    }
  }

  List<Widget> buildCards(List<Map<String, dynamic>> data) {
  List<Widget> cards = [];
  for (var item in data) {
    cards.add(
      Card(
        child: ListTile(
          title: Row( // Wrap title in Row
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded( // Use Expanded for '${item['LIBELLEARTICLE']}' to allow wrapping
                child: Text(
                  '${item['LIBELLEARTICLE']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 8), // Add space between '${item['LIBELLEARTICLE']}' and '${item['DATEFACT']}'
              Text( // '${item['DATEFACT']}' positioned at the right
                '${item['DATEFACT']}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kilometrage actuel: ',
                style: TextStyle(color: Colors.blue, fontSize: 17),
              ),
              SizedBox(height: 8),
              Text(
                '${item['NbrKM'] * 1000} KM',
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              SizedBox(height: 8), // Add some space between lines
              Text(
                'Prochain entretien: ',
                style: TextStyle(color: Colors.blue, fontSize: 17),
              ),
              SizedBox(height: 8), // Add some space between lines
              Text(
                //updatesss
                '${item['NbrKM'] * 1000 + 100000} KM',
                
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
  return cards;
}


Future<Map<String, dynamic>?> getStoredData(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    
    if (jsonString != null) {
      Map<String, dynamic> mapData = jsonDecode(jsonString);
      return mapData;
    }
    return null;
  }

}


class UserData {
  final String Plate;
  final String Plate3;
  final String Plate4;
  final String UserName;
  final String Email;
  final String Tel;
  final String MatType;

  // ignore: non_constant_identifier_names
  UserData({required this.Plate3,required this.MatType, required this.Plate4,    required this.UserName, required this.Email, required this.Plate, required this.Tel});
  

  // You can add more properties as needed// You can add more properties as needed
}

class UserMapper {
  static UserData mapToUserData(Map<String, dynamic> map) {
return UserData(
      UserName: map['UserName'] ?? '',
      Email: map['Email'] ?? '',
      Plate: map['Plate'] ?? '',
      Plate3: map['Plate3'] ?? '',
      Plate4: map['Plate4'] ?? '',
      Tel: map['Tel'] ?? '',
      MatType: map['MatType'] ?? '',
      // Add more fields as needed
    );  }
}

class FactureData {
  final String Datefact;
final String IMAT;
final String LIBELLEARTICLE;
final String NOM_CLIENT;
final String NUMFACT;
final int NbrKM;
final String TypeMat;

  // ignore: non_constant_identifier_names
  FactureData(   {required this.Datefact, required this.IMAT, required this.LIBELLEARTICLE, required this.NOM_CLIENT, required this.NUMFACT, required this.NbrKM, required this.TypeMat});
  

  // You can add more properties as needed
  factory FactureData.fromJson(Map<String, dynamic> json) {
    return FactureData(
      Datefact: json['DATEFACT'],
      IMAT: json['IMAT'],
      LIBELLEARTICLE: json['LIBELLEARTICLE'],
      NOM_CLIENT: json['NOM_CLIENT'],
      NUMFACT: json['NUMFACT'],
      NbrKM: json['NbrKM'],
      TypeMat: json['TypeMat'],
    );
  }
}