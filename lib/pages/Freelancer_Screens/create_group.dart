import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_fyp/utlis/snack_bars.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({
    super.key,
  });

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
          return;
        }
      } catch (e) {
        return;
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
      return;
    }
  }

  Future<void> createGroup() async {
    try {
      String groupName = groupNameController.text;
      String groupDescription = groupDescriptionController.text;
      String groupRules = groupRulesController.text;

      if (groupName.isEmpty || groupDescription.isEmpty || groupRules.isEmpty) {
        showWarningSnackbar(context, 'Please fill all fields!');
        return;
      }
      if (_profileImage == null) {
        showErrorSnackbar(context, 'Please Select a Group Profile Image!');
        return;
      }

      User? user = _auth.currentUser;
      if (user == null) {
        return;
      }

      List<String> groupMembers = [userEmail];
      imageUrl = await uploadGroupImage(_profileImage!);

      await _firestore.collection('groups').add({
        'group_name': groupName,
        'description': groupDescription,
        'rules': groupRules,
        'members': groupMembers,
        'members_count': groupMembers.length,
        'created_by': user.uid,
        'creator_name': userName,
        'group_admin': [userEmail],
        'profile_image': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTimestamp': null,
      });
      showSuccessSnackbar(context, 'Group created successfully!');
      Navigator.pop(context);
    } catch (e) {
      return;
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
      } else {}
    } catch (e) {
      showErrorSnackbar(context, 'Failed to upload image: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Group'),
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
                        Icons.add_a_photo,
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
              maxLines: 5,
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
              maxLines: 5,
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            minimumSize: Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: createGroup,
          label: const Text(
            'Create',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          icon: const Icon(
            Icons.group_add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
