import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keysafe/home/keynote.dart';
import 'package:keysafe/home/keysafe.dart';
import 'package:lottie/lottie.dart';

class PasswordManagerPage extends StatefulWidget {
  const PasswordManagerPage({super.key});

  @override
  _PasswordManagerPageState createState() => _PasswordManagerPageState();
}

class _PasswordManagerPageState extends State<PasswordManagerPage> {
  String generatedPassword = '';

  String _generateRandomPassword(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()-_=+';
    final random = Random();
    return Iterable.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  void _showPasswordDialog(BuildContext context, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Generated Password'),
          content: Text(password.toUpperCase()),
          actions: [
            TextButton(
              onPressed: () {
                _copyToClipboard(password.toUpperCase());
                Navigator.of(context).pop();
              },
              child: const Text('Copy to Clipboard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied to clipboard')),
    );
  }

  String _encryptText(String text, int shift) {
    String encryptedText = '';

    for (int i = 0; i < text.length; i++) {
      int charCode = text.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) {
        // Uppercase letters
        encryptedText += String.fromCharCode((charCode - 65 + shift) % 26 + 65);
      } else if (charCode >= 97 && charCode <= 122) {
        // Lowercase letters
        encryptedText += String.fromCharCode((charCode - 97 + shift) % 26 + 97);
      } else {
        // Non-alphabetic characters remain unchanged
        encryptedText += text[i];
      }
    }

    return encryptedText;
  }

  String _decryptText(String encryptedText, int shift) {
    String decryptedText = '';

    for (int i = 0; i < encryptedText.length; i++) {
      int charCode = encryptedText.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) {
        // Uppercase letters
        decryptedText +=
            String.fromCharCode((charCode - 65 - shift + 26) % 26 + 65);
      } else if (charCode >= 97 && charCode <= 122) {
        // Lowercase letters
        decryptedText +=
            String.fromCharCode((charCode - 97 - shift + 26) % 26 + 97);
      } else {
        // Non-alphabetic characters remain unchanged
        decryptedText += encryptedText[i];
      }
    }

    return decryptedText;
  }

  void _showTextInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String inputText = ''; // Initialize inputText here

        return AlertDialog(
          title: const Text('Enter Text'),
          content: TextField(
            onChanged: (value) {
              inputText = value;
            },
            decoration: const InputDecoration(hintText: "Enter your text"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                if (inputText.isNotEmpty) _showResultDialog(context, inputText);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(BuildContext context, String text) {
    String encryptedText = _encryptText(text, 3); // Encrypt the input text

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Encrypted Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Encrypted Text: $encryptedText'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _copyToClipboard(encryptedText);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Copy to Clipboard'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPasswordLengthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int passwordLength = 0;

        return AlertDialog(
          title: const Text('Password Length'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
    
              if (value.isNotEmpty) {
                passwordLength = int.parse(value);
              }
            },
            decoration:
                const InputDecoration(hintText: "Enter password length"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
      
                setState(() {
                  generatedPassword = _generateRandomPassword(passwordLength);
                });
                if (passwordLength != 0)
                  _showPasswordDialog(context, generatedPassword);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDecryptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String inputText = ''; 

        return AlertDialog(
          title: const Text('Enter Encrypted Text'),
          content: TextField(
            onChanged: (value) {
              inputText = value;
            },
            decoration: const InputDecoration(hintText: "Enter encrypted text"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (inputText.isNotEmpty) {
                  _showDecryptionResultDialog(context, inputText);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDecryptionResultDialog(BuildContext context, String encryptedText) {
    String decryptedText =
        _decryptText(encryptedText, 3);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Decrypted Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Decrypted Text: $decryptedText'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _copyToClipboard(decryptedText);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Copy to Clipboard'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KeySafe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Lottie.asset('assets/images/safe.json', height: 250),
            buildFeatureCard(
              title: 'Generate Password',
              icon: Icons.lock,
              onTap: () {
                _showPasswordLengthDialog(context);
              },
            ),
            const SizedBox(
              height: 5,
            ),
            buildFeatureCard(
              title: 'Encrypt Text',
              icon: Icons.vpn_key,
              onTap: () {
                _showTextInputDialog(context);
              },
            ),
            const SizedBox(
              height: 5,
            ),
            buildFeatureCard(
              title: 'Decrypt Text',
              icon: Icons.lock_open,
              onTap: () {
                _showDecryptionDialog(context);
              },
            ),
            const SizedBox(
              height: 5,
            ),
            buildFeatureCard(
              title: 'Password Manager',
              icon: Icons.save,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const KeySafePage()));
              },
            ),
            const SizedBox(
              height: 5,
            ),
            buildFeatureCard(
              title: 'App Notes',
              icon: Icons.note,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const KeyNotePage()));
              },
            ),
            const SizedBox(
              height: 5,
            ),
            buildFeatureCard(
              title: 'Log Out',
              icon: Icons.logout,
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: const Center(
                child: Column(
                  children: [
                    Text(
                      'KeySafe',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),

                    // Text('❤️'),
                    SizedBox(height: 4.0),
                    Text(
                      '© 2024',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeatureCard(
      {required String title, required IconData icon, void Function()? onTap}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 16.0),
              Text(
                title,
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
