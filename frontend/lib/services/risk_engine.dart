class RiskEngine {
  static Map<String, String> calculateRisk({
    required int bp,
    required List<String> symptoms,
    required bool fever,
  }) {
    if (bp > 140 && (symptoms.contains('headache') || symptoms.contains('swelling'))) {
      return {
        'risk_level': 'HIGH',
        'possible_condition': 'Pre-eclampsia risk',
      };
    }
    if (symptoms.contains('fatigue') || symptoms.contains('dizziness')) {
      return {
        'risk_level': 'MEDIUM',
        'possible_condition': 'Possible anemia',
      };
    }
    if (fever) {
      return {
        'risk_level': 'MEDIUM',
        'possible_condition': 'Possible infection',
      };
    }
    return {
      'risk_level': 'LOW',
      'possible_condition': 'None',
    };
  }
}
