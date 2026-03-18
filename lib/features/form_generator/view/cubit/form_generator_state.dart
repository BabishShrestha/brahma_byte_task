import 'package:todo_app/features/form_generator/data/form_local_storage.dart';
import 'package:todo_app/features/form_generator/domain/form_schema.dart';

enum FormGeneratorStatus { initial, loading, ready, failure, submitted }

class FormGeneratorState {
  const FormGeneratorState({
    required this.status,
    this.schema,
    this.currentStep = 0,
    this.values = const <String, dynamic>{},
    this.fieldErrors = const <String, String>{},
    this.errorMessage,
    this.resumeCandidate,
    this.resumePromptVersion = 0,
    this.submitVersion = 0,
  });

  final FormGeneratorStatus status;
  final FormSchema? schema;
  final int currentStep;
  final Map<String, dynamic> values;
  final Map<String, String> fieldErrors;
  final String? errorMessage;
  final FormProgressSnapshot? resumeCandidate;
  final int resumePromptVersion;
  final int submitVersion;

  bool get hasSchema => schema != null;

  bool get isLastStep {
    final schema = this.schema;
    if (schema == null || schema.steps.isEmpty) {
      return true;
    }

    return currentStep >= schema.steps.length - 1;
  }

  FormGeneratorState copyWith({
    FormGeneratorStatus? status,
    FormSchema? schema,
    int? currentStep,
    Map<String, dynamic>? values,
    Map<String, String>? fieldErrors,
    String? errorMessage,
    bool clearErrorMessage = false,
    FormProgressSnapshot? resumeCandidate,
    bool clearResumeCandidate = false,
    int? resumePromptVersion,
    int? submitVersion,
  }) {
    return FormGeneratorState(
      status: status ?? this.status,
      schema: schema ?? this.schema,
      currentStep: currentStep ?? this.currentStep,
      values: values ?? this.values,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      resumeCandidate: clearResumeCandidate
          ? null
          : (resumeCandidate ?? this.resumeCandidate),
      resumePromptVersion: resumePromptVersion ?? this.resumePromptVersion,
      submitVersion: submitVersion ?? this.submitVersion,
    );
  }
}
