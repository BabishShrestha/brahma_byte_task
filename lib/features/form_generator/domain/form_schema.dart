class FormSchema {
  const FormSchema({required this.title, required this.steps});

  final String title;
  final List<FormStepSchema> steps;

  factory FormSchema.fromMap(Map<String, dynamic> json) {
    final form = json['form'];
    if (form is! Map) {
      throw const FormatException('Missing form object');
    }

    final dynamic stepsRaw = form['steps'];
    if (stepsRaw is! List) {
      throw const FormatException('Form steps must be a list');
    }

    return FormSchema(
      title: form['title']?.toString() ?? 'Dynamic Form',
      steps: stepsRaw
          .map((item) => FormStepSchema.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> defaultValues() {
    final Map<String, dynamic> values = <String, dynamic>{};

    for (final step in steps) {
      for (final input in step.inputs) {
        if (input.defaultValue != null) {
          values[input.key] = input.defaultValue;
          continue;
        }

        if (input.type == InputType.toggle) {
          values[input.key] = false;
        }
      }
    }

    return values;
  }
}

class FormStepSchema {
  const FormStepSchema({
    required this.title,
    required this.description,
    required this.inputs,
  });

  final String title;
  final String description;
  final List<FormInputSchema> inputs;

  factory FormStepSchema.fromMap(Map<String, dynamic> json) {
    final dynamic inputsRaw = json['inputs'];

    return FormStepSchema(
      title: json['title']?.toString() ?? 'Untitled Step',
      description: json['description']?.toString() ?? '',
      inputs: inputsRaw is List
          ? inputsRaw
                .map(
                  (item) => FormInputSchema.fromMap(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const <FormInputSchema>[],
    );
  }
}

enum InputType { text, dropdown, toggle }

class FormInputSchema {
  const FormInputSchema({
    required this.key,
    required this.type,
    required this.label,
    required this.required,
    required this.options,
    required this.numberOnly,
    this.defaultValue,
  });

  final String key;
  final InputType type;
  final String label;
  final bool required;
  final List<String> options;
  final bool numberOnly;
  final dynamic defaultValue;

  factory FormInputSchema.fromMap(Map<String, dynamic> json) {
    final String typeRaw = json['type']?.toString() ?? 'text';
    final InputType type = switch (typeRaw) {
      'dropdown' => InputType.dropdown,
      'toggle' => InputType.toggle,
      _ => InputType.text,
    };

    final dynamic optionsRaw = json['options'];
    final validation = json['validation'];

    return FormInputSchema(
      key: json['key']?.toString() ?? '',
      type: type,
      label: json['label']?.toString() ?? '',
      required: json['required'] == true,
      options: optionsRaw is List
          ? optionsRaw.map((e) => e.toString()).toList()
          : const <String>[],
      numberOnly: validation is Map && validation['numberOnly'] == true,
      defaultValue: json['default'],
    );
  }
}
