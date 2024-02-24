// login_page.dart

import 'package:flutter/material.dart';

// Import necessary dependencies and components
import '../home/home_page.dart';
import '../services/authentication.dart';
import '../assets/theme.dart';
import '../assets/horizontal_gradient_divider.dart';
import '../assets/gradient_button.dart';

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
                    gradient: AppTheme.backgroundGradient,
                  ),
                ),
              ),

              // Login Button
              Positioned(
                top: 750,
                left: (MediaQuery.of(context).size.width / 2) - 60,
                child: GradientButton(
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
                  text: 'LOG IN',
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