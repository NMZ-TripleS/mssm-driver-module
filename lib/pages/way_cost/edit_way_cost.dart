import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mssm_driver_app/database/helper.dart';
import 'package:mssm_driver_app/database/models/models.dart';

class EditCost extends StatefulWidget {
  final bool edit;
  final Cost cost;

  EditCost(this.edit, {required this.cost, super.key})
      : assert(edit == true || cost.id == 0);

  @override
  State<EditCost> createState() => _EditWayState();
}

class _EditWayState extends State<EditCost> {
  TextEditingController titleEditingController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();
  TextEditingController amountEditingController = TextEditingController();
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
      helpText: 'Select cost date',
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
      selectedDate = DateTime.parse(widget.cost.date);
      titleEditingController.text = widget.cost.title;
      descriptionEditingController.text = widget.cost.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit ? "Edit Person" : "Add cost"),
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  textFormField(titleEditingController, "Title", "Title",
                      Icons.map, widget.edit ? widget.cost.title : "Yangon"),
                  textFormField(
                      descriptionEditingController,
                      "Description",
                      "Description",
                      Icons.place,
                      widget.edit ? widget.cost.description : "Meiktila"),
                  textFormField(amountEditingController, "Amount", "Amount",
                      Icons.place, widget.edit ? widget.cost.description : "0"),
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
                      'Change cost date',
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
                        PersonDatabaseProvider.db.updateCost(Cost(
                            title: titleEditingController.text,
                            description: descriptionEditingController.text,
                            date: DateFormat('y-M-d').format(selectedDate),
                            id: widget.cost.id,
                            costType: CostType.income,
                            wayId: "1",
                            amount: amountEditingController.text));
                        Navigator.pop(context);
                      } else {
                        debugPrint("inserting");
                        await PersonDatabaseProvider.db.insertCost(Cost(
                            title: titleEditingController.text,
                            description: descriptionEditingController.text,
                            date: DateFormat('y-M-d').format(selectedDate),
                            id: widget.cost.id,
                            costType: CostType.income,
                            wayId: "1",
                            amount: amountEditingController.text));
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
