import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class KeySafePage extends StatefulWidget {
  const KeySafePage({super.key});

  @override
  _KeySafePageState createState() => _KeySafePageState();
}

class _KeySafePageState extends State<KeySafePage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // Function to save a new password to Firestore
  void _savePassword(String uid, String title) async {
    String newPassword = _passwordController.text.trim();

    if (newPassword.isNotEmpty && title.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('keysafeUsers')
            .doc(uid)
            .collection('passwords')
            .add({'title': title, 'password': newPassword});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password saved successfully')),
        );
        _passwordController.clear();
        _titleController.clear();
      } catch (e) {
        print('Error saving password: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving password')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and password')),
      );
    }
  }

  // Function to delete a password from Firestore
  void _deletePassword(String uid, String passwordId) async {
    try {
      await FirebaseFirestore.instance
          .collection('keysafeUsers')
          .doc(uid)
          .collection('passwords')
          .doc(passwordId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password deleted successfully')),
      );
    } catch (e) {
      print('Error deleting password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KeySafe'),
      ),
      body: Column(
        children: [ Lottie.asset('assets/images/pass.json',height: 200),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Enter Title',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter Password',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _savePassword(FirebaseAuth.instance.currentUser!.uid, _titleController.text);
            },
            child: const Text('Save Password'),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('keysafeUsers')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('passwords')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return const Text('No passwords found');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      return ListTile(
                        title: Text(document['title']),
                        subtitle: Text(document['password']),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deletePassword(FirebaseAuth.instance.currentUser!.uid, document.id);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
