import 'package:flutter/material.dart';
import 'package:foodhub/users/screen/homeScreen.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class MainUserScreen extends StatefulWidget {
  const MainUserScreen({super.key});

  @override
  State<MainUserScreen> createState() => _MainUserScreenState();
}

class _MainUserScreenState extends State<MainUserScreen> {
  String tabel = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MultiSelectDropDown<int>(
                onOptionSelected: (options) {
                  tabel = options.first.label;
                },
                options: const [
                  ValueItem(label: 'Table 1', value: 1),
                  ValueItem(label: 'Table 2', value: 2),
                  ValueItem(label: 'Table 3', value: 3),
                  ValueItem(label: 'Table 4', value: 4),
                  ValueItem(label: 'Table 5', value: 5),
                  ValueItem(label: 'Table 6', value: 6),
                ],
                borderColor: Colors.blue,
                borderWidth: 3,
                hint: "Select Table Number",
                hintColor: Colors.black54,
                selectionType: SelectionType.single,
                chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                dropdownHeight: 300,
                optionTextStyle: const TextStyle(fontSize: 16),
                selectedOptionIcon: const Icon(Icons.check_circle),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (tabel == "") {
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserMenuScreen(
                                seatnumber: tabel,
                              )));
                },
                child: Text("NEXT"))
          ],
        ),
      ),
    );
  }
}
