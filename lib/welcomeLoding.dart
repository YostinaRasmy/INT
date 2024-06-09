import 'package:connection2/main_page.dart';
import 'package:flutter/material.dart';

class WelcomeLoading extends StatefulWidget {
  const WelcomeLoading({super.key});

  @override
  _WelcomeLoadingState createState() => _WelcomeLoadingState();
}

class _WelcomeLoadingState extends State<WelcomeLoading> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text('Welcome Page'),
      // ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/INT white.png'),
        const SizedBox(height: 16.0),
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
        ),
        const SizedBox(height: 16.0),
        const Column(
          children: [
            Text(
              'Discover Your Own Dream House',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'Transform your space, elevate your life',
              style: TextStyle(fontSize: 20), // Change the font size here
            ),
          ],
        ),
      ]),
    );
  }
}
