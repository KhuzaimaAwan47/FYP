import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupDetails extends StatelessWidget {
  final String groupId;

  const GroupDetails({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Details'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('groups').doc(groupId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Group not found'));
          }

          // Extract group data
          Map<String, dynamic> groupData =
          snapshot.data!.data() as Map<String, dynamic>;
          String groupName = groupData['group_name'] ?? 'Unnamed Group';
          String description = groupData['description'] ?? 'No Description';
          String rules = groupData['rules'] ?? 'No Rules';
          String profileImage = groupData['profile_image'] ?? '';
          List members = (groupData['members'] is List ? groupData['members'] : []) as List;
          //List admins = (groupData['group_admin'] is List ? groupData['group_admin'] : []) as List;
          List admins = groupData['group_admin'] is List ? groupData['group_admin'] : [];
          String createdBy = groupData['created_by'];
          String creatorName = groupData['creator_name'];

          // Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
          // String usertype = userData['user_type'];

          // Check if the current user is the group creator or an admin
          User? currentUser = _auth.currentUser;
          bool isCreator = currentUser?.uid == createdBy;
          bool isAdmin = admins.contains(currentUser?.email);
          bool isMember = members.contains(currentUser?.email);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Center(
                  child: ClipOval(
                    child: Image.network(
                      profileImage,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: const Icon(Icons.group, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Group Name
                Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87
                  ),
                ),
                Text('Created By: $creatorName',style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w500),),

                // Display Admin Usernames
                FutureBuilder<List<String>>(
                  future: _fetchMemberUsernames(admins),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.indigo));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No admins found', style: TextStyle(color: Colors.grey));
                    }
                    List<String> adminUsernames = snapshot.data!;
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Admins: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: adminUsernames.join(", "),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8.0),


                // Description
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:'Description: ',
                        style: TextStyle(fontSize: 16,color: Colors.grey[800],fontWeight: FontWeight.w500),
                      ),
                    TextSpan(text:description,style: TextStyle(color: Colors.grey[800],fontSize: 14) )
                    ]
                  ),
                ),
                const SizedBox(height: 8.0),
                // Rules
                RichText(text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Rules: ',style: TextStyle(color: Colors.grey[800],fontSize: 16,fontWeight: FontWeight.w500)
                    ),
                    TextSpan(
                      text: rules,style: TextStyle(color: Colors.grey[800],fontSize: 14)
                    )
                  ]
                )),
                const SizedBox(height: 8.0),




                // Member Usernames
                FutureBuilder<List<String>>(
                  future: _fetchMemberUsernames(members ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.indigo,));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No members found');
                    }
                    List<String> usernames = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          'Members: ${members.length}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          height: 200, // Set a fixed height for the list
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white54
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: usernames.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade50,
                                  child: Text(usernames[index][0]),
                                ),
                                title: Text(usernames[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // Edit and Delete Buttons in the same line
                if ( isAdmin)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2.0,
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            _editGroupDialog(context, groupData, groupId, members, admins);
                          },
                          child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2.0,
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            _deleteGroup(context, groupId);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 8.0),
                // Join Group Button (For Non-Creator/Non-Member Users)
                if ( !members.contains(currentUser?.email))
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      _joinGroup(groupId, currentUser?.email);
                    },
                    child: const Text('Join Group', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),

                // Leave Group Button (For Members)
                if ( members.contains(currentUser?.email))
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      _leaveGroup(groupId, currentUser?.email);
                    },
                    child: const Text('Leave Group', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fetch usernames of group members
  Future<List<String>> _fetchMemberUsernames(List<dynamic> memberEmails) async {
    try {
      List<String> usernames = [];
      for (String email in memberEmails) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        if (snapshot.docs.isNotEmpty) {
          String username = snapshot.docs.first['username'];
          usernames.add(username);
        }
      }
      return usernames;
    } catch (e) {
      print('Error fetching member usernames: $e');
      return [];
    }
  }

  // Edit Group Dialog
  void _editGroupDialog(BuildContext context, Map<String, dynamic> groupData, String groupId, List<dynamic> members, List<dynamic> admins) {
    TextEditingController groupNameController = TextEditingController(text: groupData['group_name']);
    TextEditingController descriptionController = TextEditingController(text: groupData['description']);
    TextEditingController rulesController = TextEditingController(text: groupData['rules']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addAdminDialog(context, members, admins, groupId);
                },
                child: const Text('Add Admin'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
                'group_name': groupNameController.text,
                'description': descriptionController.text,
                'rules': rulesController.text,
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );


  }

  // Join Group Functionality
  Future<void> _joinGroup(String groupId, String? userEmail) async {
    if (userEmail == null) {
      ScaffoldMessenger.of(Navigator.of(NavigatorState().context).context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to join a group')),
      );
      return;
    }

    try {
      DocumentSnapshot groupSnapshot =
      await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      List<dynamic> members = groupSnapshot['members'] ?? [];
      if (!members.contains(userEmail)) {
        members.add(userEmail);
        await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
          'members': members,
        });
        ScaffoldMessenger.of(Navigator.of(NavigatorState().context).context).showSnackBar(
          const SnackBar(content: Text('You have joined the group!')),
        );
      } else {
        ScaffoldMessenger.of(Navigator.of(NavigatorState().context).context).showSnackBar(
          const SnackBar(content: Text('You are already a member of this group')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(Navigator.of(NavigatorState().context).context).showSnackBar(
        SnackBar(content: Text('Error joining group: $e')),
      );
    }
  }

  // Leave Group Functionality
  Future _leaveGroup(String groupId, String? userEmail) async {
    if (userEmail == null) {
      ScaffoldMessenger.of(Navigator.of(NavigatorState().context).context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to leave a group')),
      );
      return;
    }
    try {
      DocumentSnapshot groupSnapshot =
      await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      List members = groupSnapshot['members'] ?? [];
      List admins = groupSnapshot['group_admin'] ?? [];
      if (members.contains(userEmail)) {
        members.remove(userEmail);
        if(admins.contains(userEmail)){
          admins.remove(userEmail);
        }
        await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
          'members': members,
          'group_admin': admins,
        });
        ScaffoldMessenger.of(Navigator.of(NavigatorState().context).context).showSnackBar(
          const SnackBar(content: Text('You have left the group!')),
        );
      } else {
        ScaffoldMessenger.of(Navigator.of(NavigatorState().context).context).showSnackBar(
          const SnackBar(content: Text('You are not a member of this group')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(Navigator.of(NavigatorState().context).context).showSnackBar(
        SnackBar(content: Text('Error leaving group: $e')),
      );
    }
  }



  // Delete Group Functionality
  Future<void> _deleteGroup(BuildContext context, String groupId) async {
    // Show a confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this group?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if user cancels
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if user confirms
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    // If the user confirms the deletion, proceed with deleting the group
    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Group deleted successfully!')));
        Navigator.pop(context); // Navigate back after deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting group: $e')));
      }
    }
  }

  // Add Admin Dialog
  void _addAdminDialog(BuildContext context, List<dynamic> members, List<dynamic> admins, String groupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Admin'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchMemberDetails(members), // Fetch member details (email + username)
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No members found');
            }

            List<Map<String, dynamic>> memberDetails = snapshot.data!;

            return ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var member in memberDetails)
                      CheckboxListTile(
                        title: Text(member['username']),
                        value: admins.contains(member['username']),
                        onChanged: (value) async {
                          if (value!) {
                            admins.add(member['username']);
                          } else {
                            admins.remove(member['username']);
                          }
                          await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(groupId)
                              .update({'group_admin': admins});
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Fetch member details (email + username) from Firestore
  Future<List<Map<String, dynamic>>> _fetchMemberDetails(List<dynamic> memberEmails) async {
    List<Map<String, dynamic>> memberDetails = [];
    try {
      for (String email in memberEmails) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        if (snapshot.docs.isNotEmpty) {
          String username = snapshot.docs.first['username'];
          memberDetails.add({
            'email': email,
            'username': username,
          });
        }
      }
    } catch (e) {
      print('Error fetching member details: $e');
    }
    return memberDetails;
  }
}