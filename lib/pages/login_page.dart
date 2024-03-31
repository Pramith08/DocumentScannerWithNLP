import 'package:docscanner/components/my_button.dart';
import 'package:docscanner/components/my_custom_home_page_transition.dart';
import 'package:docscanner/components/my_custom_page_route.dart';
import 'package:docscanner/components/my_pass_textfield.dart';
import 'package:docscanner/components/my_snack_bar.dart';
import 'package:docscanner/components/my_textfield.dart';
import 'package:docscanner/pages/home_page.dart';
import 'package:docscanner/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

double screenHeight = 0.0;
double screenWidth = 0.0;
TextEditingController _signInEmailController = TextEditingController();
TextEditingController _signInPasswordController = TextEditingController();

class _LoginPageState extends State<LoginPage> {
  void newUser() {
    Navigator.push(
      context,
      MyCustomHomePageRoute(
        const RegisterPage(),
      ),
    );
  }

  void _permissionHandler(context) async {
    PermissionStatus storagePermission = await Permission.storage.request();
    if (storagePermission.isGranted) {
      // Request camera permission
      PermissionStatus cameraPermission = await Permission.camera.request();
      if (cameraPermission.isGranted) {
        newUser;
        // Both permissions granted, continue with your logic here
      } else {
        // Camera permission not granted
        mySnackBar(context, "Permission Denied For Camera", Colors.red);
      }
    } else {
      // Storage permission not granted
      mySnackBar(context, "Permission Denied For Storage", Colors.red);
    }
  }

  Future<void> userLogin(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC3BBBB),
        ),
      ),
    );
    try {
      if (_signInEmailController.text.isEmpty &&
          _signInPasswordController.text.isEmpty) {
        mySnackBar(context, "Enter Your Email and Password", Colors.red);
        Navigator.pop(context);
        return;
      }
      if (_signInEmailController.text.isEmpty) {
        mySnackBar(context, "Enter Your Email", Colors.red);
        Navigator.pop(context);
        return;
      }
      if (_signInPasswordController.text.isEmpty) {
        mySnackBar(context, "Enter Your Password", Colors.red);
        Navigator.pop(context);
        return;
      }
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _signInEmailController.text,
        password: _signInPasswordController.text,
      );

      Navigator.pop(context);
      if (userCredential.user != null) {
        // String userId = userCredential.user!.uid;

        Navigator.of(context).pushReplacement(
          MyCustomPageRoute(
            HomePage(),
          ),
        );
        _signInEmailController.clear();
        _signInPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        mySnackBar(context, "User Not Found", Colors.red);
        Navigator.pop(context);
        return;
      } else if (e.code == 'wrong-password') {
        mySnackBar(context, "Wrong Password", Colors.red);
        Navigator.pop(context);
        return;
      } else if (e.code == 'invalid-email') {
        mySnackBar(context, "Invalid Credentials", Colors.red);
        Navigator.pop(context);
        return;
      } else if (e.code == 'invalid-credential') {
        mySnackBar(context, "Wrong Password", Colors.red);
        Navigator.pop(context);
        return;
      } else if (e.code == 'network-request-failed') {
        mySnackBar(context, "Check Your Network Connection", Colors.red);
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
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Row(
                children: [
                  Text(
                    "Login In",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          SizedBox(
                            width: 1,
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
                        controller: _signInEmailController,
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
                            width: 1,
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
                        controller: _signInPasswordController,
                        hintText: " Enter Your Password",
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
                buttonText: "Sign In",
                onTap: () {
                  userLogin(context);
                },
                buttonColor: Color(0xFFF4BBFF),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Container(
                child: TextButton(
                  style: TextButton.styleFrom(
                    fixedSize: const Size(double.infinity, 55),
                  ),
                  onPressed: () {
                    // _permissionHandler(context);
                    newUser();
                  },
                  child: const Text(
                    "Not a user..?  Create new user!",
                    style: TextStyle(
                      color: Color(0xFFC3BBBB),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // const Text(
              //   "or",
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 16,
              //   ),
              // ),
              // SizedBox(
              //   height: screenHeight * 0.025,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Container(
              //       height: 55,
              //       width: 150,
              //       decoration: BoxDecoration(
              //           color: const Color(0xFFF4BBFF),
              //           borderRadius: BorderRadius.circular(
              //             15,
              //           )),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const Text(
              //             "Google",
              //             style: TextStyle(
              //               color: Color(0xFF2D2A2E),
              //               fontSize: 16,
              //               fontWeight: FontWeight.w700,
              //             ),
              //           ),
              //           IconButton(
              //             onPressed: () {},
              //             icon: const Icon(
              //               color: Color(0xFF07070A),
              //               Icons.arrow_back_ios_sharp,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //     Container(
              //       height: 55,
              //       width: 150,
              //       decoration: BoxDecoration(
              //           color: const Color(0xFFF4BBFF),
              //           borderRadius: BorderRadius.circular(
              //             15,
              //           )),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const Text(
              //             "Google",
              //             style: TextStyle(
              //               color: Color(0xFF2D2A2E),
              //               fontSize: 16,
              //               fontWeight: FontWeight.w700,
              //             ),
              //           ),
              //           IconButton(
              //             onPressed: () {},
              //             icon: const Icon(
              //               color: Color(0xFF07070A),
              //               Icons.arrow_back_ios_sharp,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
