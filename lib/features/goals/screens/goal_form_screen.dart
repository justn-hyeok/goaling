import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';

class GoalFormScreen extends StatefulWidget {
  final Goal? goal;

  const GoalFormScreen({super.key, this.goal});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late GoalPriority _selectedPriority;

  final List<String> _categories = ['학습', '취미', '커리어', '재정', '관계', '기타'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.goal?.description ?? '');
    _selectedDate =
        widget.goal?.deadline ?? DateTime.now().add(const Duration(days: 7));
    _selectedCategory = widget.goal?.category ?? _categories.first;
    _selectedPriority = widget.goal?.priority ?? GoalPriority.medium;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? '새로운 목표' : '목표 수정'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '목표',
                    hintText: '달성하고 싶은 목표를 입력하세요',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '목표를 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: '설명',
                    hintText: '목표에 대한 자세한 설명을 입력하세요',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  '카테고리',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _categories.map((category) {
                    return ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  '우선순위',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<GoalPriority>(
                  segments: GoalPriority.values.map((priority) {
                    return ButtonSegment<GoalPriority>(
                      value: priority,
                      label: Text(priority.label),
                    );
                  }).toList(),
                  selected: {_selectedPriority},
                  onSelectionChanged: (Set<GoalPriority> selected) {
                    setState(() {
                      _selectedPriority = selected.first;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  '마감일',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveGoal,
                    child: Text(widget.goal == null ? '목표 추가' : '목표 수정'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      final goal = Goal(
        id: widget.goal?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        deadline: _selectedDate,
        priority: _selectedPriority,
        progress: widget.goal?.progress ?? 0.0,
      );

      if (widget.goal == null) {
        goalProvider.addGoal(goal);
      } else {
        goalProvider.updateGoal(goal);
      }

      Navigator.pop(context);
    }
  }
}
