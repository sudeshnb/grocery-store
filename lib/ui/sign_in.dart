import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:grocery/helpers/project_configuration.dart';
import 'package:grocery/models/state_models/sign_in_model.dart';
import 'package:grocery/models/state_models/theme_model.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/widgets/buttons/default_button.dart';
import 'package:grocery/widgets/buttons/social_button.dart';
import 'package:grocery/widgets/fade_in.dart';
import 'package:grocery/widgets/text_fields/email_text_field.dart';
import 'package:grocery/widgets/transparent_image.dart';

class SignIn extends StatefulWidget {
  final SignInModel model;

  const SignIn({Key? key, required this.model}) : super(key: key);

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    return ChangeNotifierProvider<SignInModel>(
      create: (BuildContext context) =>
          SignInModel(auth: auth, database: database),
      child: Consumer<SignInModel>(
        builder: (context, model, _) {
          return SignIn(
            model: model,
          );
        },
      ),
    );
  }

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin<SignIn> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode fullNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void dispose() {
    super.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullNameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Center(
        child: NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FadeInImage(
              image: AssetImage(ProjectConfiguration.logo),
              placeholder: MemoryImage(kTransparentImage),
              width: 100,
              height: 100,
            ),
          ),

          ///Full name field
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: widget.model.isSignedIn
                ? const SizedBox()
                : EmailTextField(
                    isLoading: widget.model.isLoading,
                    textEditingController: fullNameController,
                    focusNode: fullNameFocus,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    labelText: "Full Name",
                    iconData: Icons.person_outline,
                    onSubmitted: () {
                      _fieldFocusChange(context, fullNameFocus, emailFocus);
                    },
                    error: !widget.model.validName),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: (!widget.model.validName && !widget.model.isSignedIn)
                ? FadeIn(
                    child: Text(
                    "Please enter a valid name",
                    style: themeModel.theme.textTheme.subtitle2!
                        .apply(color: Colors.red),
                  ))
                : const SizedBox(),
          ),

          ///Email field
          EmailTextField(
              textEditingController: emailController,
              isLoading: widget.model.isLoading,
              focusNode: emailFocus,
              textInputAction: TextInputAction.next,
              textInputType: TextInputType.emailAddress,
              labelText: "Email",
              iconData: Icons.email,
              onSubmitted: () {
                _fieldFocusChange(context, emailFocus, passwordFocus);
              },
              error: !widget.model.validEmail),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: (!widget.model.validEmail)
                ? FadeIn(
                    child: Text(
                    "Please enter a valid email",
                    style: themeModel.theme.textTheme.subtitle2!
                        .apply(color: Colors.red),
                  ))
                : const SizedBox(),
          ),

          ///Password field
          EmailTextField(
              textEditingController: passwordController,
              isLoading: widget.model.isLoading,
              focusNode: passwordFocus,
              textInputAction: TextInputAction.done,
              textInputType: TextInputType.text,
              obscureText: true,
              labelText: "Password",
              iconData: Icons.lock_outline,
              onSubmitted: () {
                widget.model.isSignedIn
                    ? widget.model.signInWithEmail(
                        context, emailController.text, passwordController.text)
                    : widget.model.createAccount(context, emailController.text,
                        passwordController.text, fullNameController.text);
              },
              error: !widget.model.validPassword),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: (!widget.model.validPassword)
                ? FadeIn(
                    child: Text(
                    'Please enter a valid password : don\'t forget numbers, special characters(@, # ...), capital letters',
                    style: themeModel.theme.textTheme.subtitle2!
                        .apply(color: Colors.red),
                  ))
                : const SizedBox(),
          ),

          ///Sign in button / Loading
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: widget.model.isLoading
                ? const Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : DefaultButton(
                    color: themeModel.accentColor,
                    widget: Text(
                      widget.model.isSignedIn ? "SIGN IN" : "CREATE AN ACCOUNT",
                      style: themeModel.theme.textTheme.headline3!.apply(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: widget.model.isSignedIn
                        ? () {
                            widget.model.signInWithEmail(context,
                                emailController.text, passwordController.text);
                          }
                        : () {
                            widget.model.createAccount(
                                context,
                                emailController.text,
                                passwordController.text,
                                fullNameController.text);
                          },
                  ),
          ),

          ///Social Media buttons
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: <Widget>[
                const Spacer(),
                SocialButton(
                    path: "images/sign_in/facebook.svg",
                    color: const Color(0xFF3b5998),
                    onPressed: !widget.model.isLoading
                        ? () {
                            widget.model.signInWithFacebook(context);
                          }
                        : () {}),
                const Spacer(),
                SocialButton(
                    path: "images/sign_in/google.svg",
                    color: Colors.white,
                    onPressed: !widget.model.isLoading
                        ? () {
                            widget.model.signInWithGoogle(context);
                          }
                        : () {}),
                const Spacer(),
              ],
            ),
          ),

          ///Switch  Sign In <--> Create Account
          Align(
            alignment: Alignment.center,
            child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: GestureDetector(
                    onTap: !widget.model.isLoading
                        ? () {
                            //Clear textFields data if switching to create account or signIn
                            widget.model.changeSignStatus();

                            fullNameController.clear();
                            emailController.clear();
                            passwordController.clear();
                            fullNameFocus.unfocus();
                            emailFocus.unfocus();
                            passwordFocus.unfocus();
                          }
                        : null,
                    child: Text(
                        widget.model.isSignedIn ? "Create Account" : "Sign In",
                        style: themeModel.theme.textTheme.headline3))),
          ),
        ],
      ),
    ));
  }
}
