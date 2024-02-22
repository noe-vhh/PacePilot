// login_page.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

// Importing necessary libraries
import '../assets/theme.dart';
import '../services/authentication.dart';
import '../home/home_page.dart';
import '../assets/horizontal_gradient_divider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold widget provides basic structure for the visual interface
    return Scaffold(
      body: SingleChildScrollView(
        // SingleChildScrollView allows the content to be scrollable
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Logo positioned at the top
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
              const Positioned(
                top: 280,
                child: HorizontalGradientDivider(),
              ),
              // Divider 2
              const Positioned(
                top: 400,
                child: HorizontalGradientDivider(),
              ),
              // App description
              Positioned(
                top: 310,
                child: SizedBox(
                  width: 320,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'Your running companion app for personalized insights, dynamic statistics, and actionable goals.',
                        textAlign: TextAlign.center,
                        style: AppTheme.buildTextTheme().bodyLarge,
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
                    backgroundColor: AppTheme.themeData.elevatedButtonTheme.style!.backgroundColor!.resolve({}),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Login',
                      style: AppTheme.buildTextTheme().labelLarge,
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