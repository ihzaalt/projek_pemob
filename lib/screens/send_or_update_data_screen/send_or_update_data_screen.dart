import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_firebase_crud_app/models/kost_data.dart';
import 'package:flutter_firebase_crud_app/models/makanan_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SendOrUpdateData extends StatefulWidget {
  final String name;
  final String price;
  final String description;
  final String image;
  final String id;
  final String? collection;

  const SendOrUpdateData({
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


  Future<void> submitData() async {
  setState(() {
    showProgressIndicator = true;
  });

  final jsonData = {
    'name': nameController.text,
    'price': priceController.text,
    'description': descriptionController.text,
    'image': _image != null ? _image!.path : '',
    'id': widget.id.isNotEmpty ? widget.id : null,
  };

  if (widget.collection == 'kosts') {
    final dataDoc = FirebaseFirestore.instance.collection('kosts').doc(widget.id.isNotEmpty ? widget.id : null);
    await dataDoc.set(KostData.fromJson(jsonData).toJson() as Map<String, dynamic>);
  } else if (widget.collection == 'makanans') {
    final dataDoc = FirebaseFirestore.instance.collection('makanans').doc(widget.id.isNotEmpty ? widget.id : null);
    await dataDoc.set(MakananData.fromJson(jsonData).toJson() as Map<String, dynamic>);

  }

  setState(() {
    nameController.text = '';
    priceController.text = '';
    descriptionController.text = '';
    _image = null;
    showProgressIndicator = false;
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id.isEmpty ? 'Add Data' : 'Update Data'),
        backgroundColor: Colors.green.shade900,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20).copyWith(top: 60, bottom: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Enter name'),
            ),
            SizedBox(height: 20),
            Text(
              'Price',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(hintText: 'Enter price'),
            ),
            SizedBox(height: 20),
            Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(hintText: 'Enter description'),
            ),
            SizedBox(height: 20),
            Text(
              'Image',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            _image != null
                ? Image.file(
                    _image!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : SizedBox(
                    height: 100,
                    width: 100,
                    child: Placeholder(),
                  ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 40),
            MaterialButton(
              onPressed: submitData,
              minWidth: double.infinity,
              height: 50,
              color: Colors.green.shade900,
              child: showProgressIndicator
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
