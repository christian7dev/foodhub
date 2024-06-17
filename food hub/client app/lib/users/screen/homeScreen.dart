import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foodhub/users/screen/menuScreen.dart';
import 'package:foodhub/users/screen/ordersScreen.dart';

class UserMenuScreen extends StatefulWidget {
  String seatnumber;
  UserMenuScreen({super.key, required this.seatnumber});

  @override
  State<UserMenuScreen> createState() => _UserMenuScreenState();
}

class _UserMenuScreenState extends State<UserMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("MENU"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Food"),
              Tab(text: "Drink"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Food Tab
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection("food").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.size,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FoodDetail(
                                          seatnumber: widget.seatnumber,
                                          type: "food",
                                          id: snapshot.data!.docs[index].id,
                                        )));
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      "${snapshot.data!.docs[index].data()["link"]}"),
                                ),
                                color: Colors.blueGrey,
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Text(
                                snapshot.data!.docs[index].data()["foodname"],
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
            // Drink Tab
            StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection("drink").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.size,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FoodDetail(
                                          seatnumber: widget.seatnumber,
                                          type: "drink",
                                          id: snapshot.data!.docs[index].id,
                                        ))); // Assuming you have a DrinkDetail screen
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                      "${snapshot.data!.docs[index].data()["link"]}"),
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                              child: Text(
                                snapshot.data!.docs[index].data()["foodname"],
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
          ],
        ),
        floatingActionButton: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("order")
                .doc(widget.seatnumber)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("order")
                      .doc(widget.seatnumber)
                      .collection("items")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return snapshot.data!.size > 0
                        ? FloatingActionButton.extended(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrdersScreen(
                                          seatNumber: widget.seatnumber)));
                            },
                            label: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child:
                                  Text("ORDER (${snapshot.data!.docs.length})"),
                            ),
                          )
                        : FloatingActionButton.extended(
                            onPressed: () {}, label: Text("ORDER (0)"));
                  });
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
