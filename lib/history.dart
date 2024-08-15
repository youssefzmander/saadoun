


import 'package:flutter/material.dart';
import 'package:saadoun/localStorage.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}
class _HistoryState extends State<History>{
  List<FactureData> factureDataList = [];
  FactureData? storedData;
  final LStorage? lStorage=LStorage();
  @override
  void initState() {
    super.initState();
    loadData();
  }
  void loadData() async {
  List<Map<String, dynamic>>? data = await lStorage?.loadUniqueFromLocalStorage();
  // Handle the loaded data here
  print(data);
}
@override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: lStorage?.loadUniqueFromLocalStorage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> data = snapshot.data!;
          List<Widget> cards = lStorage!.buildCards(data);
          return ListView(
            children: cards,
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }
}