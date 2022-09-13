import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:grocery/helpers/project_configuration.dart';
import 'package:grocery/models/data_models/app_notification.dart';
import 'package:grocery/services/auth.dart';
import 'package:grocery/services/cloud_functions.dart';
import 'package:grocery/services/database.dart';
import 'package:grocery/ui/splash_screen.dart';
import 'package:provider/provider.dart';
import 'blocs/cart_bloc.dart';
import 'models/state_models/theme_model.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///Initialize Firebase
  await Firebase.initializeApp();

  ///Initialize Storage
  await GetStorage.init();

  ///Initialize Firebase messaging
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  ///Request notifications permission
  await _firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  ///Show foreground notifications
  FirebaseMessaging.onMessage.listen(myBackgroundMessageHandler);

  ///Show background notifications
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);

  runApp(const MyApp());
}

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  showNotification(AppNotification.fromMap(message.data));
}

///Show notification
Future<void> showNotification(AppNotification notification) async {}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ///Check dark mode
    final storage = GetStorage();
    bool isDark = false;
    if (storage.hasData('isDark')) {
      isDark = storage.read('isDark') ?? false;
    }

    final database = FirestoreDatabase();
    final auth = Auth();

    final providers = [
      ///Auth provider
      Provider<AuthBase>(create: (context) => auth),

      ///Database(Firestore) provider
      Provider<Database>(create: (context) => database),

      ///Cart provider
      Provider<CartBloc>(
          create: (context) => CartBloc(database: database, auth: auth))
    ];

    ///If we use cloud functions, add his provider
    if (ProjectConfiguration.useCloudFunctions) {
      providers.add(Provider<CloudFunctions>(
        create: (context) => CloudFunctions(),
      ));
    }

    return MultiProvider(
      providers: providers,
      child: ChangeNotifierProvider<ThemeModel>(
        create: (context) =>
            ThemeModel(theme: isDark ? ThemeModel.dark : ThemeModel.light),
        child: Consumer<ThemeModel>(
          builder: (context, themeModel, _) {
            return MaterialApp(
              title: 'Grocery App',
              theme: themeModel.theme,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
