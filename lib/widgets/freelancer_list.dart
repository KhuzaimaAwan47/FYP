import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'freelancer_card.dart';

class FreelancerList extends StatelessWidget {
  const FreelancerList({super.key});

  Future<List<Map<String, dynamic>>> _fetchFreelancers() async {
    User? loggedInUser = FirebaseAuth.instance.currentUser;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'freelancer')
        .get();

    List<Map<String, dynamic>> freelancers = snapshot.docs
        .where((doc) => doc['email'] != loggedInUser?.email)
        .map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
    return freelancers;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFreelancers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.indigoAccent));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading freelancers'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No freelancers found'));
          }

          final freelancers = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: freelancers.length,
            itemBuilder: (context, index) {
              final freelancer = freelancers[index];
              return FreelancerCard(
                firstName: freelancer['first_name'],
                lastName: freelancer['last_name'],
                headline: freelancer['headline'],
                hourlyRate: freelancer['hourly_rate'].toString(),
                imageUrl: freelancer['profileUrl'],
                averageRating: freelancer['averageRating'].toString(),
                totalReviews: freelancer['totalReviews'].toString(),
                location: freelancer['location'],
                freelancer: freelancer,
              );
            },
          );
        },
      ),
    );
  }
}
