import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:grocery/helpers/project_configuration.dart';
import 'package:grocery/transitions/FadeRoute.dart';
import 'package:grocery/ui/landing.dart';
import 'package:grocery/ui/on_boarding_screen.dart';
import 'package:grocery/widgets/transparent_image.dart';

class SplashScreen extends StatelessWidget {
  ///Check if first launch to redirect to onBoarding screen
  Future<bool> checkFirstLaunch(BuildContext context) async {
    GetStorage storage = GetStorage();

    ///Clear any data and let only isDark and firstLaunch
    try {
      await Future.forEach(storage.getKeys(), (key) async {
        if (!['firstLaunch', 'isDark'].contains(key)) {
          print(key);
          await storage.remove(key.toString());
        }
      });
    } catch (e) {
      print(e);
    }

    ///Clear firebase cache
    await FirebaseFirestore.instance.clearPersistence();

    await Future.delayed(Duration(milliseconds: 1500));

    ///Precache images for better performance
    ///Precache png images
    await Future.forEach<String>(ProjectConfiguration.pngImages, (image) async {
      await precacheImage(AssetImage(image), context);
    });

    ///Precache svg images
    await Future.forEach<String>(ProjectConfiguration.svgImages, (image) async {
      await precachePicture(
          ExactAssetPicture(SvgPicture.svgStringDecoderBuilder, image),
          context);
    });

    ///Check if first launch
    if (storage.hasData("firstLaunch")) {
      return false;
    } else {
      await storage.write("firstLaunch", true);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<bool>(
          future: checkFirstLaunch(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              ///Redirect to onBoarding screen if first launch else to Landing page
              if (snapshot.hasData) {
                if (snapshot.data!) {
                  // SchedulerBinding.instance.addPostFrameCallback((_) {
                  //   Navigator.pushReplacement(
                  //       context, FadeRoute(page: OnBoardingScreen()));
                  // });
                } else {
                  // SchedulerBinding.instance.addPostFrameCallback((_) {
                  //   Landing.create(context);
                  // });
                }
              }
            }

            return Center(
              child: FadeInImage(
                image: AssetImage(ProjectConfiguration.logo),
                placeholder: MemoryImage(kTransparentImage),
                width: 100,
                height: 100,
              ),
            );
          },
        ),
      ),
    );
  }
}
