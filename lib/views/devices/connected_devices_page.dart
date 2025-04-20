import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConnectedDevicesPage extends StatelessWidget {
  const ConnectedDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الأجهزة المتصلة"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc('USER_UID')  // قم بتحديد UID المستخدم
            .collection('sessions')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var sessions = snapshot.data!.docs;
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              var session = sessions[index];
              return ListTile(
                title: Text(session['device_name']),
                subtitle: Text('آخر نشاط: ${session['last_active']}'),
                trailing: Text(session['location']),
              );
            },
          );
        },
      ),
    );
  }
}
