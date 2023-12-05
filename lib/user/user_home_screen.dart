import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_crud_app/admin/home_screen/home_screen.dart';
import 'package:flutter_firebase_crud_app/models/kost_data.dart';
import 'package:flutter_firebase_crud_app/models/makanan_data.dart';
import 'package:flutter_firebase_crud_app/services/auth_service.dart';

void main() {
  runApp(MaterialApp(
    title: 'KostEat',
    home: UserHomeScreen(),
  ));
}

class UserHomeScreen extends StatefulWidget {
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedPage = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppBarTitle()),
        backgroundColor: Colors.green.shade900,
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedPage = index;
          });
        },
        children: [
          buildAboutUsPage(), 
          buildKostPage(),
          buildMakananPage(),
          buildLoginPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Kost',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Makanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login',
          ),
        ],
        currentIndex: _selectedPage,
        onTap: (index) {
          setState(() {
            _selectedPage = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
    );
  }

  String getAppBarTitle() {
    if (_selectedPage == 0) {
      return 'Home';
    } else if (_selectedPage == 1) {
      return 'Kost';
    } else if (_selectedPage == 2) {
      return 'Makanan';
    } else {
      return 'Login';
    }
  }

  Widget buildAboutUsPage() {
    return AboutUsScreen();
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

  Widget buildLoginPage() {
    return LoginPage();
  }

 Widget buildKostTile(KostData kostData) {
  return InkWell(
    onTap: () {
      navigateToDetailScreen(kostData);
    },
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              kostData.image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    kostData.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 10), // Adding space between title and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Align to the end (right) of the row
                  children: [
                    Text(
                      'Rp ${kostData.price.toString()}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ],
            ),
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
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              makananData.image,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    makananData.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 10), // Adding space between title and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.end, // Align to the end (right) of the row
                  children: [
                    Text(
                      'Rp. ${makananData.price.toString()}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ],
            ),
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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = await _authService.signInWithEmailAndPassword(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login failed'),
                    ),
                  );
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}


class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50), // Spasi atas gambar
            Image.asset('assets/images/logo.png', height: 150, width: 150),
            SizedBox(height: 16),
            Text(
              'KostEat adalah solusi inovatif yang bertujuan untuk memudahkan mahasiswa Kampus Unsoed dalam menemukan informasi terkait makanan dan kost di sekitar area kampus. Dengan visi meningkatkan kenyamanan dan produktivitas mahasiswa, kami menyediakan platform yang intuitif dan user-friendly. Melalui aplikasi mobile kami, pengguna dapat dengan mudah menelusuri pilihan makanan dan kost. Kami berkomitmen untuk memberikan akses yang cepat dan efisien, menciptakan lingkungan yang mendukung kehidupan mahasiswa yang lebih baik di Kampus Unsoed.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}