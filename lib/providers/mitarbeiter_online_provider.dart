import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final onlineMitarbeiterIdsProvider =
    StreamProvider.family<Set<String>, String>((ref, String betriebId) {
  final client = Supabase.instance.client;
  final controller = StreamController<Set<String>>();
  final channel = client.channel('online-users');

  void emitIds() {
    final presenceState = channel.presenceState();
    final onlineUsers = <String>{};

    for (final singleState in presenceState) {
      for (final presence in singleState.presences) {
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
    }

    controller.add(onlineUsers);
  }

  channel
      .onPresenceSync((_) => emitIds())
      .subscribe((status, [error]) {
    if (status == RealtimeSubscribeStatus.subscribed) {
      emitIds();
    }
  });

  ref.onDispose(() async {
    await channel.unsubscribe();
    await client.removeChannel(channel);
    await controller.close();
  });

  return controller.stream;
});

final onlineMitarbeiterProvider =
    Provider.family<AsyncValue<int>, String>((ref, String betriebId) {
  final onlineIdsAsync = ref.watch(onlineMitarbeiterIdsProvider(betriebId));
  return onlineIdsAsync.whenData((ids) => ids.length);
});
