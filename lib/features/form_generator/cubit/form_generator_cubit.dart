import 'package:bloc/bloc.dart';
import 'package:todo_app/features/form_generator/data/form_local_storage.dart';
import 'package:todo_app/features/form_generator/domain/dummy_json.dart';
import 'package:todo_app/features/form_generator/domain/form_schema.dart';
import 'package:todo_app/features/form_generator/cubit/form_generator_state.dart';

class FormGeneratorCubit extends Cubit<FormGeneratorState> {
  FormGeneratorCubit(this._localStorage)
    : super(const FormGeneratorState(status: FormGeneratorStatus.initial));

  final FormLocalStorage _localStorage;

  Future<void> initialize() async {
    emit(state.copyWith(status: FormGeneratorStatus.loading, clearErrorMessage: true));

    try {
      final schema = FormSchema.fromMap(formJson);
      final defaults = schema.defaultValues();
      final snapshot = await _localStorage.readProgress();

      if (snapshot != null && snapshot.hasProgress) {
        emit(
          state.copyWith(
            status: FormGeneratorStatus.ready,
            schema: schema,
            values: defaults,
            currentStep: 0,
            resumeCandidate: snapshot,
            resumePromptVersion: state.resumePromptVersion + 1,
            fieldErrors: const <String, String>{},
            clearErrorMessage: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: FormGeneratorStatus.ready,
          schema: schema,
          values: defaults,
          currentStep: 0,
          fieldErrors: const <String, String>{},
          clearErrorMessage: true,
          clearResumeCandidate: true,
        ),
      );
      await _persist();
    } catch (e) {
      emit(
        state.copyWith(
          status: FormGeneratorStatus.failure,
          errorMessage: 'Failed to initialize form: $e',
        ),
      );
    }
  }

  Future<void> checkResumePromptOnAppResume() async {
    if (state.schema == null) {
      return;
    }

    if (state.values.isNotEmpty || state.currentStep > 0) {
      return;
    }

    final snapshot = await _localStorage.readProgress();
    if (snapshot == null || !snapshot.hasProgress) {
      return;
    }

    emit(
      state.copyWith(
        resumeCandidate: snapshot,
        resumePromptVersion: state.resumePromptVersion + 1,
      ),
    );
  }

  Future<void> continueFromSavedProgress() async {
    final snapshot = state.resumeCandidate;
    final schema = state.schema;
    if (snapshot == null || schema == null) {
      return;
    }

    final clampedStep = snapshot.stepIndex.clamp(0, schema.steps.length - 1);
    final mergedValues = <String, dynamic>{
      ...schema.defaultValues(),
      ...snapshot.values,
    };

    emit(
      state.copyWith(
        currentStep: clampedStep,
        values: mergedValues,
        fieldErrors: const <String, String>{},
        clearResumeCandidate: true,
      ),
    );
    await _persist();
  }

  Future<void> discardSavedProgress() async {
    final schema = state.schema;
    if (schema == null) {
      return;
    }

    await _localStorage.clearProgress();
    emit(
      state.copyWith(
        currentStep: 0,
        values: schema.defaultValues(),
        fieldErrors: const <String, String>{},
        clearResumeCandidate: true,
      ),
    );
    await _persist();
  }

  Future<void> updateValue(String key, dynamic value) async {
    final updated = <String, dynamic>{...state.values, key: value};
    final updatedErrors = <String, String>{...state.fieldErrors}..remove(key);

    emit(state.copyWith(values: updated, fieldErrors: updatedErrors));
    await _persist();
  }

  Future<void> nextStep() async {
    final schema = state.schema;
    if (schema == null) {
      return;
    }

    final errors = _validateStep(schema.steps[state.currentStep]);
    if (errors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: errors));
      return;
    }

    if (state.currentStep >= schema.steps.length - 1) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: state.currentStep + 1,
        fieldErrors: const <String, String>{},
      ),
    );
    await _persist();
  }

  Future<void> previousStep() async {
    if (state.currentStep == 0) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: state.currentStep - 1,
        fieldErrors: const <String, String>{},
      ),
    );
    await _persist();
  }

  Future<void> submit() async {
    final schema = state.schema;
    if (schema == null) {
      return;
    }

    final allErrors = <String, String>{};
    for (final step in schema.steps) {
      allErrors.addAll(_validateStep(step));
    }

    if (allErrors.isNotEmpty) {
      emit(state.copyWith(fieldErrors: allErrors));
      return;
    }

    await _localStorage.clearProgress();
    emit(
      state.copyWith(
        status: FormGeneratorStatus.submitted,
        submitVersion: state.submitVersion + 1,
        fieldErrors: const <String, String>{},
      ),
    );

    emit(state.copyWith(status: FormGeneratorStatus.ready));
  }

  Map<String, String> _validateStep(FormStepSchema step) {
    final errors = <String, String>{};

    for (final input in step.inputs) {
      final value = state.values[input.key];

      if (input.required) {
        final isEmptyString = value is String && value.trim().isEmpty;
        if (value == null || isEmptyString) {
          errors[input.key] = '${input.label} is required';
          continue;
        }
      }

      if (input.numberOnly && value != null && value.toString().trim().isNotEmpty) {
        final isNumber = num.tryParse(value.toString()) != null;
        if (!isNumber) {
          errors[input.key] = '${input.label} must be numeric';
        }
      }
    }

    return errors;
  }

  Future<void> _persist() async {
    await _localStorage.saveProgress(
      stepIndex: state.currentStep,
      values: state.values,
    );
  }
}
