import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientCreditsPage extends StatefulWidget {
  @override
  _ClientCreditsPageState createState() => _ClientCreditsPageState();
}

class _ClientCreditsPageState extends State<ClientCreditsPage> {
  final TextEditingController _clientNameController = TextEditingController();

  // Define the list of predefined articles
  final List<Map<String, dynamic>> _predefinedArticles = [
    {'name': 'Express', 'price': 1300},
    {'name': 'Cappuccino', 'price': 1500},
    {'name': 'Direct', 'price': 1700},
  ];

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
        'paid': false, // Adding a 'paid' field to track payment status
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
                return Center(child: CircularProgressIndicator());
              }

              final creditData = snapshot.data!;
              final articles = creditData['articles'] ?? [];
              final isPaid =
                  creditData.data() != null && (creditData['paid'] ?? false);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // List of Articles with Optional Delete Icon
                  ...articles.map<Widget>((article) => ListTile(
                        title: Text(article['name']),
                        subtitle: Text('Price: ${article['price']}'),
                        trailing: isPaid
                            ? IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _removeArticle(clientName, article);
                                },
                              )
                            : null,
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
        return SimpleDialog(
          title: Text('Choose an Article'),
          children: _predefinedArticles.map((article) {
            return SimpleDialogOption(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('credit')
                    .doc(clientName)
                    .update({
                  'articles': FieldValue.arrayUnion([
                    {'name': article['name'], 'price': article['price']}
                  ]),
                  'totalCredit': FieldValue.increment(article['price']),
                });
                Navigator.of(context).pop(); // Close article selection dialog
                Navigator.of(context).pop(); // Close client details dialog
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('${article['name']} - Price: ${article['price']}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Function to remove an article from the client's credit
  void _removeArticle(String clientName, Map<String, dynamic> article) {
    FirebaseFirestore.instance.collection('credit').doc(clientName).update({
      'articles': FieldValue.arrayRemove([
        {'name': article['name'], 'price': article['price']}
      ]),
      'totalCredit': FieldValue.increment(-article['price']),
    }).then((_) {
      Navigator.of(context).pop(); // Close client details dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article removed successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove article: $error')),
      );
    });
  }
}
