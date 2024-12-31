import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'counselor_dashboard.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signUp(BuildContext context) async {
    try {
      // Create a user using Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // If user creation is successful, store additional user data in Firestore
      if (userCredential.user != null) {
        final String counselorid = userCredential.user!.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(counselorid)
            .set({
          'counselorid': counselorid, // Store the user ID
          'counselorName': nameController.text,
          'phone': phoneController.text,
        });

        // Navigate to the welcome screen after successful sign up
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomeScreen(),
          ),
        );
      }
    } catch (e) {
      print("Error signing up: $e");
      // Handle sign-up errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white, // Set the color you want here
          ),
        ),
        backgroundColor: Colors.deepPurple[700], // Deep Purple AppBar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name input field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.deepPurple[800]),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.deepPurple[300]!, width: 1.0),
                ),
              ),
            ),
            SizedBox(height: 15.0),
            // Phone Number input field
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Colors.deepPurple[800]),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.deepPurple[300]!, width: 1.0),
                ),
              ),
            ),
            SizedBox(height: 15.0),
            // Email input field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.deepPurple[800]),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.deepPurple[300]!, width: 1.0),
                ),
              ),
            ),
            SizedBox(height: 15.0),
            // Password input field
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.deepPurple[800]),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.deepPurple[300]!, width: 1.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // Sign Up Button with purple shades
            Center(
              child: ElevatedButton(
                onPressed: () => _signUp(context),
                child: Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurple, // Deep Purple button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: Colors.purpleAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        backgroundColor: Colors.deepPurple[700], // Deep Purple AppBar
      ),
      body: StreamBuilder(
        // Stream to listen for changes in the 'users' collection
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Show loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Show error message if any error occurs
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Display the list of user names
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Card(
                elevation: 3,
                color: Colors.deepPurple[50],
                child: ListTile(
                  title: Text(data['counselorName']),
                  subtitle: Text(data['phone']),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
