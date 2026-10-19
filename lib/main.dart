import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/security/security_engine.dart';
import 'core/telemetry/native_crash_bridge.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize NDK Crash & ANR signal interception bridge (libndk-crash & libndk-anr)
  NativeCrashBridge().initialize();

  // 2. Initialize Native Security Engine & Device Attestation (libse_loader & libse)
  await SecurityEngine().initialize();

  // 3. Set system overlay styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const UberReconstructedApp());
}

class UberReconstructedApp extends StatelessWidget {
  const UberReconstructedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber Mobile Architecture',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeMapScreen(),
    );
  }
}
