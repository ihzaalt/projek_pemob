import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_crud_app/admin/home_screen/home_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_firebase_crud_app/models/kost_data.dart';
import 'package:flutter_firebase_crud_app/models/makanan_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart';

class SendOrUpdateData extends StatefulWidget {
  String name;
  String price;
  String description;
  String image;
  final String id;
  final String? collection;

  SendOrUpdateData({
    this.name = '',
    this.price = '',
    this.description = '',
    this.image = '',
    this.id = '',
    this.collection,
  });

  @override
  State<SendOrUpdateData> createState() => _SendOrUpdateDataState();
}

class _SendOrUpdateDataState extends State<SendOrUpdateData> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool showProgressIndicator = false;
  File? _image;

  @override
  void initState() {
    nameController.text = widget.name;
    priceController.text = widget.price;
    descriptionController.text = widget.description;
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

      setState(() {
        if (result != null && result.files.isNotEmpty) {
          Uint8List uint8list = result.files.single.bytes!;
          _image = File.fromRawPath(uint8list);
        }
      });
    } else if (Platform.isAndroid || Platform.isIOS) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> createData() async {
    try {
      String newName = nameController.text;
      String newPrice = priceController.text;
      String newDescription = descriptionController.text;
      String newImage = '';

      int currentTime = Timestamp.now().millisecondsSinceEpoch;

      if (_image != null) {
        String imagePath = 'your_storage_path/$currentTime';
        UploadTask task = FirebaseStorage.instance.ref().child(imagePath).putFile(_image!);

        TaskSnapshot snapshot = await task;
        newImage = await snapshot.ref.getDownloadURL() ?? '';
      }

      dynamic newData;

      if (widget.collection == 'kosts') {
        newData = KostData(
          id: currentTime.toString(),
          name: newName,
          price: newPrice,
          description: newDescription,
          image: newImage,
        );
      } else if (widget.collection == 'makanans') {
        newData = MakananData(
          id: currentTime.toString(),
          name: newName,
          price: newPrice,
          description: newDescription,
          image: newImage,
        );
      }

      await FirebaseFirestore.instance.collection(widget.collection!).add(newData.toJson());

      clearFormAndNavigateBack();
    } catch (e) {
      print('Error creating data: $e');
    }
  }


Future<void> updateData() async {
  try {
    String newName = nameController.text;
    String newPrice = priceController.text;
    String newDescription = descriptionController.text;
    String newImage = '';

    String currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

    if (_image != null) {
      String imagePath = 'your_storage_path/$currentTimestamp';
      UploadTask task = FirebaseStorage.instance.ref().child(imagePath).putFile(_image!);

      TaskSnapshot snapshot = await task;
      newImage = await snapshot.ref.getDownloadURL() ?? '';
    }

    dynamic newData;

    if (widget.collection == 'kosts') {
      newData = KostData(
        name: newName,
        price: newPrice,
        description: newDescription,
        image: newImage,
        id: currentTimestamp,
      );
    } else if (widget.collection == 'makanans') {
      newData = MakananData(
        name: newName,
        price: newPrice,
        description: newDescription,
        image: newImage,
        id: currentTimestamp,
      );
    }

    await FirebaseFirestore.instance.collection(widget.collection!).add(newData.toJson());

    if (widget.id.isNotEmpty) {

      QuerySnapshot oldDocs = await FirebaseFirestore.instance.collection(widget.collection!)
          .where('id', isEqualTo: widget.id)
          .get();

      oldDocs.docs.forEach((oldDoc) {
        oldDoc.reference.delete();
      });
    }

    clearFormAndNavigateBack();
  } catch (e) {
    print('Error updating data: $e');
  }
}



  void clearFormAndNavigateBack() {
    nameController.clear();
    priceController.clear();
    descriptionController.clear();
    setState(() {
      _image = null;
      showProgressIndicator = false;
    });
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomeScreen(), // Replace HomeScreen with the actual class for your home screen
    ),
  );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade900,
        centerTitle: true,
        title: Text(
          'Send Data',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      body: SingleChildScrollView(
        padding:
            EdgeInsets.symmetric(horizontal: 20).copyWith(top: 60, bottom: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: nameController,
              onChanged: (value) {
                setState(() {
                  // Update the name when the text changes
                  widget.name = value;
                });
              },
              decoration: InputDecoration(hintText: ''),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Price',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: priceController,
              onChanged: (value) {
                setState(() {
                  // Update the price when the text changes
                  widget.price = value;
                });
              },
              decoration: InputDecoration(hintText: ''),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: descriptionController,
              onChanged: (value) {
                setState(() {
                  // Update the description when the text changes
                  widget.description = value;
                });
              },
              decoration: InputDecoration(hintText: ''),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Image',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            _image != null
                ? Image.file(
                    _image!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  )
                : SizedBox(),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(
              height: 40,
            ),
            MaterialButton(
              onPressed: widget.id.isNotEmpty ? updateData : createData,
              minWidth: double.infinity,
              height: 50,
              color: Colors.green.shade900,
              child: showProgressIndicator
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
