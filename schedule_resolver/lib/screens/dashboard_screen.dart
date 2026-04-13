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
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final aiService = Provider.of<AiScheduleService>(context);

    // Sorting tasks by start time
    final sortedTasks = List<TaskModel>.from(scheduleProvider.task);
    sortedTasks.sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Resolver'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Recommendation Alert
            if (aiService.currentAnalysis != null)
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Recommendation Ready!!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecommendationScreen(),
                          ),
                        ),
                        child: const Text('View Recommendation'),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 2. Task List
            Expanded(
              child: sortedTasks.isEmpty
                  ? const Center(child: Text('No tasks added yet'))
                  : ListView.builder(
                itemCount: sortedTasks.length,
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];
                  // Formatted time for cleaner look
                  final startTime = "${task.startTime.hour}:${task.startTime.minute.toString().padLeft(2, '0')}";
                  final endTime = "${task.endTime.hour}:${task.endTime.minute.toString().padLeft(2, '0')}";

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text('${task.category} | $startTime - $endTime'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => scheduleProvider.removeTask(task.id),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. AI Action Button
            // Changed logic to isNotEmpty: usually you analyze a schedule that HAS tasks
            if (sortedTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: aiService.isLoading
                      ? null
                      : () => aiService.analyzeSchedule(scheduleProvider.task),
                  child: aiService.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Resolve Conflicts with Ryl'),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskInputScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
