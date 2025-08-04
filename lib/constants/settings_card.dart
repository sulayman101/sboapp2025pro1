import 'package:flutter/material.dart';

class CardSettings extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subTitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CardSettings({
    super.key,
    required this.leading,
    required this.title,
    this.subTitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        elevation: 5,
        child: ListTile(
          onTap: onTap,
          leading: leading,
          title: title,
          subtitle: subTitle,
          trailing: trailing,
        ),
      ),
    );
  }
}
