import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_crud_app/auth/login_page.dart';
import 'package:flutter_firebase_crud_app/models/kost_data.dart';
import 'package:flutter_firebase_crud_app/models/makanan_data.dart';
import 'package:flutter_firebase_crud_app/services/auth_service.dart';

void main() {
  runApp(MaterialApp(
    title: 'Your App',
    home: UserHomeScreen(),
  ));
}

class UserHomeScreen extends StatefulWidget {
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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
          ListTile(
            title: Text('Login'),
            onTap: () async {
              await AuthService().signOut();
              // Navigate to the login or home page after logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
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
    );
  }
}
