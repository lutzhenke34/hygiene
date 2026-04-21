import 'package:supabase_flutter/supabase_flutter.dart';

class PresenceService {
  final _client = Supabase.instance.client;
  RealtimeChannel? _channel;

  void start({
    required String userId,
    String? betriebId,
    String? role,
  }) {
    stop();

    _channel = _client.channel('online-users');

    _channel!
        .onPresenceSync((_) {})
        .subscribe((status, [error]) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _channel!.track({
          'user_id': userId,
          'betrieb_id': betriebId,
          'role': role,
          'online_at': DateTime.now().toUtc().toIso8601String(),
        });
      }
    });
  }

  void stop() {
    if (_channel != null) {
      _channel!.untrack();
      _client.removeChannel(_channel!);
      _channel = null;
    }
  }
}
