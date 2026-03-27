import 'database_service.dart';
import 'connectivity_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SyncService {
  static Future<void> syncVisits() async {
    if (!await ConnectivityService.isOnline()) return;
    final unsynced = await DatabaseService.getUnsyncedVisits();
    for (final visit in unsynced) {
      // Replace with your backend API endpoint
      final response = await http.post(
        Uri.parse('https://your-backend.com/api/visits'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(visit),
      );
      if (response.statusCode == 200) {
        await DatabaseService.markVisitSynced(visit['id']);
      }
    }
  }
}
