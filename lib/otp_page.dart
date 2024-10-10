import 'package:flutter/material.dart';
import 'dart:async'; // Import this for Timer
import 'new_password.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;

  OTPPage({required this.phoneNumber});

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  late Timer _timer;
  int _start = 60; // Start with 60 seconds

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _submitOTP() {
    // Combine the OTP from each field into one string
    String otp = _otpControllers.map((controller) => controller.text).join();

    // Here, you should verify the OTP with your backend
    // For now, we'll just navigate to the next page
    if (otp.length == 4) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NewPasswordPage(),
        ),
      );
    } else {
      // Show error dialog if OTP is not complete
      _showErrorDialog('Please enter a complete OTP.');
    }
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resendCode() {
    // Implement resend OTP logic here
    // For now, just restart the timer
    setState(() {
      _start = 60;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 7, 49, 112),
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
                'OTP sent to ${widget.phoneNumber}',
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
                'Please enter the OTP sent to your phone number.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5B5858),
                  fontFamily: 'Outfit',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildOtpInput(),
              SizedBox(height: 20),
              Text(
                _start == 0 ? '' : '$_start seconds remaining',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 10),
              _start == 0
                  ? TextButton(
                      onPressed: _resendCode,
                      child: Text(
                        'Didn\'t receive the code? Resend',
                        style: TextStyle(color: Color.fromARGB(255, 7, 49, 112)),
                      ),
                    )
                  : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitOTP,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: const Color.fromARGB(255, 7, 49, 112),
                ),
                child: Text('Submit', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 50,
          child: TextField(
            controller: _otpControllers[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              counterText: '',
            ),
            maxLength: 1,
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                FocusScope.of(context).nextFocus();
              }
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
