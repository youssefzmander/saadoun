import 'package:flutter/material.dart';
import 'package:saadoun/localStorage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final LStorage? lStorage = LStorage();
  final List<String> products = [
    'Café',
    'Lait',
    'Thé',
    'Eau 1.5L',
    'Eau 1L',
    'Eau Garci',
    'Eau 0.5L',
    'Boisson Gazeuze',
    'Canette Gazeuze',
    'Sucre',
    'Chocolat',
    'Citronade',
    'Produit',
  ];

  String? selectedProduct;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void saveDataToFirestore() async {
    if (selectedProduct != null &&
        quantityController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      final DateTime now = DateTime.now();
      final String date = DateFormat('yyyy-MM-dd').format(now);

      final String product = selectedProduct!;
      final int quantity = int.tryParse(quantityController.text) ?? 0;
      final double price = double.tryParse(priceController.text) ?? 0.0;

      final Map<String, dynamic> newData = {
        'quantity': quantity,
        'price': price,
      };

      final DocumentReference documentRef =
          FirebaseFirestore.instance.collection('achat').doc(date);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final DocumentSnapshot snapshot = await transaction.get(documentRef);

        if (snapshot.exists) {
          // If the document already exists, merge the new data with the existing data
          final Map<String, dynamic> existingData =
              snapshot.data() as Map<String, dynamic>;
          final Map<String, dynamic> updatedData = existingData['data'] ?? {};

          updatedData[product] = newData;

          transaction.update(documentRef, {'data': updatedData});
        } else {
          // If the document does not exist, create it with the new data
          transaction.set(documentRef, {
            'date': date,
            'data': {product: newData},
          });
        }
      });

      print('Data saved to Firestore');
    } else {
      print('Please select a product and enter both quantity and price');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achat Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveDataToFirestore,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedProduct,
              hint: Text('Select a product'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedProduct = newValue;
                });
              },
              items: products.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            if (selectedProduct != null) ...[
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter quantity',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter price',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
