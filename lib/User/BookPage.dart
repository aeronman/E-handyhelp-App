import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:E_HandyHelp/User/RequestSentPage.dart';

class BookingForm extends StatefulWidget {
  final String handymanName;
  final List<String> handymanType;
  final String handymanId;
  final String userId;

  BookingForm({
    required this.userId,
    required this.handymanId,
    required this.handymanName,
    required List<dynamic> handymanType,
  }) : handymanType = List<String>.from(handymanType);

  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _serviceDetailsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _urgentRequest = false;
  List<String> _imagesBase64 = [];

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      setState(() {
        _imagesBase64.add(base64Image);
      });
    }
  }

  Future<void> _sendBookingRequest() async {
    if (_formKey.currentState!.validate()) {
      final url = 'http://127.0.0.1:3000/api/bookings';
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'userId': widget.userId,
          'handymanId': widget.handymanId,
          'handymanName': widget.handymanName,
          'handymanType': widget.handymanType,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'serviceDetails': _serviceDetailsController.text,
          'dateOfService': _selectedDate.toIso8601String(),
          'urgentRequest': _urgentRequest,
          'images': _imagesBase64,
        }),
      );

      if (response.statusCode == 200) {
       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmationPage(
                            name: _nameController.text,
                            phone: _phoneController.text,
                            address: _addressController.text,
                            city: _cityController.text,
                            date: _selectedDate,
                            handyman: widget.handymanName,
                            service: '',
                            clientName: '',
                            reservationDateTime: '', 
                            handymanType: widget.handymanType,
                            urgentRequest: _urgentRequest,
                            base64Images: _imagesBase64,
                          ),
                        ),
                      );
      } else {
        print('Failed to send booking request');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Information', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 7, 49, 112),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your city' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _serviceDetailsController,
                  decoration: InputDecoration(
                    labelText: 'Service Details',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  ),
                  maxLines: 5,
                  validator: (value) => value!.isEmpty ? 'Please describe the service needed' : null,
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Date of Service: ${DateFormat('MM/dd/yyyy - hh:mm a').format(_selectedDate)}',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDateTime(context),
                ),
                CheckboxListTile(
                  title: Text('Urgent Request'),
                  value: _urgentRequest,
                  onChanged: (value) {
                    setState(() {
                      _urgentRequest = value ?? false;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Add Image'),
                ),
                Wrap(
                  children: _imagesBase64
                      .map((image) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.memory(
                              base64Decode(image),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendBookingRequest,
                  child: Text('Send Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 49, 112),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
