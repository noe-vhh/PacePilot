// login_page.dart

import 'package:flutter/material.dart';

import '../home/home_page.dart';
import '../services/authentication.dart';

import '../assets/theme.dart';
import '../assets/horizontal_gradient_divider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Background Container
              Positioned(
                top: 84,
                left: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 730,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),

              // Logo Image
              Positioned(
                top: (MediaQuery.of(context).size.height) / 8,
                left: (MediaQuery.of(context).size.width - 300) / 2,
                child: Image.asset(
                  'assets/icon/PacePilot.png',
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

              // Main Container
              Positioned(
                top: 320,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 600,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      begin: Alignment(1, -2.6043924350460657e-8),
                      end: Alignment(-2.69978675866185e-16, 1.8829938173294067),
                      colors: [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(228, 228, 228, 1)],
                    ),
                  ),
                ),
              ),

              // Login Button with Click Animation
              Positioned(
                top: 750,
                left: (MediaQuery.of(context).size.width / 2) - 60,
                child: MaterialButton(
                  onPressed: () async {
                    // Attempt to authenticate with Strava
                    String? token = await authenticateWithStrava();

                    if (token != null) {
                      // If authentication successful, navigate to Dashboard
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => DashboardPage(accessToken: token)),
                      );
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5.0,
                  color: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: const Text(
                    'LOG IN',
                    textAlign: TextAlign.center,
                    style: AppTheme.labelText,
                  ),
                ),
              ),

              // Description Text
              Positioned(
                top: (MediaQuery.of(context).size.height) / 2 + 35,
                left: 50,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 100,
                  ),
                  child: const Text(
                    'Your running companion app for personalised insights, dynamic statistics, and actionable goals.',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyText,
                  ),
                ),
              ),

              // First Gradient Divider
              HorizontalGradientDivider(top: (MediaQuery.of(context).size.height) / 2),

              // Second Gradient Divider
              HorizontalGradientDivider(top: (MediaQuery.of(context).size.height) / 1.5),
            ],
          ),
        ),
      ),
    );
  }
}