import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

import '../features/dashboard/models/mitarbeiter.dart';

part 'mitarbeiter_provider.g.dart';

final supabase = Supabase.instance.client;

@riverpod
class MitarbeiterNotifier extends _$MitarbeiterNotifier {
  @override
  Future<List<Mitarbeiter>> build(String betriebId) async {
    final data = await supabase
        .from('mitarbeiter')
        .select()
        .eq('betrieb_id', betriebId)
        .order('nachname');

    return data.map((e) => Mitarbeiter.fromJson(e)).toList();
  }

  Future<void> addOrUpdate(Mitarbeiter m) async {
    try {
      if (m.id.isEmpty) {
        await supabase.from('mitarbeiter').insert(m.toJson());
      } else {
        await supabase
            .from('mitarbeiter')
            .update(m.toJson())
            .eq('id', m.id);
      }
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler bei addOrUpdate: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await supabase.from('mitarbeiter').delete().eq('id', id);
      ref.invalidateSelf();
    } catch (e) {
      print('❌ Fehler beim Löschen: $e');
      rethrow;
    }
  }

  /// 🔥 Verbesserte Upload-Funktion für Hygieneausweis
  Future<String?> uploadHygieneausweis(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      if (bytes.isEmpty) {
        throw Exception('Datei ist leer (0 Bytes)');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanFileName = fileName
          .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
          .toLowerCase();

      final path = 'ausweise/${timestamp}_$cleanFileName';

      // Content-Type
      String? contentType;
      final lowerName = fileName.toLowerCase();
      if (lowerName.endsWith('.pdf')) {
        contentType = 'application/pdf';
      } else if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      } else if (lowerName.endsWith('.png')) {
        contentType = 'image/png';
      } else {
        contentType = 'application/octet-stream';
      }

      // ←←← WICHTIG: Genau so wie im Supabase Dashboard!
      const String bucketName = 'Hygieneausweis';

      print('📤 Upload startet...');
      print('   Bucket     : $bucketName');
      print('   Pfad       : $path');
      print('   Dateiname  : $fileName');
      print('   Größe      : ${bytes.length} Bytes');
      print('   Content-Type: $contentType');

      final String uploadedPath = await supabase.storage
          .from(bucketName)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl = supabase.storage.from(bucketName).getPublicUrl(uploadedPath);

      print('✅ Upload ERFOLGREICH!');
      print('🔗 Public URL: $publicUrl');

      return publicUrl;
    } catch (e, stack) {
      print('❌ Upload FEHLER: $e');
      print('Stack trace:\n$stack');

      if (e.toString().contains('Bucket') || e.toString().contains('bucket')) {
        print('🔥 TIPP: Überprüfe ob der Bucket-Name exakt "Hygieneausweis" im Dashboard steht!');
      }

      rethrow;
    }
  }
}