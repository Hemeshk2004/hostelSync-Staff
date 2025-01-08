import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:hostelsync/Login%20Signup/Widget/button.dart';
import 'package:hostelsync/home_page_2.dart';

import '../Services/authentication.dart';
import '../Widget/snackbar.dart';
import '../Widget/text_field.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rollNoController =
      TextEditingController(); // Roll number input
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    rollNoController.dispose();
  }

  void signupUser() async {
    setState(() {
      isLoading = true;
    });
    String res = await AuthMethod().signupUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text);
    if (res == "success") {
      try {
        // Add user details to Firestore with rollNo as the document ID
        await FirebaseFirestore.instance
            .collection('appuser')
            .doc(rollNoController.text.trim().toUpperCase()) // Use rollNo as ID
            .set({
          'name': nameController.text.trim(),
          'rollNo': rollNoController.text.trim().toUpperCase(),
          'email': emailController.text.trim(),
        });

        setState(() {
          isLoading = false;
        });

        // Navigate to the home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage2Widget(),
          ),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, "Error saving user data: $e");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Allow resizing when the keyboard is displayed
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height / 2.8,
                child: Image.asset('assets/images/signup.gif'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0), // Add padding for better alignment
                child: Column(
                  children: [
                    TextFieldInput(
                      icon: Icons.person,
                      textEditingController: nameController,
                      hintText: 'Enter your name',
                      textInputType: TextInputType.text,
                    ),
                    TextFieldInput(
                      icon: Icons.format_list_numbered,
                      textEditingController: rollNoController,
                      hintText: 'Enter your roll number',
                      textInputType: TextInputType.text,
                    ),
                    TextFieldInput(
                      icon: Icons.email,
                      textEditingController: emailController,
                      hintText: 'Enter your email',
                      textInputType: TextInputType.text,
                    ),
                    TextFieldInput(
                      icon: Icons.lock,
                      textEditingController: passwordController,
                      hintText: 'Enter your password',
                      textInputType: TextInputType.text,
                      isPass: true,
                    ),
                    MyButtons(
                      onTap: signupUser,
                      text: isLoading ? "Signing Up..." : "Sign Up",
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            " Login",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
