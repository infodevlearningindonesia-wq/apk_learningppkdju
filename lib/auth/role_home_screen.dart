library devlearning_roles;

import 'dart:io';

import 'package:devlearning_indonesia/adminmaster/admin_account_policy.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:devlearning_indonesia/about/about_screen.dart';
import 'package:devlearning_indonesia/auth/login_screen.dart';
import 'package:devlearning_indonesia/auth/register/register_screen.dart';
import 'package:devlearning_indonesia/database/database_helper.dart';
import 'package:devlearning_indonesia/peserta/home_screen.dart';
import 'package:devlearning_indonesia/models/user.dart';
import 'package:devlearning_indonesia/models/attendance_record.dart';
import 'package:devlearning_indonesia/models/learning_material.dart';
import 'package:devlearning_indonesia/services/preference_handler.dart';
import 'package:sqflite/sqflite.dart';

part '../adminmaster/admin_home_screen.dart';
part '../adminmaster/admin_activity_screen.dart';
part '../adminmaster/admin_users_screen.dart';
part '../adminmaster/admin_widgets.dart';
part '../pengajar/pengajar_home_screen.dart';
part '../pengajar/teacher_materials_screen.dart';
part '../pengajar/teacher_participants_screen.dart';
part '../pengajar/teacher_attendance_screen.dart';
part '../peserta/peserta_home_screen.dart';
part 'role_profile_screen.dart';
part 'widgets/role_header.dart';
part 'widgets/action_card.dart';

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        switch (UserRoleX.fromValue(user['role'] as String?)) {
          case UserRole.admin:
            return AdminHomeScreen(user: user);
          case UserRole.pengajar:
            return PengajarHomeScreen(user: user);
          case UserRole.peserta:
            return const PesertaHomeScreen();
        }
      },
    );
  }

  Future<Map<String, dynamic>?> _loadCurrentUser() async {
    if (!PreferenceHandler.isLogin) return null;
    final email = PreferenceHandler.userEmail;
    if (email == null || email.isEmpty) return null;
    final user = await DatabaseHelper.instance.getUserByEmail(email);
    if (user == null) {
      await PreferenceHandler.clearSession();
    }
    return user;
  }
}
