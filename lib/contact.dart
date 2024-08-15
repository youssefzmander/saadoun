import 'package:flutter/material.dart';
import 'package:saadoun/auth.dart';
import 'package:saadoun/signin.dart';
import 'package:url_launcher/url_launcher.dart';

class contact extends StatelessWidget{
  
static const double latitude = 36.818559;
  static const double longitude = 10.129248;

  // Method to launch Google Maps
  void _launchGoogleMaps() async {
    // Construct the URL
    //final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    // Check if the device supports launching URLs
    if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar( title:Text("About Us"),centerTitle: true, backgroundColor: Colors.blue,
        actions: <Widget>[
          
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
            
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Auth().signOut();
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignIn()),
            );
            },
          ),
          ],) ,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         // Align children to the start
        children: [
          Image.asset(
            'assets/BOSCH.png', // Path to your image asset
            width: double.infinity, // Set width to fill the entire width
            height: 200, // Adjust height as needed
            //fit: BoxFit.cover, // Adjust how the image is displayed
          ),

          Padding(
  padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 25.0), // Adjust the horizontal padding as needed
  child: Text(
    "Welcome to BOSCH Car Service Sliti Auto, serving our community since 2011. With expert technicians and cutting-edge equipment, we provide comprehensive car repair and maintenance services. As an authorized BOSCH Car Service center, we uphold the highest standards of quality and professionalism. Trust us to keep your vehicle running smoothly.",
  ),
),
 Center(
            
            child: ElevatedButton(
              onPressed: _launchGoogleMaps,
              child: Text('Navigate to our location'),
            ),
          )
          // Add other widgets below the image if needed
        ],
      ),
    );
  }
}