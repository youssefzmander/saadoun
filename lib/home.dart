import 'package:flutter/material.dart';
import 'package:saadoun/localStorage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<FactureData> factureDataList = [];
  FactureData? storedData;
  final LStorage? lStorage = LStorage();
  final Map<String, TextEditingController> controllers = {};
  final TextEditingController recetteController = TextEditingController();
  final TextEditingController caisseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    reloadWidget();
  }

  void reloadWidget() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        loadData();
      });
    });
  }

  void loadData() async {
    List<Map<String, dynamic>>? data = await lStorage?.loadFromLocalStorage();
    print(data);
  }

  Future<void> saveDataToFirestore() async {
    final DateTime now = DateTime.now();
    final String date = DateFormat('yyyy-MM-dd').format(now);
    final String time = DateFormat('HH:mm').format(now);
    final String period = now.hour >= 14 && now.hour < 15
        ? 'day'
        : now.hour >= 23
            ? 'night'
            : 'other';

    final Map<String, dynamic> dataToSave = {
      'date': date,
      'time': time,
      'period': period,
      'data': controllers
          .map((title, controller) => MapEntry(title, controller.text)),
    };

    try {
      await FirebaseFirestore.instance
          .collection('stock')
          .doc('$date')
          .set({'key': 'value'});
      // Save to the stock collection
      await FirebaseFirestore.instance
          .collection('stock/$date/$period')
          .doc()
          .set(dataToSave);

      // Save to the stockadmin collection (overwrite the existing document)
      await FirebaseFirestore.instance
          .collection('stockadmin')
          .doc('realtimeStock')
          .set({
        'data': controllers
            .map((title, controller) => MapEntry(title, controller.text))
      });

      showSnackbar('Data saved successfully!');
    } catch (e) {
      showSnackbar('Error saving data: $e');
    }
  }

  Future<void> saveRecetteData() async {
    final DateTime now = DateTime.now();
    final String date = DateFormat('yyyy-MM-dd').format(now);
    final String time = DateFormat('HH:mm').format(now);

    final Map<String, dynamic> recetteData = {
      'date': date,
      'time': time,
      'recette': recetteController.text,
      'caisse': caisseController.text,
    };

    try {
      await FirebaseFirestore.instance
          .collection('recette')
          .doc()
          .set(recetteData);
      showSnackbar('Recette data saved successfully!');
      recetteController.clear();
      caisseController.clear();
      Navigator.of(context).pop(); // Close the popup
    } catch (e) {
      showSnackbar('Error saving recette data: $e');
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showRecetteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fin de Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: recetteController,
                decoration: InputDecoration(
                  labelText: 'Recette du Service',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: caisseController,
                decoration: InputDecoration(
                  labelText: 'Fond Restant dans la Caisse',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: saveRecetteData,
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    recetteController.dispose();
    caisseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      'Café',
      'Lait',
      'Thé',
      'Eau 1.5L',
      'Eau 1L',
      'Eau Garci',
      'Eau 0.5L',
      'Boisson Gazeuze',
      'Canette Gazeuze',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.assignment_turned_in),
            onPressed: showRecetteDialog,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveDataToFirestore,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: titles.map((title) {
              if (!controllers.containsKey(title)) {
                controllers[title] = TextEditingController();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: controllers[title],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: ' $title quantity',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
