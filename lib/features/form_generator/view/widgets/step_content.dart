import 'package:flutter/material.dart';
import 'package:todo_app/features/form_generator/domain/form_schema.dart';
import 'package:todo_app/features/form_generator/view/widgets/dynamic_field_widget.dart';
import 'package:todo_app/features/form_generator/view/widgets/review_content.dart';

class StepContent extends StatelessWidget {
  const StepContent({
    super.key,
    required this.step,
    required this.allValues,
    required this.fieldErrors,
    required this.onValueChanged,
  });

  final FormStepSchema step;
  final Map<String, dynamic> allValues;
  final Map<String, String> fieldErrors;
  final void Function(String key, dynamic value) onValueChanged;

  @override
  Widget build(BuildContext context) {
    if (step.inputs.isEmpty) {
      return ReviewContent(values: allValues);
    }

    return ListView.separated(
      itemCount: step.inputs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final input = step.inputs[index];
        return DynamicField(
          input: input,
          value: allValues[input.key],
          error: fieldErrors[input.key],
          onChanged: (value) => onValueChanged(input.key, value),
        );
      },
    );
  }
}
