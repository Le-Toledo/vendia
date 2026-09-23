import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/app_shell.dart';
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
import 'features/contracts/presentation/contract_form_screen.dart';
import 'features/quotes/presentation/quote_detail_screen.dart';
import 'features/auth/application/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VendeAiApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (auth.isLoading) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }
      final signedIn = auth.valueOrNull != null;
      final authRoute = [
        '/login',
        '/register',
        '/forgot-password',
        '/splash',
      ].contains(state.matchedLocation);
      if (!signedIn && (!authRoute || state.matchedLocation == '/splash')) {
        return '/login';
      }
      if (signedIn && authRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(path: '/clients', builder: (_, __) => const ClientsScreen()),
          GoRoute(
            path: '/clients/new',
            builder: (context, state) => const ClientFormScreen(),
          ),
          GoRoute(
            path: '/clients/edit',
            builder: (context, state) => ClientFormScreen(
              clientToEdit: state.extra as Map<String, dynamic>?,
            ),
          ),
          GoRoute(
            path: '/quotes',
            builder: (context, state) => const QuotesScreen(),
          ),
          GoRoute(
            path: '/contracts',
            builder: (context, state) => const ContractsScreen(),
          ),
          GoRoute(
            path: '/finance',
            builder: (context, state) => const FinanceScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/contracts/form',
        builder: (context, state) => ContractFormScreen(
          contractToEdit: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: '/quotes/new',
        builder: (context, state) =>
            QuoteFormScreen(quoteToEdit: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: '/quotes/detail',
        builder: (context, state) =>
            QuoteDetailScreen(quote: state.extra! as Map<String, dynamic>),
      ),
      GoRoute(
        path: '/marketing',
        builder: (context, state) => const MarketingHubScreen(),
      ),
      GoRoute(
        path: '/chat-ai',
        builder: (context, state) => const ChatAiScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
  // Reevaluate redirects without replacing the router or the current form.
  ref.listen(authControllerProvider, (_, __) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});

class VendeAiApp extends ConsumerWidget {
  const VendeAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'VendeAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeControllerProvider),
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
    );
  }
}
