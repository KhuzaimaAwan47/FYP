import 'package:flutter/material.dart';
import 'freelancer_card.dart';

class FreelancerList extends StatelessWidget {
  final List<Map<String, dynamic>> freelancers;

  const FreelancerList({super.key, required this.freelancers});

  @override
  Widget build(BuildContext context) {
    if (freelancers.isEmpty) {
      return const Center(child: Text('No freelancers found'));
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: freelancers.length,
        itemBuilder: (context, index) {
          final freelancer = freelancers[index];
          return FreelancerCard(
            firstName: freelancer['first_name'],
            lastName: freelancer['last_name'],
            headline: freelancer['headline'],
            hourlyRate: freelancer['hourly_rate'].toString(),
            imageUrl: freelancer['profileUrl'] ?? '',
            averageRating: freelancer['averageRating'].toString(),
            totalReviews: freelancer['totalReviews'].toString(),
            location: freelancer['location'] ?? '',
            freelancer: freelancer,
          );
        },
      ),
    );
  }
}
