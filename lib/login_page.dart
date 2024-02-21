import 'package:flutter/material.dart';
import 'authentication.dart';
import 'dashboard_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Capture the context before entering the asynchronous block
            BuildContext? currentContext = context;

            // Simulate login
            String? token = await authenticateWithStrava();
            if (token != null) {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                currentContext,
                MaterialPageRoute(builder: (context) => DashboardPage(accessToken: token)),
              );
            }
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}