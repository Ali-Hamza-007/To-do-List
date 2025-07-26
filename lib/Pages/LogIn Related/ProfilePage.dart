import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list_app/Pages/LogIn%20Related/SignInPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user!.uid)
              .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }

  Widget detailTile(String label, IconData icon) {
    return Container(
      color: Color.fromRGBO(227, 227, 227, 1),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 16),
          Expanded(child: Text(label, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Details'), centerTitle: true),
      body:
          userData == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Image.asset('assets/user.png', height: 100),
                    SizedBox(height: 30),
                    detailTile(user?.email ?? 'No email', Icons.email),
                    detailTile(
                      userData?['userName'] ?? 'No name',
                      Icons.person,
                    ),
                    detailTile(userData?['phone'] ?? 'No phone', Icons.phone),
                    detailTile(userData?['gender'] ?? 'Not set', Icons.male),
                    detailTile('********', Icons.lock),
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return SignInPage();
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
