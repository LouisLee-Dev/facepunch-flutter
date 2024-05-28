import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'lang/l10n.dart';
import 'config/app_const.dart';
import 'screens/splash_screen.dart';
import 'widgets/spin_circle.dart';
import '/providers/app_provider.dart';
import '/providers/company_provider.dart';
import '/providers/harvest_provider.dart';
import '/providers/notification_provider.dart';
import '/providers/revision_provider.dart';
import '/providers/user_provider.dart';
import '/providers/work_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
  );
  runApp(
      MultiProvider(
          providers:[
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => CompanyProvider()),
            ChangeNotifierProvider(create: (_) => RevisionProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => HarvestProvider()),
            ChangeNotifierProvider(create: (_) => WorkProvider()),
          ],
          child: MyApp()
      )
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      useDefaultLoading: false,
      overlayWidget: SpinKitCircle(color: Colors.white, size: 60,),
      overlayColor: Colors.black.withOpacity(0.6),
      overlayOpacity: 1,
      child: MaterialApp(
        title: 'FacePunch',
        debugShowCheckedModeBanner: context.watch<AppProvider>().isDebug,
        theme: ThemeData(
          splashColor: Color(primaryColor),
          primaryColor: Color(primaryColor),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        locale: Locale(context.watch<UserProvider>().locale),
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: SplashScreen(),
      ),
    );
  }

}


