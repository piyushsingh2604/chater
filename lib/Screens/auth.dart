import 'dart:io';

import 'package:chater/Widgets/User_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _form = GlobalKey<FormState>();

  var _islogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';

  File? _selectedImage;
  var _isAuthenticating = false;


  void _submit() async {
    final isvalid = _form.currentState!.validate();
    if (!isvalid || !_islogin && _selectedImage == null) {
      return;
    }

    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_islogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication failed')));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_islogin)
                          UserImagePicker(
                            onpickImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            },
                          ),
                        TextFormField(
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please Enter a valid email address.';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          decoration: InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        if (!_islogin)
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: "Username",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 4) {
                                return 'Please enter a valid username (at least 4 characters,)';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredUsername = value!;
                            },
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be at least 6 characters long.';
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: "password",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        if (_isAuthenticating) CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                              onPressed: _submit,
                              child: Text(_islogin ? 'Login' : 'Signup')),
                        SizedBox(
                          height: 20,
                        ),
                        if (!_isAuthenticating)
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _islogin = !_islogin;
                                });
                              },
                              child: Text(
                                _islogin
                                    ? 'create an account'
                                    : 'I alredy have an account',
                                style: TextStyle(color: Colors.black),
                              ))
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
