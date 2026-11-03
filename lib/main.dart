import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'state/auth_state.dart';
import 'state/theme_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge to edge immersive Android / iOS system bar handling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final authState = AuthState();
  final themeState = ThemeState();

  await authState.initialize();

  runApp(EssaneMobileApp(
    authState: authState,
    themeState: themeState,
  ));
}

class EssaneMobileApp extends StatelessWidget {
  final AuthState authState;
  final ThemeState themeState;
  late final AppRouter _appRouter;

  EssaneMobileApp({
    super.key,
    required this.authState,
    required this.themeState,
  }) {
    _appRouter = AppRouter(authState: authState, themeState: themeState);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([authState, themeState]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Essane Management',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          onGenerateInitialRoutes: (String initialRouteName) {
            return [
              _appRouter.buildSplashRoute(targetRoute: initialRouteName),
            ];
          },
          onGenerateRoute: _appRouter.onGenerateRoute,
        );
      },
    );
  }
}
