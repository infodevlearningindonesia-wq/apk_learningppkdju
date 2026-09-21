import 'package:devlearning_indonesia/splash/splash_screen.dart';
import 'package:devlearning_indonesia/database/database_platform.dart';
import 'package:devlearning_indonesia/services/preference_handler.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await initializeDatabasePlatform();
	await PreferenceHandler.init();
	await PreferenceHandler.recordAppVisit();
	runApp(const DevLearningApp());
}

class DevLearningApp extends StatelessWidget {
	const DevLearningApp({super.key});

	@override
	Widget build(BuildContext context) {
		final lightColorScheme = ColorScheme.fromSeed(
			seedColor: const Color(0xFF1E8E3E),
			brightness: Brightness.light,
		);

		final darkColorScheme = ColorScheme.fromSeed(
			seedColor: const Color(0xFF1E8E3E),
			brightness: Brightness.dark,
		);

		final baseTheme = ThemeData(
			useMaterial3: true,
			fontFamily: 'sans',
			typography: Typography.material2021(),
		);

		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: 'DevLearning Indonesia',
			themeMode: ThemeMode.system,
			theme: baseTheme.copyWith(
				colorScheme: lightColorScheme,
				scaffoldBackgroundColor: const Color(0xFFF5F7F3),
				appBarTheme: const AppBarTheme(
					centerTitle: true,
					elevation: 0,
					backgroundColor: Color(0xFFF5F7F3),
					foregroundColor: Color(0xFF183A2E),
				),
				cardTheme: CardThemeData(
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(20),
					),
					elevation: 0,
					margin: EdgeInsets.zero,
				),
				elevatedButtonTheme: ElevatedButtonThemeData(
					style: ElevatedButton.styleFrom(
						padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(16),
						),
						elevation: 0,
						foregroundColor: Colors.white,
						backgroundColor: lightColorScheme.primary,
						textStyle: const TextStyle(
							fontSize: 15,
							fontWeight: FontWeight.w700,
						),
					),
				),
				filledButtonTheme: FilledButtonThemeData(
					style: FilledButton.styleFrom(
						padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(16),
						),
					),
				),
				inputDecorationTheme: InputDecorationTheme(
					filled: true,
					fillColor: Colors.white,
					contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(16),
						borderSide: BorderSide(color: lightColorScheme.outlineVariant),
					),
					enabledBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(16),
						borderSide: BorderSide(color: lightColorScheme.outlineVariant),
					),
					focusedBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(16),
						borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
					),
					labelStyle: TextStyle(color: lightColorScheme.onSurfaceVariant),
				),
			),
			darkTheme: baseTheme.copyWith(
				colorScheme: darkColorScheme,
				scaffoldBackgroundColor: const Color(0xFF101A14),
				appBarTheme: const AppBarTheme(
					centerTitle: true,
					elevation: 0,
					backgroundColor: Color(0xFF101A14),
					foregroundColor: Colors.white,
				),
				cardTheme: CardThemeData(
					shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(20),
					),
					elevation: 0,
					margin: EdgeInsets.zero,
				),
				elevatedButtonTheme: ElevatedButtonThemeData(
					style: ElevatedButton.styleFrom(
						padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(16),
						),
						elevation: 0,
						foregroundColor: Colors.white,
						backgroundColor: darkColorScheme.primary,
						textStyle: const TextStyle(
							fontSize: 15,
							fontWeight: FontWeight.w700,
						),
					),
				),
				filledButtonTheme: FilledButtonThemeData(
					style: FilledButton.styleFrom(
						padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(16),
						),
					),
				),
				inputDecorationTheme: InputDecorationTheme(
					filled: true,
					fillColor: const Color(0xFF1B2A22),
					contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
					border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(16),
						borderSide: BorderSide(color: darkColorScheme.outlineVariant),
					),
					enabledBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(16),
						borderSide: BorderSide(color: darkColorScheme.outlineVariant),
					),
					focusedBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(16),
						borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
					),
					labelStyle: TextStyle(color: darkColorScheme.onSurfaceVariant),
				),
			),
			home: const SplashScreen(),
		);
	}
}
