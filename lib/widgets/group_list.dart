import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'group_card.dart';

class GroupList extends StatelessWidget {
  const GroupList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No groups available'));
          }
          final groupDocs = snapshot.data!.docs;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: groupDocs.length,
            itemBuilder: (context, index) {
              var groupData = groupDocs[index].data() as Map<String, dynamic>;
              String groupId = groupDocs[index].id;
              String groupName = groupData['group_name'] ?? 'Unnamed Group';
              String description = groupData['description'] ?? 'No Description';
              String ownerName = groupData['creator_name'] ?? 'Unknown';
              String postedById = groupData['created_by'] ?? 'Unknown User';
              String profileImage = groupData['profile_image'];
              String members =
                  (groupData['members'] as List<dynamic>?)?.length.toString() ??
                      '0';
              return GroupCard(
                groupId: groupId,
                groupName: groupName,
                description: description,
                postedById: postedById,
                ownerName: ownerName,
                profileImage: profileImage,
                members: members,
              );
            },
          );
        },
      ),
    );
  }
}