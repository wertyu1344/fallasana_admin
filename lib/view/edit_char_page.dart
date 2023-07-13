import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fallasana_admin/services/cloud_firestore_services.dart';
import 'package:fallasana_admin/view/home_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_network/image_network.dart';

class EditCharPage extends StatefulWidget {
  final String documentId;
  final String imageUrl;

  const EditCharPage(
      {Key? key, required this.documentId, required this.imageUrl})
      : super(key: key);

  @override
  State<EditCharPage> createState() => _EditCharPageState();
}

class _EditCharPageState extends State<EditCharPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController firstFavoriteLengthController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController promptController = TextEditingController();
  TextEditingController firstMessageController = TextEditingController();
  String selectedGender = "Male";
  int photoErrorInt = 0;
  bool isPhotoSelected = true;
  bool isPhotoUpdated = false;
  File? selectedImage;
  Uint8List? imageBytes;
  String? imageUrl;

  Future<void> selectImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
    final file = result.files.single;
    setState(() {
      imageBytes = file.bytes;
      isPhotoSelected = true;
      photoErrorInt = 1;
      isPhotoUpdated = true;
    });
  }

  Future<void> uploadImage(String id) async {
    if (imageBytes == null) {
      print("YENİ RESİM SEÇİLMEDİ");
      // Resim seçilmemişse işlemi sonlandır
      return;
    }

    final Reference ref = FirebaseStorage.instance.ref().child('images/$id');
    final UploadTask uploadTask = ref.putData(imageBytes!);
    final TaskSnapshot storageSnapshot =
        await uploadTask.whenComplete(() => null);
    imageUrl = await storageSnapshot.ref.getDownloadURL();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // İlgili dokümanı Firestore'dan getir ve ilgili controller'lara değerleri yerleştir
    fetchCharacterData();
  }

  Future<void> fetchCharacterData() async {
    // Firestore'dan dokümanı getir
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentId)
        .get();

    // Dokümandaki verileri ilgili controller'lara yerleştir
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      setState(() {
        nameController.text = data['name'] ?? '';
        titleController.text = data['title'] ?? '';
        firstFavoriteLengthController.text = data['firstFavoriteLength'] ?? '';
        categoryController.text = data['category'] ?? '';
        selectedGender = data['gender'] ?? 'Male';
        promptController.text = data['prompt'] ?? '';
        firstMessageController.text = data['firstMessage'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Character")),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 19,
                ),
                isPhotoUpdated
                    ? Ink(
                        decoration: const ShapeDecoration(
                          shape: CircleBorder(),
                        ),
                        child: InkWell(
                          onTap: () async {
                            await selectImage();
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: isPhotoSelected
                                ? ClipOval(
                                    child: Image.memory(
                                      imageBytes!,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.camera_alt_outlined),
                                  ),
                          ),
                        ),
                      )
                    : ImageNetwork(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () async {
                          await selectImage();
                        },
                        image: widget.imageUrl,
                        width: 100,
                        height: 100,
                      ),
                const SizedBox(height: 5),
                photoErrorInt == -1
                    ? const Text(
                        "Fotoğraf seçilmedi",
                        style: TextStyle(color: Colors.red),
                      )
                    : const SizedBox(),
                const SizedBox(height: 5),
                textFieldWidget(
                  text: "Name",
                  controller: nameController,
                  maxline: 1,
                  prefixIcon: const Icon(Icons.person),
                ),
                textFieldWidget(
                  text: "Title",
                  controller: titleController,
                  maxline: 2,
                  prefixIcon: const Icon(Icons.text_fields_outlined),
                ),
                textFieldWidget(
                  text: "Enter First Favorite Length",
                  controller: firstFavoriteLengthController,
                  maxline: 1,
                  prefixIcon: const Icon(Icons.favorite_border_outlined),
                ),
                textFieldWidget(
                  text: "Enter Category",
                  controller: categoryController,
                  maxline: 1,
                  prefixIcon: const Icon(Icons.category_rounded),
                ),
                selectOptions(),
                textFieldWidget(
                  text: "Enter Prompt",
                  controller: promptController,
                  maxline: 5,
                  prefixIcon: const Icon(Icons.text_fields_outlined),
                ),
                textFieldWidget(
                  text: "Enter First Message",
                  controller: firstMessageController,
                  maxline: 5,
                  prefixIcon: const Icon(Icons.text_fields_outlined),
                ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () async {
                    if (isPhotoSelected == false) {
                      photoErrorInt = -1;
                      setState(() {});
                    } else {
                      photoErrorInt = 1;
                      setState(() {});
                    }

                    if (_formKey.currentState!.validate() &&
                        photoErrorInt == 1) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Yükleniyor...'),
                              ],
                            ),
                          );
                        },
                      );

                      // Firestore'da ilgili dokümanı güncelle
                      await FirebaseServices.updateData(
                        nameController.text,
                        titleController.text,
                        firstFavoriteLengthController.text,
                        categoryController.text,
                        selectedGender,
                        promptController.text,
                        firstMessageController.text,
                        widget.documentId,
                      );

                      // Resmi yükle (eğer seçilmişse)
                      await uploadImage(widget.documentId);

                      Navigator.pop(context);
                      Get.offAll(() => HomePage());
                      Get.snackbar(
                        "Başarılı",
                        "Karakter Güncellendi",
                        backgroundColor: Colors.black,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }

  textFieldWidget(
      {required String text,
      required TextEditingController controller,
      required int maxline,
      required Icon prefixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          const SizedBox(height: 5),
          TextFormField(
            onChanged: (var value) {
              _formKey.currentState?.validate();
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bu alan boş bırakılamaz';
              }
            },
            maxLines: maxline,
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  selectOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enter Gender"),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio(
                value: 'Male',
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
              ),
              const Text("Male"),
              Radio(
                value: 'Female',
                groupValue: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value!;
                  });
                },
              ),
              const Text("Female"),
            ],
          ),
        ],
      ),
    );
  }
}
