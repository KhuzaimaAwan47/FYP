import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class FreelancerDetails extends StatefulWidget {
  final Map<String, dynamic> freelancer;
  const FreelancerDetails({super.key, required this.freelancer,});



  @override
  State<FreelancerDetails> createState() => _FreelancerDetailsState();
  }
  class _FreelancerDetailsState extends State<FreelancerDetails>{
    final double coverHeight = 150;
    final double profileHeight = 130;




  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    var screenWidth = MediaQuery.of(context).size.width;

    // Extract freelancer details from the widget
    final freelancer = widget.freelancer;
    final String firstName = freelancer['first_name'] ?? 'N/A';
    final String lastName = freelancer['last_name'] ?? 'N/A';
    final String headline = freelancer['headline'] ?? 'N/A';
    final String location = freelancer['location'] ?? 'N/A';
    final String skills = freelancer['skills'] ?? 'N/A';
    final String hourlyRate = freelancer['hourly_rate'].toString();
    final String description = freelancer['description'] ?? 'No description available';
    final String profileUrl = freelancer['profileUrl'] ??
        'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'; // Placeholder profile image URL
    final String coverUrl = freelancer['coverUrl'] ??
        'https://reactplay.io/static/media/placeholder_cover.ea7b18e0704561775829.jpg'; // Placeholder cover image


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      title: const Text('Freelancer Details'),
    ),
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
           buildCoverImage(coverUrl),
            Positioned(
              top: top,
            child: buildProfileImage(profileUrl),
            ),
        
          //--------------------------------------------Display Info Section-----------------------------------------------------
        
            Container(
              margin:  EdgeInsets.only(top: 215),
              width: screenWidth,
              //height: 250,
              //color: Colors.black12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: EdgeInsets.only(left: 16.0,),
                    child: Row(
                      children: [
                        Text(firstName,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                        SizedBox(width: 5,),
                        Text(lastName,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                   Padding(
                    padding: EdgeInsets.only(left: 16.0,right: 16),
                    child: Text(headline,textAlign: TextAlign.justify,style: TextStyle(fontSize: 18,)),
                  ),
                   Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_pin,size: 17,color: Colors.indigoAccent,),
                        Text( location,style: TextStyle(fontSize: 17,color: Colors.black54),),
                        SizedBox(width: 10),
                        Icon(Icons.attach_money,size: 17,color: Colors.indigoAccent,),
                        Text('\$$hourlyRate /hr.',style: TextStyle(fontSize: 17,color: Colors.black54),),
                      ],
                    ),
                  ),
                   Padding(
                    padding: EdgeInsets.only(left: 16.0,right: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.star,size: 17,color: Colors.indigoAccent,),
                        Text(skills,style: TextStyle(fontSize: 17,color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0,right: 16.0),
                    child: Text(description,textAlign: TextAlign.justify,style: TextStyle(fontSize: 16,color: Colors.black54),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          style:ElevatedButton.styleFrom(
                            elevation: 2.0,
                            backgroundColor: Colors.indigoAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.14,
                              vertical: 10,
                            ),
                          ),
                          onPressed: (){},
                          child: const Text('Contact Me',style: TextStyle(color: Colors.white),),),
                        SizedBox(width: 15,),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 2.0,
                            backgroundColor: Colors.indigoAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.15,
                              vertical: 10,
                            )
                          ),
                          onPressed: (){},
                          child: const Text('Offer Now',style: TextStyle(color: Colors.white),),),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

   //--------------------------------------------Cover Image-----------------------------------------------------


    // Widget buildCoverImage(String coverUrl) {
    //   return Container(
    //     height: coverHeight,
    //     width: double.infinity,
    //     decoration: BoxDecoration(
    //       color: Colors.grey[300],
    //       image: DecorationImage(
    //       image: NetworkImage(coverUrl),
    //   fit: BoxFit.cover,
    //     ),
    //     ),
    //   );
    // }
    Widget buildCoverImage(String coverUrl) {
      return FutureBuilder(
        future: precacheImage(NetworkImage(coverUrl), context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: coverHeight,
                width: double.infinity,
                color: Colors.grey[300],
              ),
            );
          } else {
            return Container(
              height: coverHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: DecorationImage(
                  image: NetworkImage(coverUrl),
                  fit: BoxFit.cover,
                ),
              ),
            );
          }
        },
      );
    }
   //--------------------------------------------Profile Image-----------------------------------------------------

    Widget buildProfileImage(String profileUrl) => Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: CircleAvatar(
        radius: profileHeight / 2,
        backgroundImage: NetworkImage(profileUrl),
      ),
    );
  }
