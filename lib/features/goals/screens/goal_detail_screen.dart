import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import 'camera_screen.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;

  const GoalDetailScreen({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '설명',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(goal.description),
            const SizedBox(height: 16),
            Text(
              '마감일: ${goal.deadline.toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '진행 상황',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            LinearProgressIndicator(value: goal.progress),
            const SizedBox(height: 16),
            Text(
              '서브태스크',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goal.subTasks.length,
              itemBuilder: (context, index) {
                final subTask = goal.subTasks[index];
                return CheckboxListTile(
                  title: Text(subTask.title),
                  value: subTask.isCompleted,
                  onChanged: (value) {
                    if (value != null) {
                      final updatedSubTask = subTask.copyWith(
                        isCompleted: value,
                      );
                      context.read<GoalProvider>().updateSubTask(
                            goal.id,
                            updatedSubTask,
                          );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              '증거 사진',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: goal.evidencePhotoPaths.length + 1,
                itemBuilder: (context, index) {
                  if (index == goal.evidencePhotoPaths.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
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
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(goal.evidencePhotoPaths[index]),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
