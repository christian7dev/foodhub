import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  String seatNumber;
  OrdersScreen({super.key, required this.seatNumber});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Timer? _timer;
  Duration _countdownDuration = Duration(minutes: 10);
  DateTime? _startTime;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown(DateTime startTime) {
    _startTime = startTime;
    _countdownDuration =
        Duration(minutes: 10) - DateTime.now().difference(startTime);

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _countdownDuration =
            Duration(minutes: 10) - DateTime.now().difference(_startTime!);
      });

      if (_countdownDuration.inSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("order")
          .doc(widget.seatNumber)
          .snapshots(),
      builder: (context, prosnapshot) {
        if (!prosnapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        var orderData = prosnapshot.data!.data();
        if (orderData != null &&
            orderData["payed"] &&
            orderData["time"] != null) {
          DateTime startTime = (orderData["time"] as Timestamp).toDate();
          if (_startTime == null || _startTime != startTime) {
            Future.microtask(() => _startCountdown(startTime));
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Orders"),
            centerTitle: true,
            actions: [
              orderData!["payed"]
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Payed ",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Not Payed ",
                        style: TextStyle(fontSize: 17, color: Colors.grey),
                      ),
                    ),
            ],
          ),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("order")
                .doc(widget.seatNumber)
                .collection("items")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data!.size == 0) {
                Navigator.pop(context);
              }
              return ListView.builder(
                itemCount: snapshot.data!.size,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapshot.data!.docs[index].data()["foodname"],
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            snapshot.data!.docs[index].data()["extra"] != null
                                ? Text(
                                    snapshot.data!.docs[index]
                                        .data()["extra"]
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 17, color: Colors.white),
                                  )
                                : const Text(""),
                            Text(
                              "Quantity : ${snapshot.data!.docs[index].data()["quantity"]}",
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.white),
                            ),
                            Text(
                              "More : ${snapshot.data!.docs[index].data()["moreinfo"]}",
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.white),
                            ),
                            Text(
                              "price : ${snapshot.data!.docs[index].data()["price"]}",
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.white),
                            ),
                            Text(
                              "seat number : ${snapshot.data!.docs[index].data()["seat number"]}",
                              style: const TextStyle(
                                  fontSize: 17, color: Colors.white),
                            ),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection("order")
                                          .doc(widget.seatNumber)
                                          .collection("items")
                                          .doc(snapshot.data!.docs[index].id)
                                          .delete();
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("order")
                .doc(widget.seatNumber)
                .snapshots(),
            builder: (context, mainsnapshot) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("order")
                    .doc(widget.seatNumber)
                    .collection("items")
                    .snapshots(),
                builder: (context, snapshot) {
                  return orderData["payed"]
                      ? FloatingActionButton.extended(
                          onPressed: () {},
                          label: Text(
                            "The Food will serve in Estimate Time (${_countdownDuration.inMinutes}:${_countdownDuration.inSeconds.remainder(60).toString().padLeft(2, '0')})",
                          ),
                        )
                      : FloatingActionButton.extended(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("order")
                                .doc(widget.seatNumber)
                                .update({
                              "time": DateTime.now(),
                              "payed": true,
                            });
                            num totalprice = 0;
                            num totalquantity = 0;
                            for (int x = 0; x < snapshot.data!.size; x++) {
                              totalprice = totalprice +
                                  snapshot.data!.docs[x].data()["price"];
                              totalquantity = totalquantity +
                                  snapshot.data!.docs[x].data()["quantity"];
                            }
                            _startCountdown(DateTime.now());
                          },
                          label: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: orderData["payed"]
                                ? const Text("Waiting")
                                : const Text("Pay"),
                          ),
                        );
                },
              );
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
}
