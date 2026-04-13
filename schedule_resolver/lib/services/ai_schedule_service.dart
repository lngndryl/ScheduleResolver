import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isloading = false;
  String? _errorMessage;

  final String _apiKey = '';

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isloading;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeSchedule(List<TaskModel> task) async {
    if (_apiKey.isEmpty || task.isEmpty) return;
    _isloading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // FIX 1: Changed to a valid model version
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final tasksJson = jsonEncode(task.map((t) => t.toJson()).toList());

      final prompt = '''
    You are an expert student scheduling assistant. The user has provided the following tasks for their day in JSON format:
    
    $tasksJson
    
    Please provide exactly 4 sections of markdown text using these EXACT headers:
    ### Detected Conflicts
    ### Ranked Tasks
    ### Recommended Schedule
    ### Explanation
    ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        _currentAnalysis = _parseResponse(response.text!);
      }
    } catch (e) {
      // FIX 2: Removed backslash from error reporting
      _errorMessage = 'Failed: $e';
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fullText) {
    String conflicts = "",
        rankedTasks = "",
        recommendedSchedule = "",
        explanation = "";

    // Splitting by '###' to match the prompt
    final sections = fullText.split('###');

    for (var section in sections) {
      final trimmed = section.trim();
      if (trimmed.startsWith('Detected Conflicts')) {
        conflicts = trimmed.replaceFirst('Detected Conflicts', '').trim();
      } else if (trimmed.startsWith('Ranked Tasks')) {
        rankedTasks = trimmed.replaceFirst('Ranked Tasks', '').trim();
      } else if (trimmed.startsWith('Recommended Schedule')) {
        recommendedSchedule = trimmed.replaceFirst('Recommended Schedule', '').trim();
      } else if (trimmed.startsWith('Explanation')) {
        explanation = trimmed.replaceFirst('Explanation', '').trim();
      }
    }

    return ScheduleAnalysis(
      conflicts: conflicts,
      rankedTasks: rankedTasks,
      recommendedSchedule: recommendedSchedule,
      explanation: explanation,
    );
  }
}
