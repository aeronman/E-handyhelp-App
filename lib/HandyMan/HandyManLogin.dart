import 'package:E_HandyHelp/ForgotPassword.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'HandyManRegister.dart';
import 'HandyManHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for shared_preferences

class HandyManLogin extends StatefulWidget {
  const HandyManLogin({super.key});

  @override
  _HandyManLoginState createState() => _HandyManLoginState();
}

class _HandyManLoginState extends State<HandyManLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginHandyman() async {
    final url = Uri.parse('http://192.168.0.113:3000/login-handyman');
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      print("Sending login request for username: $username"); // Log request initiation

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print("Received response with status code: ${response.statusCode}"); // Log response status code

      // Define 'data' here to avoid undefined name error
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // If the login is successful, extract token and handyman data
        final String token = data['token'];
        final handyman = data['handyman'];

        print("Login successful for username: $username"); // Log success

        // Save handyman data in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('_id', handyman['id']);
        await prefs.setString('fname', handyman['fname']);
        await prefs.setString('lname', handyman['lname']);
        await prefs.setString('username', handyman['username']);
        await prefs.setString('dateOfBirth', handyman['dateOfBirth']);
        await prefs.setString('contact', handyman['contact']);
        await prefs.setString('address', handyman['address']);
        await prefs.setStringList('specialization', List<String>.from(handyman['specialization']));
        await prefs.setStringList('idImages', List<String>.from(handyman['idImages']));
        await prefs.setStringList('certificatesImages', List<String>.from(handyman['certificatesImages']));
        await prefs.setBool('dataPrivacyConsent', handyman['dataPrivacyConsent']);
        await prefs.setString('accounts_status', handyman['accounts_status']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HandyManHomePage()),
        );
      } else {
        // Handle error if the login fails
        print("Login failed: ${data['message']}"); // Log failure
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(data['message'] ?? 'Invalid credentials. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print("An error occurred during login: $error"); // Log general errors
      // Handle general errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  String? _validateUsernameOrContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.fromARGB(255, 245, 245, 245);
    final gradientColors = [
      Color.fromARGB(255, 245, 245, 245),
      Color.fromARGB(255, 245, 245, 245),
      Color.fromARGB(255, 245, 245, 245)
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 80),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Image.asset(
                        'lib/Images/logo.png',
                        height: 200,
                        width: 200,
                      ),
                    ),
                    SizedBox(height: 50),
                    Text(
                      "Login",
                      style: TextStyle(
                          color: Color.fromARGB(255, 7, 49, 112),
                          fontSize: 60,
                          fontFamily: 'roboto'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 7, 49, 112),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 40),
                        TextFormField(
                          controller: _usernameController,
                          validator: _validateUsernameOrContact,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Colors.grey),
                            hintText: "Username",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: backgroundColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          validator: _validatePassword,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.grey),
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: backgroundColor,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPasswordPage()),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        MaterialButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              _loginHandyman();
                            }
                          },
                          height: 50,
                          minWidth: double.infinity,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Color.fromARGB(255, 7, 49, 112),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HandyManRegister()),
                                );
                              },
                              child: Text(
                                "Register Now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
