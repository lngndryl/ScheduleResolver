import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/schedule_analysis.dart';
import '../models/task_model.dart';



class AiScheduleService extends ChangeNotifier {

  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;


  final String _apikey = '';


  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeSchedule(List<TaskModel> task) async {
    if (_apikey.isEmpty || task.isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();


    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apikey);
      final tasksJson = jsonEncode(task.map((t) => t.toJson()).toList());

      final prompt = '''
      
      You are an Expert Student scheduling assistant. The user has provided the following tasks for their day in JSON format:
      
      $tasksJson
      
      Your job is to analyze these tasks, identify any overlaps or conflicts in their start and end times, and suggest a better balanced schedule.
      Consider their urgency, importance and required energy level.

      Please provide exactly 4 sections of markdown text:
      1. ### Detected Conflicts
      List any scheduling conflicts or state that there are none.
      2. ### Ranked Tasks
      Rank which task need attention first based on urgency, importance and energy, provide a brief reason for each.
      3. ### recommended Schedule
      Provide a revised daily timeline view adjusting the task times to resolve
      4. ### Explanation
      Explain why this recommendation was made in simple language that a student would easily understand.

      Ensure the markdown is well-formatted and easy to read. Do not include extra text outside of these headers.

      conflicts and balance the student's workload, study time, and rest.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      _currentAnalysis = _parseResponse(response.text ?? '');
    } catch (e) {

      _errorMessage = 'Failed: \$e';
    } finally {

      _isLoading = false;
      notifyListeners();
    }

  }

  ScheduleAnalysis _parseResponse(String fullText) {
    String conflicts = "", rankedTasks = "", recommendedSchedule = "", explanation = "";

    final sections = fullText.split('### ');
    for (var section in sections) {
      if (section.startsWith('Detect Conflicts')) conflicts = section.replaceFirst('Detected Conflicts', '').trim();
      else if (section.startsWith('Ranked Tasks')) rankedTasks = section.replaceFirst('Ranked Tasks', '').trim();
      else if (section.startsWith('Recommended Schedule')) recommendedSchedule = section.replaceFirst('Recommended Schedule', '').trim();
      else if (section.startsWith('Explanation')) explanation = section.replaceFirst('Explanation', '').trim();
    }

    return ScheduleAnalysis(
        conflicts: conflicts,
        rankedTasks: rankedTasks,
        recommendedSchedule: recommendedSchedule,
        explanation: explanation,
    );
  }


}