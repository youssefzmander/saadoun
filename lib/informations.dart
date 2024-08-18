import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientCreditsPage extends StatefulWidget {
  @override
  _ClientCreditsPageState createState() => _ClientCreditsPageState();
}

class _ClientCreditsPageState extends State<ClientCreditsPage> {
  final TextEditingController _clientNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Client Credits'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            // Row with TextField and Create Client Button
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _clientNameController,
                    decoration: InputDecoration(
                      labelText: 'Enter Client Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _createClient();
                  },
                  icon: Icon(Icons.add, size: 24),
                  label: Text('Create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Button color
                    foregroundColor: Colors.white, // Text color
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // List of Clients with Credit Prices
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('credit').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final clients = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      return ListTile(
                        title: Text(client.id), // Client Name as ID
                        subtitle:
                            Text('Total Credit: ${client['totalCredit']}'),
                        onTap: () => _showClientDetails(context, client.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to create a new client
  void _createClient() {
    final clientName = _clientNameController.text.trim();
    if (clientName.isNotEmpty) {
      FirebaseFirestore.instance.collection('credit').doc(clientName).set({
        'totalCredit': 0,
        'articles': [],
      }).then((_) {
        _clientNameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Client created successfully!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create client: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a client name')),
      );
    }
  }

  // Function to show client details and add articles
  void _showClientDetails(BuildContext context, String clientName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Client: $clientName'),
          content: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('credit')
                .doc(clientName)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              final creditData = snapshot.data!;
              final articles = creditData['articles'] ?? [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // List of Articles
                  ...articles.map<Widget>((article) => ListTile(
                        title: Text(article['name']),
                        subtitle: Text('Price: ${article['price']}'),
                      )),
                  SizedBox(height: 20),
                  // Add Article Button
                  ElevatedButton(
                    onPressed: () => _addArticle(context, clientName),
                    child: Text('Add Article'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to add article to the client's credit
  void _addArticle(BuildContext context, String clientName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose an Article'),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('articles')
                .doc('rCpBmbLW0edccnDug07E')
                .collection(
                    'articles') // Ensure this matches your collection structure
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final articles = snapshot.data!.docs;

              if (articles.isEmpty) {
                return Text('No articles available');
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return ListTile(
                    title: Text(article['name']),
                    subtitle: Text('Price: ${article['price']}'),
                    onTap: () {
                      FirebaseFirestore.instance
                          .collection('credit')
                          .doc(clientName)
                          .update({
                        'articles': FieldValue.arrayUnion([
                          {'name': article['name'], 'price': article['price']}
                        ]),
                        'totalCredit': FieldValue.increment(article['price']),
                      });
                      Navigator.of(context)
                          .pop(); // Close article selection dialog
                      Navigator.of(context)
                          .pop(); // Close client details dialog
                    },
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
