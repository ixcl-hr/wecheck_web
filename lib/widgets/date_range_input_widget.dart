import 'package:flutter/material.dart';
import '../constants/config.dart' as config;
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

@immutable
class DateRangeInputWidget extends StatelessWidget {
  DateRangeInputWidget(
      {Key? key,
      required this.name,
      this.initial_start,
      this.initial_end,
      this.onChanged,
      this.errorText})
      : super(key: key);

  final String name;
  final String? errorText;
  final DateTime? initial_start;
  final DateTime? initial_end;
  final Function? onChanged;

  DateTime? start;
  DateTime? end;
  @override
  FormBuilderDateRangePicker build(BuildContext context) {
    // FormBuilderDateRangePicker(
    //           name: 'date_range',
    //           firstDate: DateTime(1970),
    //           lastDate: DateTime(2030),
    //           format: DateFormat('yyyy-MM-dd'),
    //           //onChanged: _onChanged,
    //           decoration: InputDecoration(
    //             labelText: 'Date Range',
    //             helperText: 'Helper text',
    //             hintText: 'Hint text',
    //           ),
    //         ),
    start = start ?? DateTime.now().add(const Duration(days: -30));
    end = end ?? DateTime.now().add(const Duration(days: 30));

    return FormBuilderDateRangePicker(
        name: name,
        initialValue: DateTimeRange(
            start: initial_start ??
                start!, //DateTime.now().add(const Duration(days: -30)),
            end: initial_end ??
                end!), // DateTime.now().add(const Duration(days: 30))),
        firstDate: DateTime(1970),
        lastDate: DateTime(2500),
        style: const TextStyle(fontSize: 14),
        format: DateFormat(config.dateFormat),
        textAlign: TextAlign.center,
        saveText: "OK",
        // onSaved: onSaved != null ? onSaved(this) : () => {},
        onChanged: (value) {
          start = value!.start;
          end = value.end;
          if (onChanged != null) onChanged;
        },
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
