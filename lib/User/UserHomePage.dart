import 'dart:io';
import 'package:E_HandyHelp/User/BookPage.dart';
import 'package:E_HandyHelp/User/UserNotification.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:E_HandyHelp/FirstPage.dart';
import 'package:E_HandyHelp/User/Messages.dart';
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
  String _id = '';
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
    _searchController.addListener(_filterProfiles); // Add listener to the search controller
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller when the widget is destroyed
    super.dispose();
  }
  Future<void> _logout(BuildContext context) async {
    // Clear SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Navigate back to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => FirstPage()), // Replace with your login screen widget
    );
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
              '_id' : profile['_id'],
              'name': '${profile['fname']} ${profile['lname']}',
              'address': profile['address'],
              'handymanType': profile['specialization'], // Array of strings
              'imageUrl': profile['idImages'].isNotEmpty ? profile['idImages'][0] : null,
            };
          }).toList();
          filteredProfiles = profiles; // Initially, filtered profiles = all profiles
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

  // Filter profiles based on the search term
  void _filterProfiles() {
    String searchQuery = _searchController.text.toLowerCase();
    setState(() {
      filteredProfiles = profiles.where((profile) {
        List<dynamic> handymanTypes = profile['handymanType'];
        return handymanTypes.any((type) => type.toLowerCase().contains(searchQuery));
      }).toList();
    });
  }
 Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _id = prefs.getString('_id') ?? '';
      _fname = prefs.getString('fname') ?? '';
      _lname = prefs.getString('lname') ?? '';
      _username = prefs.getString('username') ?? '';
      _contact = prefs.getString('contact') ?? '';
      _password = prefs.getString('password') ?? '';
      String? imagePath = prefs.getString('images');
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
        child: FutureBuilder<Map<String, String>>(
          future: _getUserData(),
          builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading user data'));
            } else {
              final userData = snapshot.data!;
              return ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 7, 49, 112),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _pickProfileImage,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!) as ImageProvider<Object>
                                : AssetImage('lib/Images/profile.webp') as ImageProvider<Object>,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${userData['fname']} ${userData['lname']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '$_username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: const Color.fromARGB(255, 7, 49, 112),
                    ),
                    title: Text('Account Information'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountInformation()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.circle_notifications_rounded,
                      color: const Color.fromARGB(255, 7, 49, 112),
                    ),
                    title: Text('Notification'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.message_rounded,
                      color: const Color.fromARGB(255, 7, 49, 112),
                    ),
                    title: Text('Messages'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MessagesScreen()),
                      );
                    },
                  ),
                  
                  ListTile(
                    leading: Icon(
                      Icons.contact_support_rounded,
                      color: const Color.fromARGB(255, 7, 49, 112),
                    ),
                    title: Text('Contact Admin'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: const Color.fromARGB(255, 7, 49, 112),
                    ),
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout_rounded,
                      color: const Color.fromARGB(255, 7, 49, 112),
                    ),
                    title: Text('Logout'),
                    onTap: () async {
                      await _logout(context);
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: _isLoading // Check loading state before rendering profiles
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController, // Use the search controller
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Search Handyman',
                            suffixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 250,
                          autoPlay: true,
                          enlargeCenterPage: true,
                        ),
                        items: [
                          // Add carousel items here
                          'https://via.placeholder.com/400x200?text=Slide+1',
                          'https://via.placeholder.com/400x200?text=Slide+2',
                          'https://via.placeholder.com/400x200?text=Slide+3',
                        ].map((item) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(item),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Available Handymen',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        itemCount: filteredProfiles.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(), // Prevent scrolling
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16.0),
                              leading: CircleAvatar(
                                backgroundImage: filteredProfiles[index]['imageUrl'] != null
                                    ? NetworkImage(filteredProfiles[index]['imageUrl'])
                                    : AssetImage('https://via.placeholder.com/400x200?text=Profile') as ImageProvider<Object>,
                              ),
                              title: Text(filteredProfiles[index]['name']),
                              subtitle: Text('${filteredProfiles[index]['address']}\n${filteredProfiles[index]['handymanType'].join(', ')}'),
                              isThreeLine: true,
                              onTap: () {
                                print('userid :'+_id);
                                print(filteredProfiles[index]['_id']);
                                // Navigate to booking page or details
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BookingForm(
                                    userId: _id ?? '',handymanId:filteredProfiles[index]['_id'],handymanName:filteredProfiles[index]['name'], handymanType: filteredProfiles[index]['handymanType'],
                                  )), 
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
  
}
