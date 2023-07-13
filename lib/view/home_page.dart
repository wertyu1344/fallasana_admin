import 'package:fallasana_admin/view/add_char_page.dart';
import 'package:fallasana_admin/view/char_list_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Fallasana Admin Panel"),
      ),
      body: Column(
        children: [
          Row(
            children: [
              homeTile(
                title: "Add New Character",
                onTap: () => Get.to(() => const AddCharPage()),
              ),
              homeTile(
                title: "Character List",
                onTap: () => Get.to(() => CharListPage()),
              ),
            ],
          )
        ],
      ),
    );
  }

  Expanded homeTile({required String title, required var onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 200,
            decoration: const BoxDecoration(color: Colors.orangeAccent),
            child: Center(
              child: Text(title),
            ),
          ),
        ),
      ),
    );
  }
}
