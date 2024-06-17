import 'package:chefapp/screen/detailScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  String chefName;
  OrderScreen({super.key, required this.chefName});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("order")
              .orderBy("time", descending: true)
              .snapshots(),
          builder: (context, ordersnapshot) {
            if (!ordersnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: ordersnapshot.data!.size,
              itemBuilder: (context, index) {
                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("order")
                        .doc(ordersnapshot.data!.docs[index].id)
                        .collection("items")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderDetailScreen(
                                        chefName: widget.chefName,
                                        seatnumber: ordersnapshot
                                            .data!.docs[index].id)));
                          },
                          child: Container(
                            height: 130,
                            decoration: BoxDecoration(
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Seat Numebr : ${ordersnapshot.data!.docs[index].id}",
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.white),
                                  ),
                                  Text(
                                    "Numebr of Order : ${snapshot.data!.size}",
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.white),
                                  ),
                                  ordersnapshot.data!.docs[index]
                                              .data()["chef"] ==
                                          ""
                                      ? const Text(
                                          "Accepted Chef None",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.white),
                                        )
                                      : Text(
                                          "Accepted Chef ${ordersnapshot.data!.docs[index].data()["chef"]}",
                                          style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.white),
                                        ),
                                  ordersnapshot.data!.docs[index]
                                          .data()["payed"]
                                      ? const Text(
                                          "Payed",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.white),
                                        )
                                      : const Text(
                                          "NotPayed",
                                          style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.white),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              },
            );
          }),
    );
  }
}
