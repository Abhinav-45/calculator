import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistScreen extends StatelessWidget {
  static const backgroundColor = Color(0xff1a1111);
  final String deviceId;

  const HistScreen({required this.deviceId});

  Future<void> _deleteHistoryItem(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .collection('history')
          .doc(docId)
          .delete();
    } catch (e) {
      // Handle errors if needed
      print('Error deleting document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Center(
          child: Text(
            'History',
            style: TextStyle(color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('devices')
            .doc(deviceId)
            .collection('history')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No history available',
                    style: TextStyle(color: Colors.white)));
          }
          var history = snapshot.data!.docs;
          return ListView.separated(
            itemCount: history.length,
            itemBuilder: (context, index) {
              var doc = history[index];
              var data = doc.data() as Map<String, dynamic>;
              var timestamp = (data['timestamp'] as Timestamp).toDate();
              var formattedDate =
                  DateFormat('yMMMd').add_jm().format(timestamp);
              return ListTile(
                title: Text(
                  '${data['question']} = ${data['answer']}',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[200]),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _deleteHistoryItem(doc.id),
                ),
              );
            },
            separatorBuilder: (context, index) =>
                Divider(color: Color.fromARGB(255, 108, 86, 86)),
          );
        },
      ),
    );
  }
}
