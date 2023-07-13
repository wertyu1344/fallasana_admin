import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fallasana_admin/services/cloud_firestore_services.dart';
import 'package:fallasana_admin/view/edit_char_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';

class CharListPage extends StatefulWidget {
  @override
  _CharListPageState createState() => _CharListPageState();
}

class _CharListPageState extends State<CharListPage> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Character List"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              final ref =
                  FirebaseStorage.instance.ref().child('images/${data["id"]}');

              return FutureBuilder<String>(
                future: ref.getDownloadURL(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Yükleniyor durumunu göstermek için bir widget döndürebilirsiniz.
                    return SizedBox();
                  } else if (snapshot.hasError) {
                    // Hata durumunda bir hata mesajı gösterebilirsiniz.
                    return Text('Hata: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    // Fotoğraf URL'si başarıyla alındıysa ListTile'ı döndürebilirsiniz.
                    String imageUrl = snapshot.data!;
                    print("iamge url $imageUrl");

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade200),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ImageNetwork(
                                image: imageUrl,
                                height: 50,
                                width: 50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data["name"]),
                                Text(data["gender"]),
                              ],
                            ),
                            Spacer(),
                            IconButton(
                                onPressed: () {
                                  Get.to(() => EditCharPage(
                                      documentId: data["id"],
                                      imageUrl: imageUrl));
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                )),
                            const SizedBox(width: 10),
                            IconButton(
                                onPressed: () {
                                  FirebaseServices.deleteData(data["id"]);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                )),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Beklenmeyen bir durum için bir hata mesajı gösterebilirsiniz.
                    return Text('Beklenmeyen bir durum oluştu.');
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
