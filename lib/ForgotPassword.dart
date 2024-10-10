import 'package:flutter/material.dart';
import 'otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneController = TextEditingController();

  void _submitPhoneNumber() {
    String phoneNumber = _phoneController.text;
    if (_validatePhoneNumber(phoneNumber)) {
      // Here, you should send the phone number to your backend to send the OTP
      // For now, we'll just navigate to the next page

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OTPPage(phoneNumber: phoneNumber),
        ),
      );
    }
  }

  bool _validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      _showErrorDialog('Please enter your phone number');
      return false;
    }
    if (!RegExp(r'^\d{11}$').hasMatch(phoneNumber)) {
      _showErrorDialog('Please enter a valid phone number');
      return false;
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 7, 49, 112),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(   
            
            children: [
              Container(               
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/Images/otpimage.png'), // replace with your image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Please enter the phone number we will send the OTP to this phone number.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5B5858),
                  fontFamily: 'Outfit',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPhoneNumber,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color.fromARGB(255, 7, 49, 112),
                ),
                child: Text('Continue', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
