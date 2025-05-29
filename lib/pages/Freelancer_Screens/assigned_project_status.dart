import 'package:flutter/material.dart';

class ProjectStatus extends StatefulWidget {
  final String status;
  final List<Map<String, dynamic>> projects;
  const ProjectStatus({super.key, required this.status, required this.projects});

  @override
  State<ProjectStatus> createState() => _ProjectStatusState();

}
class _ProjectStatusState extends State<ProjectStatus> {

  void _showProjectDetails(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
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
                        style: TextStyle(fontSize:25,fontWeight: FontWeight.w500),
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
                  leading: const Icon(Icons.person_outline,color: Colors.indigoAccent,),
                  title: Text(project['owner_name'] ?? 'N/A'),
                  subtitle: const Text('Owner'),
                ),
                if (project['budget'] != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.attach_money,color: Colors.indigoAccent,),
                    title: Text('\$${project['budget']}'),
                    subtitle: const Text('Budget'),
                  ),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline,color: Colors.indigoAccent,),
                  title: Text(project['project_status'] ?? 'N/A'),
                  subtitle: const Text('Status'),
                ),
                if (project['project_status'] == 'Completed') ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.local_atm_outlined,color: Colors.indigoAccent,),
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
                const SizedBox(height: 16),
                if (project['project_status'] == 'Completed') ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Make Payment'),
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
      appBar: AppBar(
        title: Text('${widget.status} Projects'),
      ),
      body: widget.projects.isEmpty
          ? const Center(child: Text('No projects found.'))
          : ListView.builder(
        itemCount: widget.projects.length,
        itemBuilder: (context, index) {
          final project = widget.projects[index];
          return GestureDetector(
            onTap: () => _showProjectDetails(project),
            child: Card(
              margin: const EdgeInsets.only(left: 16,right: 16,top: 5,bottom: 5),
              elevation: 0,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.assignment_outlined,size: 30,color: Colors.indigoAccent,),
                title: Text(project['project_name'] ?? 'No Title',style: TextStyle(fontWeight: FontWeight.w500),),
                subtitle: Text('Posted By: ${project['owner_name']}',style: TextStyle(color: Colors.grey[700]),),
                trailing: Text('${project['project_status']}',style: TextStyle(fontWeight: FontWeight.w500),),
              ),
            ),
          );
        },
      ),
    );
  }
}

