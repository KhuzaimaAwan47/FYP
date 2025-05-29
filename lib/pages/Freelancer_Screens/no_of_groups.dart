import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// This page shows number of groups created by current user.
class NoOfGroups extends StatefulWidget {
  final List<Map<String, dynamic>> groups;

  const NoOfGroups({super.key, required this.groups});

  @override
  State<NoOfGroups> createState() => _NoOfGroupsState();
}

class _NoOfGroupsState extends State<NoOfGroups> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Groups Created')),
      body: widget.groups.isEmpty
          ? const Center(child: Text('No groups found.'))
          : ListView.builder(
              itemCount: widget.groups.length,
              itemBuilder: (context, index) {
                final group = widget.groups[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.grey[100],
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: CachedNetworkImage(
                        imageUrl: group['profile_image'] ??
                            'https://via.placeholder.com/150 ',
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    title: Text(group['group_name'] ?? 'Group'),
                    subtitle: Text(
                      group['description'] ?? 'Description',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
