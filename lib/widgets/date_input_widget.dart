import 'package:flutter/material.dart';
import '../constants/config.dart' as config;
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class DateInputWidget extends StatelessWidget {
  const DateInputWidget(
      {super.key, required this.name, this.initialValue, this.errorText});

  final String name;
  final DateTime? initialValue;
  final String? errorText;

  @override
  FormBuilderDateTimePicker build(BuildContext context) {
    return FormBuilderDateTimePicker(
        initialValue: initialValue,
        name: name,
        inputType: InputType.date,
        style: const TextStyle(fontSize: 14),
        format: DateFormat(config.dateFormat),
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 5, 0, 5),
            labelStyle: TextStyle(color: Colors.black87),
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
        validator: FormBuilderValidators.required(
            errorText: errorText ?? 'กรอกวันที่'));
  }
}
