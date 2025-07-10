import 'package:flutter/material.dart';

class NoOfPostedProjects extends StatefulWidget {
  final List<Map<String, dynamic>> projects;

  const NoOfPostedProjects({super.key, required this.projects});

  @override
  State<NoOfPostedProjects> createState() => NoOfPostedProjectsState();
}

class NoOfPostedProjectsState extends State<NoOfPostedProjects> {
  void _showProjectDetails(Map<String, dynamic> project) {
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
                        project['project_name'] ?? 'No Title',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.indigoAccent,
                  ),
                  title: Text(project['owner_name'] ?? 'N/A'),
                  subtitle: const Text('Owner'),
                ),
                if (project['budget'] != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.attach_money,
                      color: Colors.indigoAccent,
                    ),
                    title: Text('\$${project['budget']}'),
                    subtitle: const Text('Budget'),
                  ),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.info_outline,
                    color: Colors.indigoAccent,
                  ),
                  title: Text(project['project_status'] ?? 'N/A'),
                  subtitle: const Text('Status'),
                ),
                if (project['project_status'] == 'Completed') ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.local_atm_outlined,
                      color: Colors.indigoAccent,
                    ),
                    title: Text('${project['payment_status']}'),
                    subtitle: Text('Payment Status'),
                  )
                ],
                if (project['description'] != null) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      project['description'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Posted Projects')),
      body: widget.projects.isEmpty
          ? const Center(child: Text('No projects posted.'))
          : ListView.builder(
              itemCount: widget.projects.length,
              itemBuilder: (context, index) {
                final projects = widget.projects[index];
                return GestureDetector(
                  onTap: () => _showProjectDetails(projects),
                  child: Card(
                    margin: const EdgeInsets.only(
                        left: 16, right: 16, top: 4, bottom: 4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.grey[100],
                    child: ListTile(
                      leading: Icon(
                        Icons.assignment_outlined,
                        size: 30,
                        color: Colors.indigoAccent,
                      ),
                      title:
                          Text(projects['project_name'] ?? 'Unknown Project'),
                      subtitle: Text(
                          'Status: ${projects['project_status'] ?? 'Unknown'}'),
                      trailing: Text('\$${projects['budget']}'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
