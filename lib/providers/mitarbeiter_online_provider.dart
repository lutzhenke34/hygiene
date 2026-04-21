import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final onlineMitarbeiterProvider =
    StreamProvider.family<int, String>((ref, String betriebId) {
  final client = Supabase.instance.client;
  final controller = StreamController<int>();
  final channel = client.channel('online-users');

  void emitCount() {
    final presenceState = channel.presenceState();
    final onlineUsers = <String>{};

    for (final presence in presenceState) {
      final payload = presence.payload;
      final payloadBetriebId = payload['betrieb_id'];
      final role = payload['role'];
      final userId = payload['user_id'];

      if (payloadBetriebId == betriebId &&
          role != 'admin' &&
          userId is String &&
          userId.isNotEmpty) {
        onlineUsers.add(userId);
      }
    }

    controller.add(onlineUsers.length);
  }

  channel
      .onPresenceSync((_) => emitCount())
      .subscribe((status, [error]) {
    if (status == RealtimeSubscribeStatus.subscribed) {
      emitCount();
    }
  });

  ref.onDispose(() async {
    await channel.unsubscribe();
    await client.removeChannel(channel);
    await controller.close();
  });

  return controller.stream;
});
