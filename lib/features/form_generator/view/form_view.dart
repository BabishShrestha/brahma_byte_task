import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/features/form_generator/view/cubit/form_generator_cubit.dart';
import 'package:todo_app/features/form_generator/view/cubit/form_generator_state.dart';
import 'package:todo_app/features/form_generator/data/form_local_storage.dart';
import 'package:todo_app/features/form_generator/view/widgets/step_content.dart';

class FormView extends StatefulWidget {
  const FormView({super.key});

  @override
  State<FormView> createState() => _FormViewState();
}

class _FormViewState extends State<FormView> with WidgetsBindingObserver {
  late final FormGeneratorCubit _cubit;
  int _lastResumePromptVersion = 0;
  int _lastSubmitVersion = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit = FormGeneratorCubit(FormLocalStorage());
    _cubit.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.checkResumePromptOnAppResume();
    }
  }

  Future<void> _showResumeDialog(FormProgressSnapshot snapshot) async {
    final String when = snapshot.savedAt == null
        ? 'unknown time'
        : DateFormat('yyyy-MM-dd HH:mm').format(snapshot.savedAt!.toLocal());

    final bool? continueSaved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resume Previous Form?'),
          content: Text(
            'Found saved progress from $when. Continue where you left off?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Start Fresh'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (continueSaved == true) {
      await _cubit.continueFromSavedProgress();
      return;
    }

    await _cubit.discardSavedProgress();
  }

  Future<void> _showSubmitResult(Map<String, dynamic> values) async {
    final pretty = const JsonEncoder.withIndent('  ').convert(values);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Form Submitted'),
          content: SingleChildScrollView(child: SelectableText(pretty)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<FormGeneratorCubit, FormGeneratorState>(
        listener: (context, state) async {
          if (state.resumeCandidate != null &&
              state.resumePromptVersion != _lastResumePromptVersion) {
            _lastResumePromptVersion = state.resumePromptVersion;
            await _showResumeDialog(state.resumeCandidate!);
          }

          if (state.submitVersion != _lastSubmitVersion) {
            _lastSubmitVersion = state.submitVersion;
            await _showSubmitResult(state.values);
          }
        },
        builder: (context, state) {
          if (state.status == FormGeneratorStatus.loading ||
              state.status == FormGeneratorStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == FormGeneratorStatus.failure || !state.hasSchema) {
            return Scaffold(
              appBar: AppBar(title: const Text('Dynamic Form Generator')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage ?? 'Unable to load form'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<FormGeneratorCubit>().initialize(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final schema = state.schema!;
          final currentStep = schema.steps[state.currentStep];

          return Scaffold(
            appBar: AppBar(title: Text(schema.title)),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (state.currentStep + 1) / schema.steps.length,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Step ${state.currentStep + 1} of ${schema.steps.length}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStep.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(currentStep.description),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StepContent(
                      step: currentStep,
                      allValues: state.values,
                      fieldErrors: state.fieldErrors,
                      onValueChanged: (key, value) {
                        context.read<FormGeneratorCubit>().updateValue(
                          key,
                          value,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (state.currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context
                                .read<FormGeneratorCubit>()
                                .previousStep(),
                            child: const Text('Back'),
                          ),
                        ),
                      if (state.currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (state.isLastStep) {
                              context.read<FormGeneratorCubit>().submit();
                              return;
                            }

                            context.read<FormGeneratorCubit>().nextStep();
                          },
                          child: Text(state.isLastStep ? 'Submit' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
