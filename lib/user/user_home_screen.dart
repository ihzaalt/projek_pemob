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
  return InkWell(
    onTap: () {
      navigateToDetailScreen(kostData);
    },
    child: Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar di atas teks
          Container(
            width: double.infinity,
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                kostData.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10),
          // Teks
          Text(
            kostData.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5),
          Text(
            'Rp ${kostData.price.toString()}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    ),
  );
}

Widget buildMakananTile(MakananData makananData) {
  return InkWell(
    onTap: () {
      navigateToDetailScreen(makananData);
    },
    child: Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar di atas teks
          Container(
            width: double.infinity,
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                makananData.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 10),
          // Teks
          Text(
            makananData.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5),
          Text(
            'Rp ${makananData.price.toString()}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    ),
  );
}

void navigateToDetailScreen(dynamic data) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => DetailScreen(data: data),
    ),
  );
}
}


class DetailScreen extends StatelessWidget {
  final dynamic data;

  DetailScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar di atas teks
            Container(
              width: double.infinity,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  data.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Teks
            Text(
              data.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Rp ${data.price.toString()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              data.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
