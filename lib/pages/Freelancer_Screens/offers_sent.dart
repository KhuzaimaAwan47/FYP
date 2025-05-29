import 'package:flutter/material.dart';

// This is offers sent page that shows all offers that are sent by current user.
class OffersSent extends StatefulWidget {
  final List<Map<String, dynamic>> offers;
  const OffersSent({super.key, required this.offers});

  @override
  State<OffersSent> createState() => _OffersSentState();
}

class _OffersSentState extends State<OffersSent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Offers Sent')),
      body: widget.offers.isEmpty
          ? const Center(child: Text('No offers sent.'))
          : ListView.builder(
        itemCount: widget.offers.length,
        itemBuilder: (context, index) {
          final offers = widget.offers[index];
          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.grey[100],
            child: ListTile(
              leading: Icon(Icons.assignment_outlined,size: 30,color: Colors.indigoAccent,),
              title: Text(offers['project_name'] ?? 'Unknown Project'),
              subtitle: Text('Recipient: ${offers['assigned_to']}'),
            ),
          );
        },
      ),
    );
  }
}