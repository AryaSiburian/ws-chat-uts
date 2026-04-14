import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State <SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), (){
      if(mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PlaceHolderHomeScreen()),
        );
      }
    });
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold (
        backgroundColor: const Color(0xFFFFFFFF),
        body : Center (
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/animations/logo_splash.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,

                repeat: false,
              ),
              const SizedBox(height: 10),
                
            ]
          )
        )
      );
    }
}

class PlaceHolderHomeScreen extends StatelessWidget {
  PlaceHolderHomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center (child: Text('Halaman Chat')));
  }
}

