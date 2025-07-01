import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../../../core/services/notification_service.dart';

class GoalProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  List<Goal> _goals = [];

  GoalProvider(this._notificationService);

  List<Goal> get goals => List.unmodifiable(_goals);

  void addGoal(Goal goal) {
    _goals.add(goal);
    _notificationService.scheduleGoalReminder(
      goalId: goal.id,
      title: goal.title,
      description: goal.description,
      deadline: goal.deadline,
    );
    notifyListeners();
  }

  void updateGoal(Goal goal) {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      _notificationService.cancelGoalReminders(goal.id);
      _notificationService.scheduleGoalReminder(
        goalId: goal.id,
        title: goal.title,
        description: goal.description,
        deadline: goal.deadline,
      );
      notifyListeners();
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((goal) => goal.id == id);
    _notificationService.cancelGoalReminders(id);
    notifyListeners();
  }

  void updateSubTask(String goalId, SubTask subTask) {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final subTaskIndex =
          goal.subTasks.indexWhere((st) => st.id == subTask.id);

      if (subTaskIndex != -1) {
        final updatedSubTasks = List<SubTask>.from(goal.subTasks);
        updatedSubTasks[subTaskIndex] = subTask;

        final updatedGoal = goal.copyWith(
          subTasks: updatedSubTasks,
          progress: _calculateProgress(updatedSubTasks),
        );

        _goals[goalIndex] = updatedGoal;

        if (updatedGoal.progress >= 1.0) {
          _notificationService.showGoalCompletionNotification(
            title: updatedGoal.title,
          );
        }

        notifyListeners();
      }
    }
  }

  double _calculateProgress(List<SubTask> subTasks) {
    if (subTasks.isEmpty) return 0.0;
    final completedTasks = subTasks.where((task) => task.isCompleted).length;
    return completedTasks / subTasks.length;
  }

  void addEvidencePhoto(String goalId, String photoPath) {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final updatedPhotoPaths = List<String>.from(goal.evidencePhotoPaths)
        ..add(photoPath);
      _goals[goalIndex] = goal.copyWith(evidencePhotoPaths: updatedPhotoPaths);
      notifyListeners();
    }
  }

  void addDocument(String goalId, String documentPath) {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final updatedDocPaths = List<String>.from(goal.documentPaths)
        ..add(documentPath);
      _goals[goalIndex] = goal.copyWith(documentPaths: updatedDocPaths);
      notifyListeners();
    }
  }
}
