// Advanced Search Filters Widget
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_fyp/pages/Freelancer_Screens/Projectdetails.dart';

import 'Freelancerdetails.dart';
import 'Groupdetails.dart';

class Search extends StatefulWidget {
  final String userEmail;
  const Search({super.key, required this.userEmail});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late TextEditingController searchController;
  List<DocumentSnapshot> freelancers = [];
  List<DocumentSnapshot> projects = [];
  List<DocumentSnapshot> groups = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    // Perform initial search
  }

  Future<void> performSearch(Map<String, dynamic> filters) async {
    try {
      Query freelancerQuery = FirebaseFirestore.instance.collection('users') .where('userType', isEqualTo: 'freelancer');
      Query projectQuery = FirebaseFirestore.instance.collection('projects');
      Query groupQuery = FirebaseFirestore.instance.collection('groups');

      // Apply hourly rate filter
      if (filters['hourlyRate'] != null) {
        freelancerQuery = freelancerQuery.where(
            'hourly_rate',
            isLessThanOrEqualTo: filters['hourlyRate']);
      }

      final freelancerSnapshot = await freelancerQuery.get();
      List<DocumentSnapshot> filteredFreelancers = freelancerSnapshot.docs;

      // Exclude current user from freelancers list
      filteredFreelancers = filteredFreelancers
          .where((doc) => doc['email'] != widget.userEmail)
          .toList();

      // Apply project budget filter
      if (filters['projectBudget'] != null) {
        projectQuery = projectQuery.where('budget',
            isLessThanOrEqualTo: filters['projectBudget']);
        final projectSnapshot = await projectQuery.get();
        projects = projectSnapshot.docs;
      } else {
        projects = [];
      }

      // Apply group members filter
      if (filters['groupMembers'] != null) {
        groupQuery = groupQuery.where('members_count',
            isLessThanOrEqualTo: filters['groupMembers']);
        final groupSnapshot = await groupQuery.get();
        groups = groupSnapshot.docs;
      } else {
        groups = [];
      }

      setState(() {
        freelancers = filteredFreelancers;
        projects = projects;
        groups = groups;
      });

      print(freelancers);
      print(projects);
      print(groups);
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final filterData = await showModalBottomSheet(
                  context: context,
                  builder: (context) => const AdvancedSearchFilters(),
                );
                if (filterData != null) {
                  await performSearch(filterData);
                }
              },
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey,size: 30),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "Search freelancers, groups, & projects",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: freelancers.isEmpty && projects.isEmpty && groups.isEmpty
                  ? const Center(child: Text('No results found.'))
                  : ListView(
                children: [
                  if (freelancers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Freelancers', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...freelancers.map((doc) => Card(
                          color: Colors.grey[100],
                          elevation: 0,
                          child: ListTile(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FreelancerDetails(freelancer: doc.data() as Map<String, dynamic>),
                                ),
                              );
                            },
                            leading: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: doc['profileUrl'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                            title: Text(doc['username'],style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text('\$${doc['hourly_rate']}/hr'),
                            trailing: Icon(Icons.arrow_forward_ios,color: Colors.grey,)
                          ),
                        )),
                      ],
                    ),
                  if (projects.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Projects', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...projects.map((doc) => Card(
                          elevation: 0,
                          color: Colors.grey[100],
                          child: ListTile(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetails(
                                    projectId: doc.id,
                                    projectName: doc['project_name'],
                                    postedById: doc['posted_by'],
                                  ),
                                ),
                              );
                            },
                            leading: Icon(Icons.assignment_outlined, color: Colors.indigo,size: 30,),
                            title: Text(doc['project_name'],style: TextStyle(fontWeight: FontWeight.w500),),
                            subtitle: Text('\$${doc['budget']}'),
                            trailing: Icon(Icons.arrow_forward_ios,color: Colors.grey,),
                          ),
                        )),
                      ],
                    ),
                  if (groups.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Groups', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...groups.map((doc) => Card(
                          color: Colors.grey[100],
                          elevation: 0,
                          child: ListTile(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupDetails(groupId: doc.id),
                                ),
                              );
                            },
                            leading: ClipOval(
                              child: CachedNetworkImage(imageUrl: doc['profile_image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                            title: Text(doc['group_name'],style: TextStyle(fontWeight: FontWeight.w500),),
                            subtitle: Text('${doc['members_count']} members'),
                            trailing: Icon(Icons.arrow_forward_ios,color: Colors.grey,),
                          ),
                        )),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdvancedSearchFilters extends StatefulWidget {
  const AdvancedSearchFilters({super.key});

  @override
  _AdvancedSearchFiltersState createState() => _AdvancedSearchFiltersState();
}

class _AdvancedSearchFiltersState extends State<AdvancedSearchFilters> {
  double hourlyRate = 0;
  double projectBudget = 0;
  double groupMembers = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Advanced Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Text('Search Freelancers by Hourly Rate: \$${hourlyRate.toInt()}',
          style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
          ),
          Slider(
            activeColor: Colors.indigo,
            value: hourlyRate,
            min: 0,
            max: 100,
            divisions: 20,
            label: hourlyRate.round().toString(),
            onChanged: (value) => setState(() => hourlyRate = value),
          ),

          const SizedBox(height: 10),
          Text('Search Projects According to Budget: \$${projectBudget.toInt()}',
            style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
          ),
          Slider(
            activeColor: Colors.indigo,
            value: projectBudget,
            min: 0,
            max: 1000,
            divisions: 20,
            label: projectBudget.round().toString(),
            onChanged: (value) => setState(() => projectBudget = value),
          ),

          const SizedBox(height: 10),
          Text('Search Groups According to Group Members: ${groupMembers.toInt()}',
            style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
          ),
          Slider(
            activeColor: Colors.indigo,
            value: groupMembers,
            min: 0,
            max: 50,
            divisions: 10,
            label: groupMembers.round().toString(),
            onChanged: (value) => setState(() => groupMembers = value),
          ),

          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context, {
                'hourlyRate': hourlyRate,
                'projectBudget': projectBudget,
                'groupMembers': groupMembers,
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )
            ),
            label: const Text('Search', style: TextStyle(color: Colors.white)),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }
}