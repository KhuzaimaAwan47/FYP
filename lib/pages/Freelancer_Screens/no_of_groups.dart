import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as TimeAgo;

// This page shows number of groups created by current user.
class NoOfGroups extends StatefulWidget {
  final List<Map<String, dynamic>> groups;

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    return TimeAgo.format(timestamp.toDate());
  }

  const NoOfGroups({super.key, required this.groups});

  @override
  State<NoOfGroups> createState() => _NoOfGroupsState();
}

/* --------------------------- Show Group Details Method --------------------------- */

void _showGroupDetails(
    BuildContext context, Map<String, dynamic> group, NoOfGroups widget) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group['group_name'] ?? 'No Title',
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: Navigator.of(context).pop,
                  ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline,
                    color: Colors.indigoAccent),
                title: Text(group['creator_name'] ?? 'N/A'),
                subtitle: const Text('Owner'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timer_outlined,
                    color: Colors.indigoAccent),
                title: Text(widget.formatTimestamp(group['created_at'])),
                subtitle: const Text('Created At'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.group_outlined,
                    color: Colors.indigoAccent),
                title: Text((group['members'] is List)
                    ? group['members'].length.toString()
                    : '0'),
                subtitle: const Text('Members'),
              ),
              if (group['description'] != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    group['description'],
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
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
                return GestureDetector(
                  onTap: () {
                    _showGroupDetails(context, group, widget);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(
                        left: 16, right: 16, top: 4, bottom: 4),
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
                        trailing: Text(
                          widget.formatTimestamp(group['created_at']),
                          style: const TextStyle(color: Colors.grey),
                        )),
                  ),
                );
              },
            ),
    );
  }
}
