import 'package:flutter/material.dart';
import '../pages/Freelancer_Screens/Groupdetails.dart';

class GroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String description;
  final String postedById;
  final String ownerName;
  final String profileImage;
  final String members;

  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.description,
    required this.postedById,
    required this.ownerName,
    required this.profileImage,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetails(groupId: groupId),
          ),
        );
      },
      child: Card(
        color: Colors.grey[50],
        shadowColor: Colors.grey[400],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 1,
        margin: const EdgeInsets.all(8.0),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      profileImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.group,
                                size: 15, color: Colors.grey),
                            Text('Members: $members',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey[300], thickness: 1, height: 1),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.person_2_rounded,
                      size: 15, color: Colors.grey),
                  Text('Created By: $ownerName',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
