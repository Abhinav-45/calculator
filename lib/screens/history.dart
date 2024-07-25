import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistScreen extends StatelessWidget {
  static const backgroundColor = Color(0xff1a1111);
  static const textColor1 = Colors.white;
  static const textColor2 = Colors.grey;
  static const dividerColor = Color.fromARGB(255, 108, 86, 86);
  final String deviceId;

  const HistScreen({super.key, required this.deviceId});

  Future<void> _deleteHistoryItem(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('devices')
          .doc(deviceId)
          .collection('history')
          .doc(docId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting document: $e');
      }
    }
  }

  Widget _buildListItem(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    var timestamp = data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : DateTime.now();
    var formattedDate = DateFormat('yMMMd').add_jm().format(timestamp);

    return ListTile(
      title: Text(
        '${data['question']} = ${data['answer']}',
        style: const TextStyle(color: textColor1),
      ),
      subtitle: Text(
        formattedDate,
        style: TextStyle(color: textColor2.shade200),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: textColor1),
        onPressed: () => _deleteHistoryItem(doc.id),
      ),
    );
  }

  Widget _buildHistoryList(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child:
            Text('No history available', style: TextStyle(color: textColor1)),
      );
    }

    var history = snapshot.data!.docs;
    return ListView.separated(
      itemCount: history.length,
      itemBuilder: (context, index) => _buildListItem(history[index]),
      separatorBuilder: (context, index) => const Divider(color: dividerColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Center(
          child: Text('History', style: TextStyle(color: textColor1)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp, color: textColor1),
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
        builder: _buildHistoryList,
      ),
    );
  }
}
