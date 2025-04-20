import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<StatefulWidget> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController =
      TextEditingController();
  final TextEditingController groupRulesController = TextEditingController();
  final TextEditingController groupMembersController = TextEditingController();
  File? _profileImage;
  String? imageUrl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userName = '';
  String userEmail = '';
  List<String> groupMembers = [];
  List<Map<String, dynamic>> freelancersList = [];
  List<String> selectedFreelancerEmails = [];
  List<String> selectedFreelancerUsernames = [];

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
    _fetchFreelancers();
  }

  Future<void> loadCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            userName = userDoc['username'];
            userEmail = userDoc['email'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User name not found!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future _fetchFreelancers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'freelancer')
          .get();

      List<Map<String, String>> freelancers = [];
      User? currentUser = _auth.currentUser;

      for (var doc in snapshot.docs) {
        Map data = doc.data() as Map;
        String email = data['email'];
        String username = data['username'];

        // Exclude the current user from the list
        if (currentUser != null && email != currentUser.email) {
          freelancers.add({
            'email': email,
            'username': username,
          });
        }
      }

      setState(() {
        freelancersList = freelancers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching freelancers: $e')),
      );
    }
  }

  Future<void> createGroup() async {
    try {
      String groupName = groupNameController.text;
      String groupDescription = groupDescriptionController.text;
      String groupRules = groupRulesController.text;

      if (groupName.isEmpty || groupDescription.isEmpty || groupRules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
            duration: Duration(seconds: 3),
            content: Text('Please fill all fields!'),
          ),
        );
        return;
      }

      User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in!')),
        );
        return;
      }

      Set<String> allMembers = Set.from(
          selectedFreelancerEmails.where((email) => userEmail.isNotEmpty));
      if (userEmail.isNotEmpty) {
        allMembers.add(userEmail);
      }
      groupMembers = allMembers.toList();

      if (_profileImage != null) {
        // Upload image to Firebase Storage and get the URL
        // Add Firebase Storage implementation here if needed
        imageUrl = await uploadGroupImage(
            _profileImage!); // Replace this with actual URL after upload
      }

      await _firestore.collection('groups').add({
        'group_name': groupName,
        'description': groupDescription,
        'rules': groupRules,
        'members': groupMembers,
        'created_by': user.uid,
        'creator_name': userName,
        'group_admin': [userEmail],
        'profile_image': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
          content: Text('Group created successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadGroupImage(File image) async {
    try {
      User? currentUser = _auth.currentUser; // Get the current user
      if (currentUser != null) {
        String userId = currentUser.uid;
        Reference reference = FirebaseStorage.instance
            .ref()
            .child("group_profileImages/$userId/Group_Profile.png");
        await reference.putFile(image);
        return await reference.getDownloadURL();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No user is logged in!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to upload image: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Group'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickProfileImage,
              child: CircleAvatar(
                backgroundColor: Colors.indigo.shade50,
                radius: 60,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.grey,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              style: TextStyle(fontWeight: FontWeight.w500),
              controller: groupNameController,
              decoration: InputDecoration(
                hintText: 'Group Name',
                hintStyle: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.normal),
                prefixIcon: Icon(
                  Icons.group_add_outlined,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: groupDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                label: Text('Group Description'),
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
                hintText: 'Group Description',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: groupRulesController,
              maxLines: 3,
              decoration: InputDecoration(
                label: Text('Group Rules'),
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Group Rules',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            const Text('Select Members:', style: TextStyle(fontSize: 16)),
            SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: Colors.grey),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: freelancersList.length,
                  itemBuilder: (context, index) => CheckboxListTile(
                    title: Text(freelancersList[index]['email']),
                    value: selectedFreelancerEmails
                        .contains(freelancersList[index]['email']),
                    onChanged: (value) => setState(() {
                      if (value!) {
                        selectedFreelancerEmails
                            .add(freelancersList[index]['email']);
                      } else {
                        selectedFreelancerEmails
                            .remove(freelancersList[index]['email']);
                      }
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Column(
              children: [
                if (userEmail.isNotEmpty ||
                    selectedFreelancerEmails
                        .isNotEmpty) // Conditionally render Wrap
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      if (userEmail.isNotEmpty) // Display current user's email
                        Chip(label: Text(userEmail)),
                      ...selectedFreelancerEmails
                          .map((email) => Chip(
                                label: Text(email),
                                onDeleted: () => setState(() =>
                                    selectedFreelancerEmails.remove(email)),
                              ))
                          .toList(),
                    ],
                  ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: createGroup,
              child: const Text(
                'Create',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}