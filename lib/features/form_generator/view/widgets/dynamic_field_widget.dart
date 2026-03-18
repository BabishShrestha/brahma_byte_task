import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/features/form_generator/domain/form_schema.dart';

class DynamicField extends StatefulWidget {
  const DynamicField({
    super.key,
    required this.input,
    required this.value,
    required this.error,
    required this.onChanged,
  });

  final FormInputSchema input;
  final dynamic value;
  final String? error;
  final ValueChanged<dynamic> onChanged;

  @override
  State<DynamicField> createState() => _DynamicFieldState();
}

class _DynamicFieldState extends State<DynamicField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(DynamicField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the cubit restores saved values, sync the controller —
    // but only when the field isn't focused to avoid disrupting active typing.
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      final newText = widget.value?.toString() ?? '';
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: newText.length);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.input.type) {
      case InputType.text:
        return TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.input.numberOnly
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: widget.input.numberOnly
              ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(
            labelText: widget.input.label,
            errorText: widget.error,
            border: const OutlineInputBorder(),
          ),
          onChanged: widget.onChanged,
        );

      case InputType.dropdown:
        final String? selected = widget.input.options.contains(widget.value)
            ? widget.value?.toString()
            : null;
        return DropdownButtonFormField<String>(
          value: selected,
          decoration: InputDecoration(
            labelText: widget.input.label,
            errorText: widget.error,
            border: const OutlineInputBorder(),
          ),
          items: widget.input.options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: (v) => widget.onChanged(v),
        );

      case InputType.toggle:
        return InputDecorator(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            errorText: widget.error,
          ),
          child: SwitchListTile.adaptive(
            value: widget.value == true,
            title: Text(widget.input.label),
            contentPadding: EdgeInsets.zero,
            onChanged: (v) => widget.onChanged(v),
          ),
        );
    }
  }
}
