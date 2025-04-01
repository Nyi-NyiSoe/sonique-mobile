import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonique/Representation/widgets/CustomButton.dart';
import 'package:sonique/core/theme/services/routes/routes.dart';
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Stack(
              children: [
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Hero(
                      tag: "logo",
                      transitionOnUserGestures: true,
                      child: Image.asset(
                        "assets/images/music.png",
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 220,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "S O N I Q U E",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 63, 62, 62),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),

                          Text(
                            "Discover new music, create playlists, and enjoy your favorite songs.",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          CustomElevatedButton(
                            width: double.infinity,
                            height: 50,
                            child: Text(
                              'Login',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            onPressed: () {
                              context.go(Routes.login);
                            },
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                " Or Create an Account",
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                              SizedBox(width: 20),
                              Icon(Icons.arrow_forward_sharp, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
