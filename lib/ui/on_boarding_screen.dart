import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/ui/landing.dart';
import 'package:grocery/widgets/buttons/default_button.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with TickerProviderStateMixin<OnBoardingScreen> {
  PageController pageViewController = PageController();

  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final themeModel = Provider.of<ThemeModel>(context);

    List<Widget> screens = [
      ///First page
      Container(
        padding: const EdgeInsets.all(20),
        color: themeModel.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: themeModel.secondBackgroundColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(height * 0.2))),
                child: SvgPicture.asset(
                  "images/on_boarding/1.svg",
                  height: height * 0.4,
                )),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Quickly search and add\nhealthy foods to your cart!',
                  style: themeModel.theme.textTheme.headline3!
                      .apply(color: themeModel.secondTextColor),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),

      ///Second Page
      Container(
        padding: const EdgeInsets.all(20),
        color: themeModel.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: themeModel.secondBackgroundColor,
                  borderRadius:
                      BorderRadius.all(Radius.circular(height * 0.2))),
              child: SvgPicture.asset(
                "images/on_boarding/2.svg",
                height: height * 0.4,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Super fast delivery\n within two hours!',
                  style: themeModel.theme.textTheme.headline3!
                      .apply(color: themeModel.secondTextColor),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),

      ///Third page
      Container(
        padding: const EdgeInsets.all(20),
        color: themeModel.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: themeModel.secondBackgroundColor,
                    borderRadius:
                        BorderRadius.all(Radius.circular(height * 0.2))),
                child: SvgPicture.asset(
                  "images/on_boarding/3.svg",
                  height: height * 0.4,
                )),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Easy payment in delivery!',
                  style: themeModel.theme.textTheme.headline3!
                      .apply(color: themeModel.secondTextColor),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    ];

    return Scaffold(
      body: Container(
        color: themeModel.secondBackgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: height * 0.80,
              child: PageView(
                controller: pageViewController,
                children: screens,
                onPageChanged: (index) {
                  setState(() {
                    pageIndex = index;
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: themeModel.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 10,
                    margin: const EdgeInsets.only(right: 10, left: 10),
                    width: (pageIndex == 0) ? 20 : 10,
                    decoration: BoxDecoration(
                      color: (pageIndex == 0)
                          ? themeModel.accentColor
                          : themeModel.secondTextColor,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 10,
                    margin: const EdgeInsets.only(right: 10),
                    width: (pageIndex == 1) ? 20 : 10,
                    decoration: BoxDecoration(
                      color: (pageIndex == 1)
                          ? themeModel.accentColor
                          : themeModel.secondTextColor,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 10,
                    margin: const EdgeInsets.only(right: 10),
                    width: (pageIndex == 2) ? 20 : 10,
                    decoration: BoxDecoration(
                      color: (pageIndex == 2)
                          ? themeModel.accentColor
                          : themeModel.secondTextColor,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Center(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: (pageIndex == 2)
                    ? SizedBox(
                        width: double.infinity,
                        child: DefaultButton(
                            padding: const EdgeInsets.all(10),
                            widget: Text(
                              'Get Started',
                              style: themeModel.theme.textTheme.headline3!
                                  .apply(color: Colors.white),
                            ),
                            onPressed: () {
                              Landing.create(context);
                            },
                            color: themeModel.accentColor),
                      )
                    : GestureDetector(
                        onTap: () {
                          Landing.create(context);
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.all(10),
                          child: FadeIn(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                'Skip',
                                style: themeModel.theme.textTheme.headline3,
                              )),
                        ),
                      ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
