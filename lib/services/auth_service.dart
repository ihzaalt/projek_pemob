import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class AuthService {
  final FirebaseAuth.FirebaseAuth _auth = FirebaseAuth.FirebaseAuth.instance;

  // Registrasi menggunakan email dan kata sandi
  Future<FirebaseAuth.User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      FirebaseAuth.UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseAuth.User? user = result.user;
      return user;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }

  // Login menggunakan email dan kata sandi
  Future<FirebaseAuth.User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      FirebaseAuth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseAuth.User? user = result.user;
      return user;
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  // Mendapatkan user saat ini setelah login
  FirebaseAuth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
