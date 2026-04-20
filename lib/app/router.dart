import 'package:go_router/go_router.dart';
import '../features/features/presentation/betriebe_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BetriebePage(),
    ),
  ],
);