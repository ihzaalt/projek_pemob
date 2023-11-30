import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_crud_app/models/kost_data.dart';
import 'package:flutter_firebase_crud_app/models/makanan_data.dart';
import 'package:flutter_firebase_crud_app/screens/send_or_update_data_screen/send_or_update_data_screen.dart';

void main() {
  runApp(MaterialApp(
    title: 'Your App',
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedPage == 0 ? 'Kost' : 'Makanan'),
        backgroundColor: Colors.green.shade900,
        centerTitle: true,
      ),
      drawer: buildSidebar(),
      body: _selectedPage == 0 ? buildKostPage() : buildMakananPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SendOrUpdateData(
                collection: _selectedPage == 0 ? 'kosts' : 'makanans',
              ),
            ),
          );
        },
        backgroundColor: Colors.green.shade900,
        child: Icon(Icons.add),
      ),
    );
  }

  Drawer buildSidebar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green.shade900,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Kost'),
            onTap: () {
              setState(() {
                _selectedPage = 0;
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            title: Text('Makanan'),
            onTap: () {
              setState(() {
                _selectedPage = 1;
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildKostPage() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('kosts').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        return streamSnapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 41),
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: ((context, index) {
                  // Use KostData.fromJson to convert Firestore data to KostData
                  KostData kostData = KostData.fromJson(streamSnapshot.data!.docs[index].data() as Map<String, dynamic>);
                  return buildKostTile(kostData);
                }),
              )
            : Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }

  Widget buildMakananPage() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('makanans').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        return streamSnapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 41),
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: ((context, index) {
                  // Use MakananData.fromJson to convert Firestore data to MakananData
                  MakananData makananData = MakananData.fromJson(streamSnapshot.data!.docs[index].data() as Map<String, dynamic>);
                  return buildMakananTile(makananData);
                }),
              )
            : Center(
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }

  Widget buildKostTile(KostData kostData) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      title: Text(
        kostData.name,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rp ${kostData.price.toString()}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
          Text(
            kostData.description,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      leading: Image.network(
        kostData.image,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              navigateToUpdateScreen(kostData);
            },
            icon: Icon(Icons.edit, color: Colors.blue, size: 21),
          ),
          IconButton(
            onPressed: () async {
              await deleteData(kostData);
            },
            icon: Icon(Icons.delete, color: Colors.green.shade900, size: 21),
          ),
        ],
      ),
    );
  }

  Widget buildMakananTile(MakananData makananData) {
    return ListTile(
      title: Text(
        makananData.name,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rp ${makananData.price.toString()}}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
          Text(
            makananData.description,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
      leading: Image.network(
        makananData.image,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              navigateToUpdateScreen(makananData);
            },
            icon: Icon(Icons.edit, color: Colors.blue, size: 21),
          ),
          IconButton(
            onPressed: () async {
              await deleteData(makananData);
            },
            icon: Icon(Icons.delete, color: Colors.green.shade900, size: 21),
          ),
        ],
      ),
    );
  }

  void navigateToUpdateScreen(dynamic data) {
    String id = data.id;
    String collection = '';

    if (data is KostData) {
      collection = 'kosts';
    } else if (data is MakananData) {
      collection = 'makanans';
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SendOrUpdateData(
          id: id,
          name: data.name,
          price: data.price,
          description: data.description,
          image: data.image,
          collection: collection,
        ),
      ),
    );
  }

  Future<void> deleteData(dynamic data) async {
  String id = data.id;
  String collection = '';

  if (data is KostData) {
    collection = 'kosts';
  } else if (data is MakananData) {
    collection = 'makanans';
  }

  final docData = FirebaseFirestore.instance.collection(collection).doc(id);
  await docData.delete();
}

}
