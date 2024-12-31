import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'counselor_sign_up_page.dart';
import 'counselor_dashboard.dart';

class CounselorLoginPage extends StatefulWidget {
  @override
  _CounselorLoginPageState createState() => _CounselorLoginPageState();
}

class _CounselorLoginPageState extends State<CounselorLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> deleteExpiredAvailabilities() async {
    //Step 1: Get the current authenticated user
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No user is currently authenticated.");
      return;
    }

    final String userId = currentUser.uid; // The authenticated user's UID
    final DateTime now = DateTime.now(); // Current system time

    try {
      // Step 2: Access the 'availabilities' sub-collection for the user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('availabilities')
          .get(); // Retrieve all availabilities

      // Step 3: Loop through the documents and check if their datetime has passed
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();

        if (data['date'] != null && data['start'] != null) {
          // Extract date and start time
          Timestamp dateTimestamp = data['date'];
          Map<String, dynamic> start = data['start'];
          int hour = start['hour'] ?? 0; // Default to 0 if missing
          int minute = start['minute'] ?? 0;

          // Combine date and time into a DateTime object
          DateTime documentDateTime = dateTimestamp.toDate();
          documentDateTime = DateTime(
            documentDateTime.year,
            documentDateTime.month,
            documentDateTime.day,
            hour,
            minute,
          );

          // Compare with current time
          if (documentDateTime.isBefore(now)) {
            print("Deleting expired availability: ${doc.id}");
            batch.delete(doc.reference);
          }
        }
      }

      // Commit the batch
      await batch.commit();
      print("Expired availabilities deleted successfully.");
    } catch (e) {
      print("Error deleting expired availabilities: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8EAF6), // Light purple background
      appBar: AppBar(
        title: Text(
          'Welcome Counselor!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: Color(0xFF5E35B1), // Deep purple app bar
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.0),
                  Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF512DA8), // Bold purple text
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Color(0xFF303F9F)), // Indigo
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFF3949AB)), // Indigo on focus
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your Email.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // Hide password characters
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color(0xFF303F9F)), // Indigo
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(0xFF3949AB)), // Indigo on focus
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()),
                          );
                        },
                        child: Text(
                          'New here?',
                          style: TextStyle(
                              color: Color(0xFF512DA8)), // Deep purple text
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          print('Forgot password clicked');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Color(0xFF512DA8)), // Deep purple text
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final UserCredential userCredential =
                                  await _auth.signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              );
                              if (userCredential.user != null) {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userCredential.user!.uid)
                                    .update({
                                  'online': true,
                                });
                              }
                              await deleteExpiredAvailabilities();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CounselorDashboard()),
                              );
                            } on FirebaseAuthException catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.message!),
                                ),
                              );
                            }
                          }
                        },
                        child: Text('Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Color(0xFF5E35B1), // Deep purple button
                          foregroundColor: Colors.white, // White text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
