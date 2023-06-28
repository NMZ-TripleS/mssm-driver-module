import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mssm_driver_app/database/helper.dart';
import 'package:mssm_driver_app/database/models/way.dart';

class EditWay extends StatefulWidget {
  final bool edit;
  final Way way;

  EditWay(this.edit, {required this.way, super.key})
      : assert(edit == true || way.id == 0);

  @override
  State<EditWay> createState() => _EditWayState();
}

class _EditWayState extends State<EditWay> {
  TextEditingController fromEditingController = TextEditingController();
  TextEditingController toEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(const Duration(days: 10))) &&
        day.isBefore(DateTime.now().add(const Duration(days: 1))))) {
      return true;
    }
    return false;
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      helpText: 'Select way date',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      selectableDayPredicate: _decideWhichDayToEnable,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.edit == true) {
      selectedDate = DateTime.parse(widget.way.date);
      fromEditingController.text = widget.way.from;
      toEditingController.text = widget.way.to;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit ? "Edit Person" : "Add way"),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  textFormField(fromEditingController, "From", "From City",
                      Icons.map, widget.edit ? widget.way.from : "Yangon"),
                  textFormField(toEditingController, "To", "To Cityy",
                      Icons.place, widget.edit ? widget.way.to : "Meiktila"),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context), // Refer step 3
                    child: const Text(
                      'Change way date',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    child: const Text(
                      "Save",
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')));
                      } else if (widget.edit == true) {
                        debugPrint("updagint");
                        PersonDatabaseProvider.db.updateWay(Way(
                            from: fromEditingController.text,
                            to: toEditingController.text,
                            date: DateFormat('y-M-d').format(selectedDate),
                            id: widget.way.id));
                        Navigator.pop(context);
                      } else {
                        debugPrint("inserting");
                        await PersonDatabaseProvider.db.insertWay(Way(
                            from: fromEditingController.text,
                            to: toEditingController.text,
                            date: DateFormat('y-M-d').format(selectedDate)));
                        if (!mounted) return;
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            ),
          )),
    );
  }

  textFormField(TextEditingController t, String label, String hint,
      IconData iconData, String initialValue) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        controller: t,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            prefixIcon: Icon(iconData),
            hintText: hint,
            labelText: label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}
