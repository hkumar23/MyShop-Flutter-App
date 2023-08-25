import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

enum AuthMode {
  Signup,
  Login,
}

class AuthScreen extends StatelessWidget {
  static const routeName = "/auth";
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: deviceSize.height,
          width: deviceSize.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Text("MyShop",
                      style: GoogleFonts.lobster(
                        color: Theme.of(context).primaryColor,
                        fontSize: 50,
                        // fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              Flexible(
                flex: deviceSize.width > 600 ? 4 : 2,
                child: AuthCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    "password": "",
    "email": "",
  };
  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("An error occured!"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Okay"))
              ],
            ));
  }

  final _passwordController = TextEditingController();
  bool _isLoading = false;
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  Future<void> _submit() async {
    // print("Logged In");
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        //Login
        await Provider.of<Auth>(context, listen: false).login(
          _authData["email"]!,
          _authData["password"]!,
        );
      } else {
        //Signup
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData["email"]!,
          _authData["password"]!,
        );
      }
    } on Exception catch (error) {
      var errorMessage = "Authentication Failed";
      if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "Could not found a user with that email.";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        errorMessage = "Invalid Password.";
      } else if (error.toString().contains("EMAIL_EXISTS")) {
        errorMessage = "This email address is already in use.";
      } else if (error.toString().contains("TOO_MANY_ATTEMPTS_TRY_LATER")) {
        errorMessage = "Too many attempts.Please try again later.";
      } else if (error.toString().contains("INVALID_EMAIL")) {
        errorMessage = "This is not a valid email address.";
      } else if (error.toString().contains("WEAK_PASSWORD")) {
        errorMessage = "This password is too weak.";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      var errorMessage = "Could not authenticate you. Please try again later!";
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: Colors.black,
      //   ),
      // ),
      height: _authMode == AuthMode.Signup ? 640 : 520,
      constraints: BoxConstraints(
        minHeight: _authMode == AuthMode.Signup ? 640 : 520,
      ),
      width: deviceSize.width * 0.85,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                _authMode == AuthMode.Login
                    ? "Login to your Account"
                    : "Create your Account",
                textScaleFactor: 1.3,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Email"),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || !value.contains("@")) {
                  return "Invalid Email!";
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              onSaved: (value) {
                _authData["email"] = value!;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            // Card(
            //   elevation: 3,
            //   shadowColor: Colors.black45,
            //   child: Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 10),
            //     child: TextFormField(
            //       decoration: const InputDecoration(
            //         label: Text("Password"),
            //         border: InputBorder.none,
            //       ),
            //     ),
            //   ),
            // ),
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Password"),
                border: OutlineInputBorder(),
              ),
              controller: _passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null || value.length < 7) {
                  return "Password is too short!";
                }
                return null;
              },
              onSaved: (value) {
                _authData["password"] = value!;
              },
            ),
            if (_authMode == AuthMode.Signup)
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: const InputDecoration(
                    label: Text("Confirm Password"),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                          if (_passwordController.text != value) {
                            return "Passwords do not match!";
                          }
                          return null;
                        }
                      : null,
                ),
              ),
            const SizedBox(
              height: 15,
            ),
            _isLoading
                ? CircularProgressIndicator()
                : Container(
                    width: deviceSize.width * 0.85,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(),
                      onPressed: _submit,
                      child: Text(
                        _authMode == AuthMode.Login ? "Login" : "Signup",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _authMode == AuthMode.Login
                        ? "Don't have an account?"
                        : "Having an Account?",
                  ),
                  MaterialButton(
                    onPressed: () {
                      _switchAuthMode();
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Text(
                      _authMode == AuthMode.Login ? "Sign up" : "Login     ",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            )
          ],
        )),
      ),
    );
  }
}
