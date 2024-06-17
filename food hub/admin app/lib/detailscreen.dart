import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("completedOrders")
            .doc(widget.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("completedOrders")
                .doc(widget.id)
                .collection("items")
                .snapshots(),
            builder: (context, mainsnapshot) {
              if (!mainsnapshot.hasData) {
                return Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              double totalPrice = 0;
              List<String> foodNames = [];
              for (var doc in mainsnapshot.data!.docs) {
                var data = doc.data() as Map<String, dynamic>;
                totalPrice += data['price'];
                foodNames.add(data['foodname']);
              }

              return Scaffold(
                appBar: AppBar(
                  title: const Text("Order Details"),
                  backgroundColor: Colors.deepPurple,
                ),
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Chef Name: ${snapshot.data!['chef']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Seat Number: ${snapshot.data!['seatnumber']}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Items:",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...foodNames.map((name) => Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          )),
                      const SizedBox(height: 20),
                      Text(
                        "Total Price: \$${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
}
