import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import 'camera_screen.dart';
import 'goal_form_screen.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoalFormScreen(goal: goal),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusSection(context),
          const SizedBox(height: 24),
          _buildProgressSection(context),
          const SizedBox(height: 24),
          _buildDescriptionSection(context),
          const SizedBox(height: 24),
          _buildSubTasksSection(context),
          const SizedBox(height: 24),
          _buildEvidenceSection(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraScreen(
                onImageCaptured: (imagePath) {
                  context.read<GoalProvider>().addEvidencePhoto(
                        goal.id,
                        imagePath,
                      );
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isCompleted = goal.progress >= 1.0;
    final isDelayed = !isCompleted && goal.deadline.isBefore(now);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : isDelayed
                          ? Icons.warning
                          : Icons.pending,
                  color: isCompleted
                      ? Colors.green
                      : isDelayed
                          ? Colors.red
                          : Colors.indigo,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isCompleted
                      ? '완료된 목표'
                      : isDelayed
                          ? '지연된 목표'
                          : '진행 중인 목표',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isCompleted
                        ? Colors.green
                        : isDelayed
                            ? Colors.red
                            : Colors.indigo,
                  ),
                ),
              ],
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<GoalProvider>().updateGoal(
                          goal.copyWith(progress: 1.0),
                        );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('목표 완료하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '진행률',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            _getPriorityColor(goal.priority).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        goal.priority.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getPriorityColor(goal.priority),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${(goal.progress * 100).toInt()}%',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: goal.progress == 1.0 ? Colors.green : Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.progress == 1.0 ? Colors.green : Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '마감일: ${_formatDate(goal.deadline)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getDeadlineColor(goal.deadline),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '설명',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              goal.description,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTasksSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '세부 작업',
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // TODO: Add subtask
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('추가'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: goal.subTasks.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final subTask = goal.subTasks[index];
              return ListTile(
                leading: Icon(
                  subTask.isCompleted
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: subTask.isCompleted ? Colors.green : Colors.grey[400],
                ),
                title: Text(
                  subTask.title,
                  style: TextStyle(
                    decoration:
                        subTask.isCompleted ? TextDecoration.lineThrough : null,
                    color: subTask.isCompleted
                        ? Colors.grey[600]
                        : Colors.grey[800],
                  ),
                ),
                onTap: () {
                  // TODO: Toggle subtask completion
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '달성 증거',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (goal.evidencePhotoPaths.isEmpty)
          Card(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '아직 등록된 증거가 없습니다',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '목표 달성을 증명할 사진을 추가해보세요',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: goal.evidencePhotoPaths.length,
            itemBuilder: (context, index) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    _showFullScreenImage(
                      context,
                      goal.evidencePhotoPaths[index],
                    );
                  },
                  child: Hero(
                    tag: 'evidence_${goal.evidencePhotoPaths[index]}',
                    child: Image.file(
                      File(goal.evidencePhotoPaths[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Container(
            color: Colors.black,
            child: Center(
              child: Hero(
                tag: 'evidence_$imagePath',
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  Color _getDeadlineColor(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (deadline.isBefore(now)) {
      return Colors.red; // 지연
    } else if (difference <= 7) {
      return Colors.orange; // 임박
    }
    return Colors.grey[800]!; // 일반
  }

  Color _getPriorityColor(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.high:
        return Colors.red;
      case GoalPriority.medium:
        return Colors.orange;
      case GoalPriority.low:
        return Colors.blue;
    }
  }
}
