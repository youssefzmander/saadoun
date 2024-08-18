import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isAuthenticated = false;
  String? _errorMessage;
  Map<String, dynamic>? stockData; // Store the stock admin data here

  // Admin password
  final String adminPassword = '1996';

  void _checkPassword() {
    if (_passwordController.text == adminPassword) {
      setState(() {
        _isAuthenticated = true;
        _errorMessage = null;
      });
      Navigator.of(context).pop(); // Close the popup if the password is correct
      _fetchStockData(); // Fetch stock data after authentication
    } else {
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPasswordPopup();
    });
  }

  void _showPasswordPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the popup by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Admin Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Enter Admin Password',
                  errorText: _errorMessage,
                ),
                obscureText: true, // Hide the password input
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _checkPassword,
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchStockData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('stockadmin')
          .doc('realtimeStock')
          .get();

      setState(() {
        stockData = documentSnapshot.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        centerTitle: true,
      ),
      body: _isAuthenticated
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: stockData == null
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Show loading until data is fetched
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Stock Admin Data",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: ListView(
                            children: stockData!.entries.map((entry) {
                              return ListTile(
                                title: Text(entry
                                    .key), // The key of the data (e.g., item name)
                                subtitle: Text(
                                    'Quantity: ${entry.value}'), // The value of the data (e.g., quantity)
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
            )
          : Center(
              child:
                  CircularProgressIndicator(), // Show loading until authenticated
            ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
