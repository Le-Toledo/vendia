import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/clients/presentation/clients_screen.dart';
import 'features/clients/presentation/client_form_screen.dart';
import 'features/quotes/presentation/quotes_screen.dart';
import 'features/quotes/presentation/quote_form_screen.dart';
import 'features/contracts/presentation/contracts_screen.dart';
import 'features/finance/presentation/finance_screen.dart';
import 'features/marketing/presentation/marketing_hub_screen.dart';
import 'features/chat_ai/presentation/chat_ai_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/settings/presentation/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VendeAiApp()));
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
        path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen()),
    GoRoute(
        path: '/clients', builder: (context, state) => const ClientsScreen()),
    GoRoute(
        path: '/clients/new',
        builder: (context, state) => const ClientFormScreen()),
    GoRoute(
      path: '/clients/edit',
      builder: (context, state) => ClientFormScreen(
        clientToEdit: state.extra as Map<String, String>?,
      ),
    ),
    GoRoute(path: '/quotes', builder: (context, state) => const QuotesScreen()),
    GoRoute(
      path: '/quotes/new',
      builder: (context, state) => QuoteFormScreen(
        quoteToEdit: state.extra as Map<String, dynamic>?,
      ),
    ),
    GoRoute(
        path: '/contracts',
        builder: (context, state) => const ContractsScreen()),
    GoRoute(
        path: '/finance', builder: (context, state) => const FinanceScreen()),
    GoRoute(
        path: '/marketing',
        builder: (context, state) => const MarketingHubScreen()),
    GoRoute(
        path: '/chat-ai', builder: (context, state) => const ChatAiScreen()),
    GoRoute(
        path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
);

class VendeAiApp extends StatelessWidget {
  const VendeAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VendeAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
    );
  }
}
