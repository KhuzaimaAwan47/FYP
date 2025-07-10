import 'package:flutter/material.dart';

class NoOfBidsReceived extends StatefulWidget{
  final List<Map<String, dynamic>> bids;
  const NoOfBidsReceived({super.key,
    required this.bids});

  @override
  State<StatefulWidget> createState() => _NoOfBidsReceivedState();

}
class _NoOfBidsReceivedState extends State<NoOfBidsReceived>{

  /* --------------------------- Show Bids Details Method Method --------------------------- */
  void _showBidDetails(BuildContext context, Map<String, dynamic> bid) {
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(
                      bid['project_name'] ?? 'No Title',
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: Navigator.of(context).pop,
                  ),
                ]),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.indigoAccent,
                  ),
                  title: Text(bid['owner_name'] ?? 'N/A'),
                  subtitle: const Text('Owner'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.indigoAccent,
                  ),
                  title: Text(bid['bidder_name'] ?? 'N/A'),
                  subtitle: const Text('Bidder'),
                ),
                if (bid['bid_amount'] != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.attach_money,
                      color: Colors.indigoAccent,
                    ),
                    title: Text('\$ ${bid['bid_amount']}'),
                    subtitle: const Text('Bid Amount'),
                  ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.info_outline,
                    color: Colors.indigoAccent,
                  ),
                  title: Text(bid['status'] ?? bid['status'] ?? 'N/A'),
                  subtitle: const Text('Bid Status'),
                ),
                if (bid['project_status'] != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.indigoAccent,
                    ),
                    title: Text(bid['project_status'] ?? 'N/A'),
                    subtitle: const Text('Project Status'),
                  ),
                if (bid['message'] != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.message_outlined,
                      color: Colors.indigoAccent,
                    ),
                    title: Text(bid['message'] ?? 'N/A',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),),
                  ),

                if (bid['description'] != null) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      bid['description'],
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.grey[700]),
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
      appBar: AppBar(title: const Text('Bids Received')),
      body: widget.bids.isEmpty
          ? const Center(child: Text('No bids found.'))
          : ListView.builder(
        itemCount: widget.bids.length,
        itemBuilder: (context, index) {
          final bids = widget.bids[index];
          return GestureDetector(
            onTap: () {
              _showBidDetails(context, bids);
            },
            child: Column(
              children: [
                Card(
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
                    title: Text(bids['project_name'] ?? 'Unknown Project',style: const TextStyle(fontWeight: FontWeight.w500),),
                    subtitle: Text('You ${bids['status'] ?? 'Unknown'} this \$${bids['bid_amount']} bid.',overflow: TextOverflow.ellipsis),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (bids['project_status'] == 'Completed')
                          Flexible(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigoAccent,
                                ),
                                onPressed: (){},
                                child: const Text('Make Payment',style: TextStyle(color: Colors.white),),)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


