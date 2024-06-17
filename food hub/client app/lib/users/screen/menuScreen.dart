import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FoodDetail extends StatefulWidget {
  String type;
  String id;
  String seatnumber;
  FoodDetail(
      {super.key,
      required this.id,
      required this.type,
      required this.seatnumber});

  @override
  State<FoodDetail> createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  TextEditingController _infoController = TextEditingController();
  GlobalKey _formKey = GlobalKey<FormState>();
  int itemnum = 1;

  List extra = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(widget.type)
            .doc(widget.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 20),
                    child: Text(
                      snapshot.data!["foodname"],
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 30, right: 10, left: 10),
                    child: Text(snapshot.data!["detail"]),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Extra",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomCheckBoxGroup(
                    buttonTextStyle: const ButtonTextStyle(
                      selectedColor: Colors.red,
                      unSelectedColor: Colors.orange,
                      textStyle: TextStyle(
                        fontSize: 16,
                      ),
                      selectedTextStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    unSelectedColor: Theme.of(context).canvasColor,
                    buttonLables:
                        List<String>.from(snapshot.data!.data()!["extra"]),
                    buttonValuesList:
                        List<String>.from(snapshot.data!.data()!["extra"]),
                    checkBoxButtonValues: (values) {
                      extra = values;
                    },
                    spacing: 0,
                    horizontal: false,
                    enableButtonWrap: true,
                    width: 150,
                    absoluteZeroSpacing: false,
                    selectedColor: Theme.of(context).splashColor,
                    padding: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        maxLines: 3,
                        controller: _infoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Additional Info",
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 20, right: 10, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("PRICE ${snapshot.data!.data()!["price"]}"),
                        const SizedBox(
                          width: 150,
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if (itemnum > 1) {
                                  itemnum--;
                                }
                              });
                            },
                            icon: const Icon(Icons.remove)),
                        Text(itemnum.toString()),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                itemnum++;
                              });
                            },
                            icon: Icon(Icons.add))
                      ],
                    ),
                  ),
                  Text(
                    "Total Price : ${(snapshot.data!.data()!["price"]) * itemnum}",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        int total = (snapshot.data!.data()!["price"]) * itemnum;
                        await FirebaseFirestore.instance
                            .collection("order")
                            .doc(widget.seatnumber)
                            .collection("items")
                            .doc()
                            .set({
                          "seat number": widget.seatnumber,
                          "foodname": snapshot.data!.data()!["foodname"],
                          "extra": extra,
                          "quantity": itemnum,
                          "price": total,
                          "moreinfo": _infoController.text,
                        });
                        await FirebaseFirestore.instance
                            .collection("order")
                            .doc(widget.seatnumber)
                            .set({
                          "chef": "",
                          "payed": false,
                          "done": false,
                          "seatnumber": widget.seatnumber,
                          "time": DateTime.now()
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("ADD"))
                ],
              ),
            ),
          );
        });
  }
}
