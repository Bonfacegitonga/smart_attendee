import 'package:flutter/material.dart';
import 'package:getwidget/components/dropdown/gf_multiselect.dart';
import 'package:getwidget/getwidget.dart';
import 'package:getwidget/types/gf_checkbox_type.dart';

class Multiselect extends StatefulWidget {
  final List<dynamic> dropList;
  final String title;
  final Function(List<dynamic>) onChanged;
  // final Widget submit;
  const Multiselect({
    super.key,
    required this.dropList,
    required this.title,
    required this.onChanged,
  });

  @override
  State<Multiselect> createState() => _MultiselectState();
}

class _MultiselectState extends State<Multiselect> {
  final List<dynamic> _selectedItems = [];
  @override
  Widget build(BuildContext context) {
    return GFMultiSelect(
      items: widget.dropList,

      onSelect: (value) {
        setState(() {
          if (_selectedItems.contains(value)) {
            _selectedItems.remove(value);
          } else {
            _selectedItems.add(value);
          }
          widget.onChanged(_selectedItems);
        });
      },
      //dropdownTitleTileText: 'Messi, Griezmann, Coutinho ',
      dropdownTitleTileColor: Colors.grey[200],
      //size: GFSize.MEDIUM,
      dropdownTitleTileMargin:
          const EdgeInsets.only(top: 22, left: 18, right: 18, bottom: 5),
      dropdownTitleTilePadding: const EdgeInsets.all(10),
      dropdownUnderlineBorder:
          const BorderSide(color: Colors.transparent, width: 2),
      dropdownTitleTileBorder:
          Border.all(color: Colors.grey.shade300, width: 1),
      dropdownTitleTileBorderRadius: BorderRadius.circular(5),
      expandedIcon: const Icon(
        Icons.keyboard_arrow_down,
        color: Colors.black54,
      ),
      collapsedIcon: const Icon(
        Icons.keyboard_arrow_up,
        color: Colors.black54,
      ),
      submitButton: const Text("Ok"),
      dropdownTitleTileTextStyle:
          const TextStyle(fontSize: 14, color: Colors.black54),
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.all(6),
      type: GFCheckboxType.basic,
      activeBgColor: Colors.green.withOpacity(0.5),
      inactiveBorderColor: Colors.grey.shade200,
    );
  }
}
