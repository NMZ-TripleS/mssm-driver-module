import 'package:flutter/material.dart';

class IOBaseWidget extends StatelessWidget {
  const IOBaseWidget(
      {super.key,
      required this.title,
      required this.selected,
      required this.onClick});
  final String title;
  final void Function()? onClick;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            border:
                Border.all(color: selected ? Colors.purple[900]! : Colors.grey),
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(
            title,
            style:
                TextStyle(color: selected ? Colors.purple[900]! : Colors.grey),
          ),
        ),
      ),
    );
  }
}
