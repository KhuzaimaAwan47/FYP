import 'package:cached_network_image/cached_network_image.dart';
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
                    child: CachedNetworkImage(
                      imageUrl: profileImage,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: Center(child: const CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    )
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
                            const Icon(Icons.person_2_rounded,
                                size: 15, color: Colors.indigoAccent),
                            const SizedBox(width: 5),
                            Text(' $ownerName',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.group,
                                size: 18, color: Colors.indigoAccent),
                            const SizedBox(width: 5),
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
              Text(
                description,
                maxLines: 3,
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
