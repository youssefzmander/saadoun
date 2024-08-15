


import 'package:flutter/material.dart';
import 'package:saadoun/localStorage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  List<FactureData> factureDataList = [];
  FactureData? storedData;
  final LStorage? lStorage=LStorage();
  @override
  void initState() {
    super.initState();
    reloadWidget();
  }
  void reloadWidget() {
    // Reload the widget after a delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        loadData();
      });
    });
  }
  void loadData() async {
  List<Map<String, dynamic>>? data = await lStorage?.loadFromLocalStorage();
  // Handle the loaded data here
  print(data);
}

@override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: lStorage?.loadFromLocalStorage(),
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