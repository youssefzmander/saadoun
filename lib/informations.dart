

import 'package:flutter/material.dart';

class Informations extends StatelessWidget{
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        
        body: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Devices list :', style: TextStyle(fontSize: 20)),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.device_unknown, size: 50),
                title: Text('modem ZTE orange'),
                subtitle:
                    Text('The ZTE modem is a Wi-Fi modem, which means it has four connections without any devices. This allows multiple devices to connect to the internet without the need for cables. A Wi-Fi modem receives information from the Internet Service Provider (ISP) and sends it without a device.'),
              ),
              
            ),
            
          ],
        ),
        
      ),
    );
  }
}