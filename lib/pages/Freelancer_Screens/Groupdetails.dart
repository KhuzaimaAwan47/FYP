import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_fyp/utlis/snack_bars.dart';
import 'GroupChatPage.dart';

class GroupDetails extends StatefulWidget {
  final String groupId;

  const GroupDetails({super.key, required this.groupId});

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  // Initialize Firebase Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /* --------------------------- Main Build Widget --------------------------- */

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('groups').doc(widget.groupId).snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()));
        }
        // Error or group not found
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text('Group not found')));
        }

        // Extract group data
        Map<String, dynamic> groupData =
            snapshot.data!.data() as Map<String, dynamic>;
        String groupName = groupData['group_name'] ?? 'Unnamed Group';
        String description = groupData['description'] ?? 'No Description';
        String rules = groupData['rules'] ?? 'No Rules';
        String profileImage = groupData['profile_image'] ?? '';
        List members = groupData['members'] is List ? groupData['members'] : [];
        List admins =
            groupData['group_admin'] is List ? groupData['group_admin'] : [];
        String creatorName = groupData['creator_name'] ?? 'Unknown';

        // Current user and role check
        User? currentUser = _auth.currentUser;
        bool isAdmin = admins.contains(currentUser?.email);
        bool isMember = members.contains(currentUser?.email);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Group Details'),
            actions: [
              if (isAdmin)
                PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editGroupDialog(
                          context, groupData, widget.groupId, members, admins);
                    } else if (value == 'delete') {
                      _deleteGroup(context, widget.groupId);
                    } else if (value == 'addAdmin') {
                      _addAdminDialog(context, members, admins, widget.groupId);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, color: Colors.indigo),
                            const SizedBox(width: 4),
                            const Text('Edit Group'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.indigo),
                            const SizedBox(width: 4),
                            const Text('Delete Group'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'addAdmin',
                        child: Row(
                          children: [
                            const Icon(Icons.group_add, color: Colors.indigo),
                            const SizedBox(width: 4),
                            const Text('Add Admin'),
                          ],
                        ),
                      ),
                    ];
                  },
                  offset: const Offset(0, kToolbarHeight),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image with a soft shadow
                    Container(
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]),
                      child: GestureDetector(
                        onTap: () {
                          if (isAdmin) {
                            _editGroupProfileImage(context);
                          }
                        },
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: profileImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[300],
                              ),
                              child: const Icon(Icons.group,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Group Info Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group Name
                          Text(
                            groupName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          // Created By
                          Text(
                            'Created By: $creatorName',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              // Members Button
                              ElevatedButton.icon(
                                onPressed: () => _showMembersDialog(
                                    context, members, admins),
                                icon: const Icon(
                                  Icons.people,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: Text('Members (${members.length})'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.indigoAccent,
                                  textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 5,
                              ),

                              if (isMember)
                                // Chat Button
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GroupChatScreen(
                                          groupId: widget.groupId,
                                          groupName: groupName,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.chat_bubble,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text('Group Chat'),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.indigoAccent,
                                    textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Description
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description Section
                    Card(
                      color: Colors.grey[50],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.grey.shade200, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            RichText(
                              textAlign: TextAlign.justify,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Description: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blueGrey.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: description,
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Rules Section
                    Card(
                      color: Colors.grey[50],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: Colors.grey.shade200, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Rules: ',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade900,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: rules,
                                style: TextStyle(
                                  color: Colors.blueGrey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action Buttons
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: isMember ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: Icon(isMember ? Icons.exit_to_app : Icons.group_add,
                        color: Colors.white),
                    label: Text(
                      isMember ? 'Leave Group' : 'Join Group',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      isMember
                          ? _leaveGroup(
                              context, widget.groupId, currentUser?.email)
                          : _joinGroup(
                              context, widget.groupId, currentUser?.email);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* --------------------------- Pick group profile Method --------------------------- */

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {});
    }
  }

  /* --------------------------- Upload Group Profile Method --------------------------- */

  Future<String?> uploadGroupImage(File image, BuildContext context) async {
    try {
      User? currentUser = _auth.currentUser;
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
    return null;
  }

  /* --------------------------- Edit Group Profile Image Method --------------------------- */

  void _editGroupProfileImage(BuildContext context) async {
    File? selectedImage;
    String? newImageUrl;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Change Group Profile Image'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        selectedImage = File(pickedFile.path);
                        dialogSetState(() {});
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: Text(selectedImage != null
                        ? 'Change Image'
                        : 'Select Image'),
                  ),
                  if (selectedImage != null)
                    Image.file(
                      selectedImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                  ),
                  onPressed: selectedImage == null
                      ? null
                      : () async {
                          newImageUrl =
                              await uploadGroupImage(selectedImage!, context);
                          if (newImageUrl != null) {
                            await _firestore
                                .collection('groups')
                                .doc(widget.groupId)
                                .update({'profile_image': newImageUrl});
                            Navigator.pop(context);
                            showSuccessSnackbar(
                                context, 'Profile image updated successfully!');
                          }
                        },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /* --------------------------- Dialogs --------------------------- */

  // Edit Group Dialog
  void _editGroupDialog(BuildContext context, Map<String, dynamic> groupData,
      String groupId, List<dynamic> members, List<dynamic> admins) {
    TextEditingController groupNameController =
        TextEditingController(text: groupData['group_name']);
    TextEditingController descriptionController =
        TextEditingController(text: groupData['description']);
    TextEditingController rulesController =
        TextEditingController(text: groupData['rules']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit Group'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: groupNameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelText: 'Group Name'),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                maxLines: 3,
                controller: descriptionController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelText: 'Description'),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                maxLines: 3,
                controller: rulesController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelText: 'Rules'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigoAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              await _firestore.collection('groups').doc(groupId).update({
                'group_name': groupNameController.text,
                'description': descriptionController.text,
                'rules': rulesController.text,
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Add Admin Dialog
  void _addAdminDialog(BuildContext context, List<dynamic> members,
      List<dynamic> admins, String groupId) {
    List<String> updatedAdmins =
        List.from(admins); // Temporary list for selections

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Add Admin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchMemberDetails(members),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No members found',
                        style: TextStyle(color: Colors.black54));
                  }

                  return SizedBox(
                    height: 300,
                    width: 350,
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var member = snapshot.data![index];
                        bool isSelected =
                            updatedAdmins.contains(member['email']);

                        return CheckboxListTile(
                          title: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 24,
                                  child: CachedNetworkImage(
                                    imageUrl: member['profileUrl'] ??
                                        'https://via.placeholder.com/150',
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(member['username']),
                              ),
                              // Text(
                              //   member['username'],
                              //   style: const TextStyle(fontSize: 16),
                              // ),
                            ],
                          ),
                          value: isSelected,
                          activeColor: Colors.indigoAccent,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                updatedAdmins.add(member['email']);
                              } else {
                                updatedAdmins.remove(member['email']);
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await _firestore
                        .collection('groups')
                        .doc(groupId)
                        .update({'group_admin': updatedAdmins});
                    Navigator.pop(context);
                    showSuccessSnackbar(context, 'Admins updated successfully');
                  },
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // show members dialog
  void _showMembersDialog(
      BuildContext context, List<dynamic> members, List<dynamic> admins) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Group Members',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              // Member List
              SizedBox(
                height: 300,
                width: 320,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchMemberDetails(members),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No members found',
                              style: TextStyle(color: Colors.black54)));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var member = snapshot.data![index];
                        bool isAdmin = admins.contains(member['email']);

                        return ListTile(
                          leading: GestureDetector(
                              onTap: () {},
                              child: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: member['profileUrl'] != null
                                      ? CircleAvatar(
                                    // backgroundImage: NetworkImage(
                                    //           member['profileUrl']),
                                          radius: 24,
                                    child: CachedNetworkImage(imageUrl: member['profileUrl'],
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                    ),
                                        )
                                      : CircleAvatar(
                                          radius: 20,
                                          child: const Icon(Icons.person,
                                              color: Colors.white),
                                        ))),
                          title: Text(
                            member['username'],
                            style: TextStyle(
                              fontWeight:
                                  isAdmin ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16,
                              color: isAdmin
                                  ? Colors.blue.shade700
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: isAdmin
                              ? const Text(
                                  'Admin',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* --------------------------- Group Related Methods --------------------------- */

  // Join Group Functionality
  Future<void> _joinGroup(
      BuildContext context, String groupId, String? userEmail) async {
    if (userEmail == null) {
      showWarningSnackbar(context, 'You must be logged in to join a group');
      return;
    }
    try {
      DocumentSnapshot groupSnapshot =
          await _firestore.collection('groups').doc(groupId).get();
      List<dynamic> members = groupSnapshot['members'] ?? [];
      if (!members.contains(userEmail)) {
        members.add(userEmail);
        await _firestore
            .collection('groups')
            .doc(groupId)
            .update({'members': members});
        showSuccessSnackbar(context, 'You have joined the group!');
      } else {
        showWarningSnackbar(context, 'You are already a member of this group');
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error joining group: $e');
    }
  }

  // Leave Group Functionality
  Future<void> _leaveGroup(
      BuildContext context, String groupId, String? userEmail) async {
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to leave a group')),
      );
      return;
    }

    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // If user cancels or dismisses the dialog, exit the function
    if (confirm != true) return;

    try {
      DocumentSnapshot groupSnapshot =
          await _firestore.collection('groups').doc(groupId).get();
      List<dynamic> members = groupSnapshot['members'] ?? [];
      List<dynamic> admins = groupSnapshot['group_admin'] ?? [];

      if (members.contains(userEmail)) {
        members.remove(userEmail);
        if (admins.contains(userEmail)) {
          admins.remove(userEmail);
        }
        await _firestore.collection('groups').doc(groupId).update({
          'members': members,
          'group_admin': admins,
        });
        showSuccessSnackbar(context, 'You left the group!');
      } else {
        showWarningSnackbar(context, 'You are not a member of this group');
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error leaving group: $e');
    }
  }

  // Delete Group Functionality
  Future<void> _deleteGroup(BuildContext context, String groupId) async {
    // Confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this group?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _firestore.collection('groups').doc(groupId).delete();
        showSuccessSnackbar(context, 'Group deleted successfully!');
        Navigator.pop(context);
      } catch (e) {
        showErrorSnackbar(context, 'Error deleting group: $e');
      }
    }
  }

  // Fetch member details (email + username)
  Future<List<Map<String, dynamic>>> _fetchMemberDetails(
      List<dynamic> memberEmails) async {
    List<Map<String, dynamic>> memberDetails = [];
    try {
      for (String email in memberEmails) {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        if (snapshot.docs.isNotEmpty) {
          var userData = snapshot.docs.first.data() as Map<String, dynamic>;
          String username = userData['username'];
          String? profileUrl = userData['profileUrl']; // Get from Firestore
          memberDetails.add({
            'email': email,
            'username': username,
            'profileUrl': profileUrl,
          });
        }
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error fetching member details: $e');
    }
    return memberDetails;
  }
}
