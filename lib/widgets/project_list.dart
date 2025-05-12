import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'project_card.dart';

class ProjectList extends StatelessWidget {
  const ProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('projects').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No projects available'));
          }
          final projectDocs = snapshot.data!.docs;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: projectDocs.length,
            itemBuilder: (context, index) {
              var projectData = projectDocs[index].data() as Map<String, dynamic>;
              String projectId = projectDocs[index].id;
              String projectName = projectData['project_name'] ?? 'Unnamed Project';
              String description = projectData['description'] ?? 'No Description';
              String ownerName = projectData['owner_name'] ?? 'Unknown';
              double budget = (projectData['budget'] is int)
                  ? (projectData['budget'] as int).toDouble()
                  : projectData['budget'] ?? 0.0;
              String postedById = projectData['posted_by'] ?? 'Unknown User';
              return ProjectCard(
                projectName: projectName,
                budget: budget,
                description: description,
                projectId: projectId,
                postedById: postedById,
                ownerName: ownerName,
              );
            },
          );
        },
      ),
    );
  }
}