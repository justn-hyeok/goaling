import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import 'goal_form_screen.dart';
import 'goal_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 목표'),
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          final goals = provider.goals;
          final now = DateTime.now();

          // 목표 상태별 카운트 계산
          int inProgress = 0;
          int completed = 0;
          int delayed = 0;

          for (final goal in goals) {
            if (goal.progress >= 1.0) {
              completed++;
            } else if (goal.deadline.isBefore(now)) {
              delayed++;
            } else {
              inProgress++;
            }
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: '진행 중',
                        value: inProgress.toString(),
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: '완료',
                        value: completed.toString(),
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: '지연',
                        value: delayed.toString(),
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const _GoalList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GoalFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalList extends StatelessWidget {
  const _GoalList();

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final goals = provider.goals;
        final now = DateTime.now();

        if (goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '아직 목표가 없습니다',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '새로운 목표를 추가해보세요!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          );
        }

        // 목표 정렬
        final sortedGoals = goals.toList()
          ..sort((a, b) {
            // 먼저 상태별로 정렬 (진행 중 > 지연 > 완료)
            final aCompleted = a.progress >= 1.0;
            final bCompleted = b.progress >= 1.0;
            final aDelayed = !aCompleted && a.deadline.isBefore(now);
            final bDelayed = !bCompleted && b.deadline.isBefore(now);

            if (aCompleted != bCompleted) {
              return aCompleted ? 1 : -1; // 완료된 목표는 뒤로
            }

            if (aDelayed != bDelayed) {
              return aDelayed ? -1 : 1; // 지연된 목표는 진행 중인 목표 다음으로
            }

            // 같은 상태 내에서 정렬
            if (aCompleted) {
              // 완료된 목표는 최근에 완료된 순
              return b.priority.index.compareTo(a.priority.index);
            } else if (aDelayed) {
              // 지연된 목표는 최근에 지연된 순
              return a.deadline.compareTo(b.deadline);
            } else {
              // 진행 중인 목표는 마감일이 가까운 순
              return a.deadline.compareTo(b.deadline);
            }
          });

        return ListView.separated(
          itemCount: sortedGoals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final goal = sortedGoals[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0 ||
                    _getGoalStatus(sortedGoals[index - 1], now) !=
                        _getGoalStatus(goal, now)) ...[
                  if (index != 0) const SizedBox(height: 16),
                  Text(
                    _getStatusHeader(goal, now),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
                _GoalCard(goal: goal),
              ],
            );
          },
        );
      },
    );
  }

  String _getStatusHeader(Goal goal, DateTime now) {
    if (goal.progress >= 1.0) {
      return '완료된 목표';
    } else if (goal.deadline.isBefore(now)) {
      return '지연된 목표';
    } else {
      return '진행 중인 목표';
    }
  }

  String _getGoalStatus(Goal goal, DateTime now) {
    if (goal.progress >= 1.0) {
      return 'completed';
    } else if (goal.deadline.isBefore(now)) {
      return 'delayed';
    } else {
      return 'in_progress';
    }
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalDetailScreen(goal: goal),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    goal.category,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(goal.deadline),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getDeadlineColor(goal.deadline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                goal.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (goal.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  goal.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.progress == 1.0 ? Colors.green : Colors.indigo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }

  Color _getDeadlineColor(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;

    if (deadline.isBefore(now)) {
      return Colors.red; // 지연
    } else if (difference <= 7) {
      return Colors.orange; // 임박
    }
    return Colors.grey[600]!; // 일반
  }
}
