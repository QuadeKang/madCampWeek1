import 'package:flutter/material.dart';
import 'dart:async';
import 'package:tabapp/main.dart'; // MyTabbedApp이 정의된 경로로 수정해주세요.
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  Animation<double>? animation; // Make it nullable
  double finalSize = 0; // default value
  bool isAnimationInitialized = false; // New flag to indicate if animation is initialized

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 2, milliseconds: 500), // Adjust duration to control speed
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          finalSize = calculateFinalSize(context);
          animation = Tween<double>(begin: 0, end: finalSize).animate(
            CurvedAnimation(
              parent: controller,
              // Use a custom Cubic curve to make the initial speed faster
              curve: Cubic(1,.3,0,.98), // Adjust these values to change the curve
            ),
          )..addListener(() {
            setState(() {});
          });

          // Start the animation and navigate after it's complete
          controller.forward().whenComplete(() {
            navigateToMainApp(context);
          });
        });
      }
    });
  }

  void navigateToMainApp(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyTabbedApp()));
  }

  double calculateFinalSize(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenDiagonal = math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
    return screenDiagonal; // Slightly increase the size
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isAnimationInitialized && mounted) {
      finalSize = calculateFinalSize(context); // Calculate final size here
      animation = Tween<double>(begin: 0, end: finalSize).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInExpo),
      )..addListener(() {
        setState(() {}); // This triggers the widget to rebuild with the new animation value
      });
      isAnimationInitialized = true; // Ensure this is set to true
      controller.forward().whenComplete(() {
        navigateToMainApp(context);
      });
    }

    return Scaffold(
      body: Center(
        child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (isAnimationInitialized && animation != null) // Check both conditions
                AnimatedBuilder(
                  animation: animation!,
                  builder: (context, child) {
                    return Container(
                      width: animation!.value,
                      height: animation!.value,
                      decoration: BoxDecoration(
                        color: Color(0xFFececec),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),

              SvgPicture.asset('assets/images/logo.svg', width: 150, height: 150),
            ],
          ),
        ),
      ),
    );
  }
}