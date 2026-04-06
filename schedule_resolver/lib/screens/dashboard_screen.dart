import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/ai_schedule_service.dart';
import '../models/task_model.dart';
import 'task_input_screen.dart';
import 'recommendation_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final aiservice = Provider.of<AiScheduleService>(context);

    final sortedTasks = List<TaskModel>.from(scheduleProvider.task);
    sortedTasks.sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));


    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Resolver'), centerTitle: true),
    );
  }
}

