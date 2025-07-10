import 'package:flutter/material.dart';

// This is offers sent page that shows all offers that are sent by current user.
class OffersSent extends StatefulWidget {
  final List<Map<String, dynamic>> offers;

  const OffersSent({super.key, required this.offers});

  @override
  State<OffersSent> createState() => _OffersSentState();
}

class _OffersSentState extends State<OffersSent> {
  /* --------------------------- Show Offers Details Method --------------------------- */

  void _showOfferDetails(BuildContext context, Map<String, dynamic> offer) {
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
              padding: EdgeInsets.all(16.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            offer['project_name'] ?? 'No Title',
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: Navigator.of(context).pop,
                        ),
                      ],
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.person_outline,
                        color: Colors.indigoAccent,
                      ),
                      title: Text(offer['owner_name'] ?? 'N/A'),
                      subtitle: const Text('Owner'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.person_outline,
                        color: Colors.indigoAccent,
                      ),
                      title: Text(offer['assigned_to'] ?? 'N/A'),
                      subtitle: const Text('Recipient'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.attach_money,
                        color: Colors.indigoAccent,
                      ),
                      title: Text('\$${offer['budget']}'),
                      subtitle: const Text('Budget'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.info_outline,
                        color: Colors.indigoAccent,
                      ),
                      title: Text(offer['project_status'] ??
                          offer['project_status'] ??
                          'N/A'),
                      subtitle: const Text('Status'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.timer_outlined,
                        color: Colors.indigoAccent,
                      ),
                      title: Text(offer['estimated_time'] ??
                          offer['estimated_time'] ??
                          'N/A'),
                      subtitle: const Text('Estimated Time'),
                    ),
                    if ((offer['project_status'] ?? offer['project_status']) ==
                        'Completed')
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.local_atm_outlined,
                          color: Colors.indigoAccent,
                        ),
                        title: Text(offer['payment_status'] ?? 'N/A'),
                        subtitle: const Text('Payment Status'),
                      )
                  ]),
            ),
          );
        });
  }

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
                return GestureDetector(
                  onTap: () {
                    _showOfferDetails(context, offers);
                  },
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
                      title: Text(offers['project_name'] ?? 'Unknown Project'),
                      subtitle: Text('Recipient: ${offers['assigned_to']}'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
