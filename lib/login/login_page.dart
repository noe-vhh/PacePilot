// login_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '/../services/authentication.dart';
import '/../home/home_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.163, 0.844),
              end: Alignment(-0.844, 0.806),
              colors: [Color.fromRGBO(104, 108, 107, 1), Color.fromRGBO(64, 64, 64, 1)],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Logo
              Positioned(
                top: 30,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icon/PacePilot.png',
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Divider 1
              Positioned(
                top: 280,
                child: Container(
                  width: 340,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment(0.981, 0.0),
                      end: Alignment(0.0, 0.000135811904),
                      colors: [Color.fromRGBO(153, 188, 157, 1), Color.fromRGBO(89, 114, 111, 1)],
                    ),
                  ),
                ),
              ),
              // Divider 2
              Positioned(
                top: 400,
                child: Container(
                  width: 340,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      begin: Alignment(0.981, 0.0),
                      end: Alignment(0.0, 0.000135811904),
                      colors: [Color.fromRGBO(153, 188, 157, 1), Color.fromRGBO(89, 114, 111, 1)],
                    ),
                  ),
                ),
              ),
              // App description
              const Positioned(
                top: 325,
                child: SizedBox(
                  width: 320,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'Your running companion app for personalised insights, dynamic statistics, and actionable goals.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontFamily: 'Sansation',
                          fontSize: 15,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Login Button
              Positioned(
                top: 700,
                child: ElevatedButton(
                  onPressed: () async {
                    // Attempt to authenticate with Strava
                    String? token = await authenticateWithStrava();

                    if (token != null) {
                      // If authentication successful, navigate to Dashboard
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardPage(accessToken: token)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(153, 189, 156, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Sansation',
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}