import 'package:chefapp/screen/orderScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("chefs").snapshots(),
        builder: (context, snapshot) {
          return Scaffold(
            body: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: RichText(
                      text: const TextSpan(children: [
                        TextSpan(
                            text: "FOOD",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 25)),
                        TextSpan(
                            text: "HUB",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 25)),
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextFormField(
                      controller: _name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required";
                        }
                      },
                      decoration: InputDecoration(
                          hintText: "Chef Name",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: _password,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required";
                        }
                      },
                      decoration: InputDecoration(
                          hintText: "Password",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            for (int x = 0; x < snapshot.data!.size; x++) {
                              if (snapshot.data!.docs[x].data()["username"] ==
                                      _name.text &&
                                  snapshot.data!.docs[x].data()["password"] ==
                                      _password.text) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OrderScreen(chefName: _name.text)));
                              } else {
                                return;
                              }
                            }
                          }
                        },
                        child: Text("Log in")),
                  )
                ],
              ),
            ),
          );
        });
  }
}
