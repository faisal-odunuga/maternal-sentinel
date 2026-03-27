import 'dart:convert';

class MaternalRiskAssessor {
  static Map<String, dynamic> assess({
    required List<String> symptoms,
    int? bp,
    int? hr,
    int? pregnancyWeeks,
  }) {
    List<String> possibleConditions = [];
    List<String> followUp = [];
    String riskLevel = 'LOW';
    String recommendation = 'No immediate risk detected.';
    String status = 'assessed';

    // Check for missing data
    if (bp == null || hr == null || pregnancyWeeks == null || symptoms.isEmpty) {
      status = 'needs_more_data';
      if (bp == null) followUp.add('What is the patient\'s blood pressure?');
      if (hr == null) followUp.add('What is the patient\'s heart rate?');
      if (pregnancyWeeks == null) followUp.add('How many weeks pregnant is the patient?');
      if (symptoms.isEmpty) followUp.add('What symptoms is the patient experiencing?');
      return {
        'status': status,
        'follow_up_questions': followUp,
        'possible_conditions': [],
        'risk_level': 'MEDIUM',
        'recommendation': 'Collect more symptoms before final assessment',
      };
    }

    // Pre-eclampsia
    if (bp > 140) {
      possibleConditions.add('Pre-eclampsia');
      followUp.add('Is the patient experiencing blurred vision?');
      followUp.add('Is there swelling in the hands or face?');
      riskLevel = 'MEDIUM';
      recommendation = 'Monitor closely and refer to clinic if symptoms worsen.';
    }

    // Anemia
    if (symptoms.any((s) => s.toLowerCase().contains('fatigue') || s.toLowerCase().contains('dizzy'))) {
      possibleConditions.add('Anemia');
      followUp.add('Is the patient pale or short of breath?');
      riskLevel = 'MEDIUM';
      recommendation = 'Consider hemoglobin check and iron supplements.';
    }

    // Infection
    if (symptoms.any((s) => s.toLowerCase().contains('fever'))) {
      possibleConditions.add('Infection');
      followUp.add('Is there pain or burning during urination?');
      followUp.add('Is there foul-smelling vaginal discharge?');
      riskLevel = 'HIGH';
      recommendation = 'Refer to clinic for infection assessment.';
    }

    // Dehydration
    if (symptoms.any((s) => s.toLowerCase().contains('thirst') || s.toLowerCase().contains('dry mouth'))) {
      possibleConditions.add('Dehydration');
      followUp.add('Is the patient able to keep fluids down?');
      riskLevel = 'MEDIUM';
      recommendation = 'Encourage oral fluids and monitor.';
    }

    // Escalate if multiple risks
    if (possibleConditions.length > 1 || riskLevel == 'HIGH') {
      riskLevel = 'HIGH';
      recommendation = 'Refer to clinic or hospital for urgent review.';
    }

    // If no risks detected
    if (possibleConditions.isEmpty) {
      riskLevel = 'LOW';
      recommendation = 'Continue routine monitoring.';
    }

    return {
      'status': status,
      'follow_up_questions': followUp,
      'possible_conditions': possibleConditions,
      'risk_level': riskLevel,
      'recommendation': recommendation,
    };
  }
}

class DynamicQuestionnaireEngine {
  final List<String> _generalQuestions = [
    'Does the patient have a headache?',
    'Is the patient experiencing fever?',
    'Is there swelling in the hands or feet?',
    'Is the patient feeling dizzy or weak?',
    'Is there any vaginal bleeding?',
  ];
  final List<String> _asked = [];
  final List<String> _toAsk = [];
  final List<String> _followUps = [];
  int _maxQuestions = 6;
  int _count = 0;

  DynamicQuestionnaireEngine({List<String>? initialSymptoms}) {
    _toAsk.addAll(_generalQuestions);
    if (initialSymptoms != null) {
      for (final s in initialSymptoms) {
        if (s.toLowerCase().contains('fever')) {
          _followUps.add('Has the fever lasted more than 2 days?');
        }
        if (s.toLowerCase().contains('headache')) {
          _followUps.add('Is the headache severe or sudden?');
        }
        if (s.toLowerCase().contains('swelling')) {
          _followUps.add('Is the swelling getting worse?');
        }
      }
    }
  }

  List<String> nextQuestions(Map<String, String> previousAnswers) {
    // Adapt based on previous answers
    for (final entry in previousAnswers.entries) {
      if (!_asked.contains(entry.key)) _asked.add(entry.key);
      if (entry.value.toLowerCase() == 'yes') {
        if (entry.key.contains('headache')) {
          _followUps.add('Is the headache severe or sudden?');
        }
        if (entry.key.contains('fever')) {
          _followUps.add('Has the fever lasted more than 2 days?');
        }
        if (entry.key.contains('swelling')) {
          _followUps.add('Is the swelling getting worse?');
        }
        if (entry.key.contains('dizzy')) {
          _followUps.add('Is the patient pale or short of breath?');
        }
      }
    }
    // Remove already asked
    _toAsk.removeWhere((q) => _asked.contains(q));
    // Compose next batch
    List<String> next = [];
    while (next.length < 2 && _toAsk.isNotEmpty && _count < _maxQuestions) {
      next.add(_toAsk.removeAt(0));
      _count++;
    }
    while (next.length < 4 && _followUps.isNotEmpty && _count < _maxQuestions) {
      next.add(_followUps.removeAt(0));
      _count++;
    }
    return next;
  }
}