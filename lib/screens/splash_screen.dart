import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacityLogoManoEntonada = 0.0;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 300), () {
      setState(() => opacityLogoManoEntonada = 1.0);
    });

    Timer(const Duration(seconds: 7), () {
      Navigator.pushReplacementNamed(context, '/loginScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2F7),
      body: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              opacity: opacityLogoManoEntonada,
              duration: const Duration(seconds: 1),
              child: Image.asset(
                'assets/images/logo_manoentonadas.png',
                width: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
