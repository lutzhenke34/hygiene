import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider für die ausgewählte Betrieb-ID (String?)
final selectedBetriebIdProvider = StateProvider<String?>((ref) => null);

// Async-Notifier, der beim App-Start die ID aus SharedPreferences lädt
final selectedBetriebInitializerProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final lastId = prefs.getString('last_selected_betrieb_id');
  if (lastId != null) {
    ref.read(selectedBetriebIdProvider.notifier).state = lastId;
  }
});

// Hilfsfunktion zum Speichern (kannst du später aufrufen)
Future<void> saveSelectedBetrieb(String? id) async {
  final prefs = await SharedPreferences.getInstance();
  if (id != null) {
    await prefs.setString('last_selected_betrieb_id', id);
  } else {
    await prefs.remove('last_selected_betrieb_id');
  }
}