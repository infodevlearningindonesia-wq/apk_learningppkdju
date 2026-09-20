import 'package:devlearning_indonesia/splash/splash_screen.dart';
import 'package:devlearning_indonesia/database/database_platform.dart';
import 'package:devlearning_indonesia/services/preference_handler.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await initializeDatabasePlatform();
	await PreferenceHandler.init();
	runApp(const DevLearningApp());
}

class DevLearningApp extends StatelessWidget {
	const DevLearningApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: 'DevLearning Indonesia',
			theme: ThemeData(
				useMaterial3: true,
				colorScheme: ColorScheme.fromSeed(
					seedColor: const Color(0xFF3F7D27),
					brightness: Brightness.light,
				),
				scaffoldBackgroundColor: const Color(0xFFF8FBF4),
				fontFamily: 'sans',
			),
			home:  SplashScreen(),
		);
	}
}
