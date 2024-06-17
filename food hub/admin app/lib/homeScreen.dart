import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodhubadmin/detailscreen.dart';
import 'package:foodhubadmin/penddingorderdetail.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Orders"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Completed Orders"),
              Tab(text: "Waiting Orders"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCompletedOrders(),
            _buildWaitingOrders(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedOrders() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("completedOrders")
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.size,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data();
            Timestamp timestamp = data["time"];
            DateTime dateTime = timestamp.toDate();
            String formattedDate =
                DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(id: snapshot.data!.docs[index].id)));
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Chef Name: ${data["chef"]}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Seat Number: ${data["seatnumber"]}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Date: $formattedDate",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWaitingOrders() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("order")
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.size,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data();
            Timestamp timestamp = data["time"];
            DateTime dateTime = timestamp.toDate();
            String formattedDate =
                DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(
                              id: snapshot.data!.docs[index].id)));
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data["chef"] != ""
                              ? "Chef : ${data["chef"]}"
                              : "Chef : Waiting Chef ..",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Seat Number: ${data["seatnumber"]}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Date: $formattedDate",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
