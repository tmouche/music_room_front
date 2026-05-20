import 'package:flutter/material.dart';
import '../../app/theme/spacing.dart';


class ChooseLogButton extends StatefulWidget {
  const ChooseLogButton({
    super.key,
    required this.label,
  });

  final String label;

  @override
  State<ChooseLogButton> createState() => _ChooseLogButton();
}

class _ChooseLogButton extends State<ChooseLogButton> {

  bool isSelected = false;

  void _onSelected() {
    setState(() {
      isSelected = !isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: EdgeInsets.all(Spacing.xs),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.withAlpha(50) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextButton(
        onPressed: _onSelected,
        child: Text(, style: appTextTheme().titleSmall,)
      ),
    )
  }
}