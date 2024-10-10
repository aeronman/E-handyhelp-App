import 'dart:io';
import 'package:E_HandyHelp/User/BookPage.dart';
import 'package:E_HandyHelp/User/UserNotification.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:E_HandyHelp/FirstPage.dart';
import 'package:E_HandyHelp/Messages.dart';
import 'package:E_HandyHelp/User/Settings.dart';
import 'package:E_HandyHelp/User/UserAccountInformation.dart';
import 'package:E_HandyHelp/User/ServiceRequest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http; 

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-HandyHelp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Dashboard(),
    );
  }
}
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _fname = '';
  String _lname = '';
  String _username = '';
  String _password = '';
  String _contact = '';
  String _address = '';
  String _dateOfBirth = '';
  File? _profileImage;

  TextEditingController _passwordController = TextEditingController();
  TextEditingController _searchController = TextEditingController(); // Add search controller

  bool _isLoading = true; // Added loading state
  List<Map<String, dynamic>> profiles = []; // Profiles list
  List<Map<String, dynamic>> filteredProfiles = []; // Filtered profiles list

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data
    fetchProfiles(); // Fetch profiles from API
    _searchController.addListener(_filterProfiles); // Listen to changes in search field
  }

  // Fetch profiles from the API
  Future<void> fetchProfiles() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:3000/profiles'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          profiles = data.map((profile) {
            return {
              'name': '${profile['fname']} ${profile['lname']}',
              'address': profile['address'],
              'handymanType': profile['specialization'], // Ensure this is an array of strings
              'imageUrl': profile['idImages'].isNotEmpty ? profile['idImages'][0] : null,
            };
          }).toList();
          filteredProfiles = profiles; // Initialize filtered profiles
          _isLoading = false; // Set loading to false after fetching
        });
      } else {
        throw Exception('Failed to load profiles');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Set loading to false on error
      });
      print('Error fetching profiles: $e');
    }
  }

  // Filter profiles based on search input
  void _filterProfiles() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProfiles = profiles.where((profile) {
        // Check if handymanType is a list and contains the query
        bool matchesType = profile['handymanType'] is List 
          && (profile['handymanType'] as List).any((type) => type.toLowerCase().contains(query));
        // Check if the name contains the query
        bool matchesName = profile['name'].toLowerCase().contains(query);

        // Return true if either condition is met
        return matchesType || matchesName;
      }).toList();
    });
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fname = prefs.getString('fname') ?? '';
      _lname = prefs.getString('lname') ?? '';
      _username = prefs.getString('username') ?? '';
      _contact = prefs.getString('contact') ?? '';
      _password = prefs.getString('password') ?? '';
      String? imagePath = prefs.getString('profileImage');
      if (imagePath != null && imagePath.isNotEmpty) {
        _profileImage = File(imagePath);
      }
    });
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      // Save image path or update profile image in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', image.path);
    }
  }

  Future<Map<String, String>> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fname = prefs.getString('fname') ?? 'First Name';
    String lname = prefs.getString('lname') ?? 'Last Name';
    String username = prefs.getString('username') ?? 'Username';
    return {'fname': fname, 'lname': lname, 'username': username};
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose of the search controller
    super.dispose();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "E-HandyHelp",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF081A6E),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        // Your existing drawer implementation...
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16),

                  // **Carousel Slider Implementation**
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0, // Height of the carousel
                      autoPlay: true, // Enable auto-play
                      enlargeCenterPage: true, // Enlarge the center page
                      aspectRatio: 16 / 9, // Aspect ratio for the images
                      autoPlayCurve: Curves.easeInOut, // Animation curve
                      autoPlayInterval: Duration(seconds: 2), // Auto-play interval
                      autoPlayAnimationDuration: Duration(milliseconds: 800), // Animation duration
                    ),
                    items: [
                      // Replace with your image URLs or widget items
                      'https://via.placeholder.com/600x400/FF0000/FFFFFF?text=Image+1',
                      'https://via.placeholder.com/600x400/00FF00/FFFFFF?text=Image+2',
                      'https://via.placeholder.com/600x400/0000FF/FFFFFF?text=Image+3',
                    ].map((item) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(item, fit: BoxFit.cover, width: 1000.0),
                      ),
                    )).toList(),
                  ),

                  SizedBox(height: 16),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Handyman',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Handyman Profiles
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredProfiles.length,
                      itemBuilder: (context, index) {
                        final profile = filteredProfiles[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: profile['imageUrl'] != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(profile['imageUrl']),
                                  )
                                : CircleAvatar(
                                    backgroundImage: AssetImage('lib/Images/profile.webp'),
                                  ),
                            title: Text(profile['name']),
                            subtitle: Text(profile['handymanType'].join(', ')),
                            trailing: IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BookPage()),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

