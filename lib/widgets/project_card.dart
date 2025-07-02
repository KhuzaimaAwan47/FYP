import 'package:flutter/material.dart';
import '../pages/Freelancer_Screens/Projectdetails.dart';

class ProjectCard extends StatelessWidget {
  final String projectName;
  final double budget;
  final String description;
  final String projectId;
  final String postedById;
  final String ownerName;

  const ProjectCard({
    super.key,
    required this.projectName,
    required this.budget,
    required this.description,
    required this.projectId,
    required this.postedById,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetails(
              projectId: projectId,
              postedById: postedById,
              projectName: projectName,
            ),
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
                  const Icon(Icons.assignment, size: 50, color: Colors.black87),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.attach_money,
                                size: 18, color: Colors.indigoAccent),
                            Text(' \$${budget.toStringAsFixed(1)}',
                                style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.person_2_rounded,
                                size: 18, color: Colors.indigoAccent),
                            Text(' $ownerName',
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
