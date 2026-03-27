import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class SentinelLiveUpdate {
  const SentinelLiveUpdate({
    required this.status,
    required this.message,
    required this.confidence,
    required this.hemoglobinEstimate,
    required this.riskLevel,
  });

  final String status;
  final String message;
  final double confidence;
  final double? hemoglobinEstimate;
  final String? riskLevel;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'confidence': confidence,
      'hemoglobin_estimate': hemoglobinEstimate,
      'risk_level': riskLevel,
    };
  }

  factory SentinelLiveUpdate.fromJson(Map<String, dynamic> json) {
    return SentinelLiveUpdate(
      status: json['status']?.toString() ?? 'scanning',
      message: json['message']?.toString() ?? 'Processing frame...',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      hemoglobinEstimate: (json['hemoglobin_estimate'] as num?)?.toDouble(),
      riskLevel: json['risk_level']?.toString(),
    );
  }
}

class SentinelAiService {
  SentinelAiService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Stream<SentinelLiveUpdate> streamLowerEyelidAnalysis({
    required String scanId,
  }) async* {
    final uri = Uri.parse('$baseUrl/v1/sentinel/live-anemia-scan');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'text/event-stream, application/x-ndjson, application/json'
      ..body = jsonEncode({'scan_id': scanId, 'region': 'lower_eyelid'});

    final streamedResponse = await _client.send(request);
    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      throw SentinelAiServiceException(
        'Stream request failed with status ${streamedResponse.statusCode}.',
      );
    }

    await for (final line in streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      String candidate = trimmed;
      if (trimmed.startsWith('data:')) {
        candidate = trimmed.substring(5).trim();
      }

      if (candidate.isEmpty || candidate == '[DONE]') {
        continue;
      }

      final decoded = jsonDecode(candidate);
      if (decoded is! Map<String, dynamic>) {
        continue;
      }

      yield SentinelLiveUpdate.fromJson(decoded);
    }
  }
}

class SentinelAiServiceException implements Exception {
  const SentinelAiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
