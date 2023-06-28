import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mssm_driver_app/database/helper.dart';
import 'package:mssm_driver_app/database/models/models.dart';
import 'package:mssm_driver_app/pages/way_cost/income_outcome.dart';

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
  bool inOrOut = true;
  String wayId = "0";
  final Future<List<Way>> _ways = PersonDatabaseProvider.db.ways();
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
      selectedDate = DateFormat("y-M-d").parse(widget.cost.date);
      titleEditingController.text = widget.cost.title;
      amountEditingController.text = widget.cost.amount;
      wayId = widget.cost.wayId;
      inOrOut = widget.cost.costType == CostType.income;
      descriptionEditingController.text = widget.cost.description;
    } else {
      _ways.then(
          (value) => {if (value.isNotEmpty) wayId = value.first.id.toString()});
    }
  }

  void onChanged(String? dropDownValue) {
    if (dropDownValue == null) return;
    String id = dropDownValue.split("-")[0];
    setState(() {
      wayId = id;
    });
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
                  FutureBuilder<List<Way>>(
                    future: _ways,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Way>> snapshot) {
                      if (snapshot.hasData) {
                        List<Way> ways = snapshot.data!;
                        if (ways.isEmpty) return const SizedBox();
                        List<String> wayStrings = ways
                            .map((way) => "${way.id}- ${way.from} => ${way.to}")
                            .toList();
                        return DropdownButtonExample(
                          list: wayStrings,
                          onChanged: onChanged,
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IOBaseWidget(
                          title: "IN",
                          selected: inOrOut,
                          onClick: () => setState(() => inOrOut = !inOrOut)),
                      IOBaseWidget(
                          title: "OUT",
                          selected: !inOrOut,
                          onClick: () => setState(() => inOrOut = !inOrOut))
                    ],
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
                            costType:
                                inOrOut ? CostType.income : CostType.outcome,
                            wayId: wayId,
                            amount: amountEditingController.text));
                        Navigator.pop(context);
                      } else {
                        debugPrint("inserting");
                        await PersonDatabaseProvider.db.insertCost(Cost(
                            title: titleEditingController.text,
                            description: descriptionEditingController.text,
                            date: DateFormat('y-M-d').format(selectedDate),
                            costType:
                                inOrOut ? CostType.income : CostType.outcome,
                            wayId: wayId,
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

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample(
      {super.key, required this.list, required this.onChanged});
  final List<String> list;
  final void Function(String?)? onChanged;
  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  @override
  Widget build(BuildContext context) {
    String dropdownValue = widget.list.first;
    return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: DropdownButton(
              value: dropdownValue,
              items: widget.list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: widget.onChanged,
              isExpanded: true, //make true to take width of parent widget
              underline: Container(), //empty line
              style: const TextStyle(
                  fontSize: 18, color: Colors.black), //Icon color
            )));
  }
}
