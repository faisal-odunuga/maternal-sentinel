import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/risk_engine.dart';
import '../services/question_flow.dart';
import '../services/sync_service.dart';

class AddVisitScreen extends StatefulWidget {
  static const String routeName = '/add-visit';
  final int patientId;
  const AddVisitScreen({required this.patientId, super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  int bp = 120;
  int heartRate = 80;
  List<String> symptoms = [];
  bool fever = false;
  Map<String, String>? riskResult;
  List<String> followUpQuestions = [];

  final _formKey = GlobalKey<FormState>();
  final _symptomController = TextEditingController();

  void calculateRisk() {
    riskResult = RiskEngine.calculateRisk(bp: bp, symptoms: symptoms, fever: fever);
    followUpQuestions = QuestionFlow.getFollowUpQuestions(symptoms);
    setState(() {});
  }

  Future<void> saveVisit() async {
    await DatabaseService.insertVisit({
      'patient_id': widget.patientId,
      'bp': bp,
      'heart_rate': heartRate,
      'symptoms': symptoms.join(','),
      'risk_level': riskResult?['risk_level'] ?? '',
      'possible_condition': riskResult?['possible_condition'] ?? '',
      'synced': 0,
    });
    await SyncService.syncVisits(); // Try to sync if online
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Visit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Blood Pressure (BP)'),
                initialValue: bp.toString(),
                keyboardType: TextInputType.number,
                onChanged: (v) => bp = int.tryParse(v) ?? 120,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Heart Rate'),
                initialValue: heartRate.toString(),
                keyboardType: TextInputType.number,
                onChanged: (v) => heartRate = int.tryParse(v) ?? 80,
              ),
              TextFormField(
                controller: _symptomController,
                decoration: const InputDecoration(labelText: 'Symptoms (comma separated)'),
                onChanged: (v) {
                  symptoms = v.split(',').map((s) => s.trim().toLowerCase()).where((s) => s.isNotEmpty).toList();
                },
              ),
              SwitchListTile(
                title: const Text('Fever'),
                value: fever,
                onChanged: (v) => setState(() => fever = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: calculateRisk,
                child: const Text('Calculate Risk'),
              ),
              if (riskResult != null) ...[
                const SizedBox(height: 16),
                Text('Risk: ${riskResult!['risk_level']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Condition: ${riskResult!['possible_condition']}'),
                ...followUpQuestions.map((q) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(q),
                )),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: saveVisit,
                  child: const Text('Save Visit'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
