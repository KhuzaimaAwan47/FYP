import 'package:flutter/material.dart';
import '../pages/Freelancer_Screens/Freelancerdetails.dart';


class FreelancerCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String headline;
  final String hourlyRate;
  final String imageUrl;
  final String averageRating;
  final String totalReviews;
  final String location;
  final Map<String, dynamic> freelancer;

  const FreelancerCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.headline,
    required this.hourlyRate,
    required this.imageUrl,
    required this.freelancer,
    required this.averageRating,
    required this.totalReviews,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FreelancerDetails(freelancer: freelancer),
          ),
        );
      },
      child: Card(
        color: Colors.grey[50],
        shadowColor: Colors.grey[300],
        elevation: 1,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
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
                    child: Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $lastName',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.attach_money,
                                color: Colors.indigoAccent, size: 18),
                            Text('\$$hourlyRate/hr',
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.indigoAccent, size: 18),
                            Text(location,
                                style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  RichText(
                    overflow: TextOverflow.fade,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: averageRating,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextSpan(
                          text: '/5',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        TextSpan(
                          text: ' ($totalReviews Review)',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                headline,
                maxLines: 1,
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
