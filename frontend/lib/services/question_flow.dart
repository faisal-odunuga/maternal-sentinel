class QuestionFlow {
  static List<String> getFollowUpQuestions(List<String> symptoms) {
    final questions = <String>[];
    if (symptoms.contains('headache')) {
      questions.add('Is there blurred vision?');
      questions.add('Is there swelling in face or hands?');
    }
    if (symptoms.contains('fatigue')) {
      questions.add('Is there dizziness?');
    }
    if (symptoms.contains('fever')) {
      questions.add('Is there chills or sweating?');
    }
    // Add more as needed, limit to 7
    return questions.take(7).toList();
  }
}
