import 'package:biz_hub/screens/auth/forget_password_screen.dart';
import 'package:biz_hub/screens/auth/login_screen.dart';
import 'package:biz_hub/screens/auth/signup_screen.dart';
import 'package:biz_hub/screens/company/add_comapny_screen.dart';
import 'package:biz_hub/screens/company/company_detail_screen.dart';
import 'package:biz_hub/screens/company/edit_comapny_details_screen.dart';
import 'package:biz_hub/screens/home/home_screen.dart';
import 'package:biz_hub/screens/profile/edit-profile_screen.dart';
import 'package:biz_hub/screens/profile/user_profile_screen.dart';
import 'package:biz_hub/screens/tools/resume_builder_screen.dart';
import 'package:biz_hub/screens/tools/tools_dashboard_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  // Static route names for easy reference
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String splash = '/splash';
  static const String home = '/home';
  static const String companyDetail = '/company';
  static const String addCompany = '/company/add';
  static const String editCompany = '/company/edit';
  static const String userProfile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String toolsDashboard = '/tools';
  static const String resumeBuilder = '/tools/resume-builder';
  static const String ocrTextExtraction = '/tools/ocr-extraction';
  static const String businessCardScanner = '/tools/business-card-scanner';

  // The onGenerateRoute implementation for traditional Flutter navigation
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Authentication Routes
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());

      // Home Route
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      // Company Routes
      // case companyDetail:
      //   if (args is String) {
      //     return MaterialPageRoute(
      //       builder: (_) => CompanyDetailScreen(company: args)
      //     );
      //   }
      //   return _errorRoute();
      // case editCompany:
      //   if (args is String) {
      //     return MaterialPageRoute(
      //       builder: (_) => EditCompanyScreen(companyId: args)
      //     );
      //   }
      //   return _errorRoute();

      case addCompany:
        try {
          return MaterialPageRoute(builder: (_) => AddCompanyScreen());
        } catch (e) {
          print("Error in addCompany route: $e");
          return _errorRoute();
        }

      // Profile Routes
      case userProfile:
        if (args is String) {
          return MaterialPageRoute(
              builder: (_) => UserProfileScreen(userId: args));
        }
        return _errorRoute();
      // case editProfile:
      //   if (args is String) {
      //     return MaterialPageRoute(
      //       builder: (_) => UserEditScreen(userId: args)
      //     );
      //   }
      //   return _errorRoute();

      // Tools Routes
      case toolsDashboard:
        return MaterialPageRoute(builder: (_) => ToolsDashboardScreen());
      case resumeBuilder:
        return MaterialPageRoute(builder: (_) => ResumeBuilderScreen());
      case ocrTextExtraction:
        // Uncomment when implemented
        // return MaterialPageRoute(builder: (_) => OcrTextExtractionScreen());
        return _errorRoute();
      case businessCardScanner:
        // Uncomment when implemented
        // return MaterialPageRoute(builder: (_) => BusinessCardScannerScreen());
        return _errorRoute();

      // Default 404 error page
      default:
        return _errorRoute();
    }
  }

  // Error route for 404 page not found
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '404 - Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'The page you are looking for does not exist.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, home),
                child: Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Helper method for navigation using the traditional approach
  static void navigateTo(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  // Helper method to replace the current route
  static void navigateReplace(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  // Helper method to pop all routes and navigate to a new one
  static void navigateAndRemoveUntil(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
        context, routeName, (Route<dynamic> route) => false,
        arguments: arguments);
  }
}

// Extension to simplify navigation with the traditional Flutter approach
extension NavigationExtensions on BuildContext {
  void goToLogin() => Navigator.pushNamed(this, AppRoutes.login);
  void goToSignup() => Navigator.pushNamed(this, AppRoutes.signup);
  void goToHome() => Navigator.pushNamed(this, AppRoutes.home);
  void goToUserProfile(String userId) =>
      Navigator.pushNamed(this, AppRoutes.userProfile, arguments: userId);
  void goToCompanyDetail(String companyId) =>
      Navigator.pushNamed(this, AppRoutes.companyDetail, arguments: companyId);
  void goToToolsDashboard() =>
      Navigator.pushNamed(this, AppRoutes.toolsDashboard);
}
