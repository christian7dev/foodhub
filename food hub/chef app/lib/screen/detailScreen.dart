import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderDetailScreen extends StatefulWidget {
  final String seatnumber;
  final String chefName;

  OrderDetailScreen(
      {Key? key, required this.seatnumber, required this.chefName})
      : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Future<void> deleteCollection(String collectionPath) async {
    var collection = FirebaseFirestore.instance.collection(collectionPath);
    var snapshots = await collection.get();

    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> handleDoneButtonPressed() async {
    try {
      // Retrieve the main document data
      DocumentSnapshot<Map<String, dynamic>> orderSnapshot =
          await FirebaseFirestore.instance
              .collection("order")
              .doc(widget.seatnumber)
              .get();

      if (orderSnapshot.exists) {
        DocumentReference<Map<String, dynamic>> newOrderRef =
            await FirebaseFirestore.instance
                .collection("completedOrders")
                .add(orderSnapshot.data()!);

        QuerySnapshot<Map<String, dynamic>> itemsSnapshot =
            await FirebaseFirestore.instance
                .collection("order/${widget.seatnumber}/items")
                .get();

        for (var item in itemsSnapshot.docs) {
          await newOrderRef.collection("items").doc(item.id).set(item.data());
        }

        // Delete all documents in the "items" subcollection
        await deleteCollection("order/${widget.seatnumber}/items");

        // Delete the main document
        await FirebaseFirestore.instance
            .collection("order")
            .doc(widget.seatnumber)
            .delete();

        // Navigate back
        Navigator.pop(context);
      } else {
        print('Order document does not exist');
      }
    } catch (e) {
      // Handle any errors that occur during the deletion process
      print('Error processing the order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.seatnumber),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("order")
              .doc(widget.seatnumber)
              .collection("items")
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
                var itemData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemData["foodname"] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (itemData["extra"] != null)
                            ...List<Widget>.from(
                                itemData["extra"].map((extra) => Text(
                                      extra,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                    ))),
                          const SizedBox(height: 8),
                          if (itemData["moreinfo"] != null)
                            Text(
                              itemData["moreinfo"],
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            "Quantity : ${itemData["quantity"]}",
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
      floatingActionButton: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("order")
              .doc(widget.seatnumber)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return FloatingActionButton(onPressed: () {});
            }
            var orderData = snapshot.data!.data() as Map<String, dynamic>;
            return orderData["done"]
                ? FloatingActionButton.extended(
                    onPressed: () {},
                    label: const Text("Accepted"),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton.extended(
                        heroTag: "btn1",
                        onPressed: handleDoneButtonPressed,
                        label: const Text("Done"),
                      ),
                      orderData["chef"].isEmpty
                          ? FloatingActionButton.extended(
                              heroTag: "btn2",
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection("order")
                                    .doc(widget.seatnumber)
                                    .update({"chef": widget.chefName});
                                Navigator.pop(context);
                              },
                              label: const Text("Accept"),
                            )
                          : FloatingActionButton.extended(
                              onPressed: () {},
                              label: const Text("Accepted"),
                            ),
                    ],
                  );
          }),
    );
  }
}
