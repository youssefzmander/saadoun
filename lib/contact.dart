import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isAuthenticated = false;
  String? _errorMessage;
  final TextEditingController _passwordController = TextEditingController();

  final String adminPassword = '1996';

  List<Widget> _stockDataWidgets = [];

  void _checkPassword() {
    if (_passwordController.text == adminPassword) {
      setState(() {
        _isAuthenticated = true;
        _errorMessage = null;
      });
      Navigator.of(context).pop();
      _loadStockData();
    } else {
      setState(() {
        _errorMessage = 'Incorrect password. Please try again.';
      });
    }
  }

  void _loadStockData() async {
    try {
      QuerySnapshot stockSnapshots = await FirebaseFirestore.instance
          .collection('stock')
          .orderBy(FieldPath.documentId)
          .get();

      print(
          'Number of documents in stock collection: ${stockSnapshots.docs.length}');

      if (stockSnapshots.docs.isEmpty) {
        print('No documents found in the stock collection.');
        setState(() {
          _stockDataWidgets = [
            ListTile(
              title: Text('No stock data available.'),
            ),
          ];
        });
      } else {
        print('Documents found, processing...');
        setState(() {
          _stockDataWidgets = stockSnapshots.docs.map((doc) {
            return ListTile(
              title: Text('Date: ${doc.id}'),
              onTap: () {
                _showStockDetails(doc.id);
              },
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching stock data: $e');
      setState(() {
        _stockDataWidgets = [
          ListTile(
            title: Text('Error fetching stock data: $e'),
          ),
        ];
      });
    }
  }

  void _showStockDetails(String date) async {
    List<Widget> stockDetailsWidgets = [];

    try {
      DocumentSnapshot stockSnapshot =
          await FirebaseFirestore.instance.collection('stock').doc(date).get();

      if (stockSnapshot.exists) {
        print('Stock data found for date: $date');
        stockDetailsWidgets.add(
          ListTile(
            title: Text('Date: $date'),
            subtitle: Text('Stock: ${stockSnapshot.data()}'),
          ),
        );

        // List of expected sub-collections
        List<String> subCollections = ['day', 'night', 'other'];

        for (String subCollection in subCollections) {
          try {
            QuerySnapshot subCollectionSnapshot = await FirebaseFirestore
                .instance
                .collection('stock')
                .doc(date)
                .collection(subCollection)
                .get();

            if (subCollectionSnapshot.docs.isEmpty) {
              stockDetailsWidgets.add(
                ListTile(
                  title: Text('  Date: $date'),
                  subtitle: Text('  Stock in $subCollection: No data'),
                ),
              );
            } else {
              for (var subDoc in subCollectionSnapshot.docs) {
                print('Sub-Document ID: ${subDoc.id}, Data: ${subDoc.data()}');
                stockDetailsWidgets.add(
                  ListTile(
                    title: Text('  Date: ${subDoc.id}'),
                    subtitle:
                        Text('  Stock in $subCollection: ${subDoc.data()}'),
                  ),
                );
              }
            }
          } catch (e) {
            print('Error fetching sub-collection $subCollection: $e');
            stockDetailsWidgets.add(
              ListTile(
                title: Text('Error fetching $subCollection: $e'),
              ),
            );
          }
        }
      } else {
        print('No stock data found for date: $date');
        stockDetailsWidgets.add(
          ListTile(
            title: Text('No stock data available for date: $date'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching stock data for date $date: $e');
      stockDetailsWidgets.add(
        ListTile(
          title: Text('Error fetching stock data for date $date: $e'),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Stock Details for $date'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: stockDetailsWidgets,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
      barrierDismissible: false,
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
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        centerTitle: true,
      ),
      body: _isAuthenticated
          ? ListView(
              children: _stockDataWidgets,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
