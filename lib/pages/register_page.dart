import 'package:docscanner/components/my_button.dart';
import 'package:docscanner/components/my_custom_page_route.dart';
import 'package:docscanner/components/my_pass_textfield.dart';
import 'package:docscanner/components/my_snack_bar.dart';
import 'package:docscanner/components/my_textfield.dart';
import 'package:docscanner/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

double screenHeight = 0.0;
double screenWidth = 0.0;

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _registerEmailController;
  late TextEditingController _registerPassController;
  late TextEditingController _registerNameController;
  late TextEditingController _confirmRegisterPassController;

  @override
  void initState() {
    super.initState();
    _registerEmailController = TextEditingController();
    _registerNameController = TextEditingController();
    _registerPassController = TextEditingController();
    _confirmRegisterPassController = TextEditingController();
  }

  @override
  void dispose() {
    _registerEmailController.dispose();
    _registerNameController.dispose();
    _registerPassController.dispose();
    _confirmRegisterPassController.dispose();
    super.dispose();
  }

  void back() {
    Navigator.pop(context);
  }

  Future<void> createNewUser(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC3BBBB),
        ),
      ),
    );
    try {
      if (_registerEmailController.text.isEmpty &&
          _registerPassController.text.isEmpty &&
          _confirmRegisterPassController.text.isEmpty) {
        mySnackBar(context, "Fill Your Details", Colors.red);
        Navigator.pop(context);
        return;
      }
      if (_registerEmailController.text.isEmpty &&
          _registerPassController.text.isEmpty) {
        mySnackBar(context, "Enter Your Email and Password", Colors.red);
        Navigator.pop(context);
        return;
      }
      if (_confirmRegisterPassController.text.isEmpty) {
        mySnackBar(context, "Enter Your Password Again", Colors.red);
        Navigator.pop(context);
        return;
      }

      if (_registerEmailController.text.isEmpty) {
        mySnackBar(context, "Enter Your Email", Colors.red);
        Navigator.pop(context);
        return;
      }
      if (_registerPassController.text.isEmpty) {
        mySnackBar(context, "Enter Your Password", Colors.red);
        Navigator.pop(context);
        return;
      }
      if (_registerPassController.text != _confirmRegisterPassController.text) {
        mySnackBar(context, "Your Password Doesn't Match", Colors.red);
        _confirmRegisterPassController.clear();
        Navigator.pop(context);
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _registerEmailController.text,
              password: _registerPassController.text);
      if (userCredential.user != null) {
        Navigator.of(context).pushReplacement(
          MyCustomPageRoute(LoginPage()),
        );
        _registerEmailController.clear();
        _registerPassController.clear();
        _confirmRegisterPassController.clear();
        // _registerNameController.clear();
      }

      Navigator.pop(context);
      back();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        mySnackBar(context, "Invalid Email", Colors.red);
        _registerEmailController.clear();
        _registerPassController.clear();
        _confirmRegisterPassController.clear();
        Navigator.pop(context);
        return;
      } else if (e.code == 'invalid-credential') {
        mySnackBar(context, "Invalid Credential", Colors.red);
        Navigator.pop(context);
        return;
      } else if (e.code == 'network-request-failed') {
        mySnackBar(context, "Check Your Network Connection", Colors.red);
        Navigator.pop(context);
        return;
      } else if (e.code == 'weak-password') {
        mySnackBar(context, "Please Enter A Strong Password", Colors.red);
        Navigator.pop(context);
        return;
      } else if (e.code == 'email-already-in-use') {
        mySnackBar(context, "UserID Already Exist", Colors.red);
        Navigator.pop(context);
        return;
      }

      mySnackBar(context, e.toString(), Colors.red);
      Navigator.pop(context);
    } catch (e) {
      mySnackBar(context, e.toString(), Colors.red);
      Navigator.pop(context);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: back,
                      icon: Icon(
                        color: Color(0xFFF4BBFF),
                        Icons.arrow_back_rounded,
                        size: 32,
                      ),
                    ),
                    Text(
                      "New User",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Name",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        MyTextField(
                          controller: _registerNameController,
                          hintText: " Enter Your Name",
                          labelText: "",
                          width: double.infinity,
                          onChange: (p0) {},
                        ),
                        SizedBox(
                          height: screenHeight * 0.03,
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Email ID",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        MyTextField(
                          controller: _registerEmailController,
                          hintText: " Enter Your Email",
                          labelText: "",
                          width: double.infinity,
                          onChange: (p0) {},
                        ),
                        SizedBox(
                          height: screenHeight * 0.03,
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Password",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        MyPasswordTextField(
                          controller: _registerPassController,
                          hintText: " Enter Your Password",
                          labelText: "Password",
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: screenHeight * 0.03,
                        ),
                        const Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Confirm Password",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        MyPasswordTextField(
                          controller: _confirmRegisterPassController,
                          hintText: " Enter Your Password Again",
                          labelText: "Password",
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: screenHeight * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),
                MyButton(
                  height: 55,
                  width: double.infinity,
                  buttonText: "Register Your Account",
                  onTap: () {
                    createNewUser(context);
                  },
                  buttonColor: Color(0xFFF4BBFF),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
