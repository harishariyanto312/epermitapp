import 'package:epermits/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutx/flutx.dart';

class SingleDrawerItem extends StatefulWidget {
  var selectedPageCode;
  final IconData iconData;
  final String title;
  final String pageCode;
  final Function() action;

  SingleDrawerItem({required this.selectedPageCode, required this.iconData, required this.title, required this.pageCode, required this.action});

  @override
  State<SingleDrawerItem> createState() => _SingleDrawerItemState();
}

class _SingleDrawerItemState extends State<SingleDrawerItem> {
  @override 
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: FxSpacing.x(16),
      leading: Icon(
        widget.iconData,
        size: 20,
        color: widget.selectedPageCode == widget.pageCode ? AppTheme.theme.colorScheme.primary : AppTheme.theme.colorScheme.onBackground.withAlpha(240),
      ),
      title: Text(
        widget.title,
        style: AppTheme.theme.textTheme.subtitle2!
          .merge(
            TextStyle(
              fontWeight: widget.selectedPageCode == widget.pageCode
                ? FontWeight.w600
                : FontWeight.w500,
              letterSpacing: 0.2
            )
          ).
          merge(
            TextStyle(
              color: widget.selectedPageCode == widget.pageCode
                ? AppTheme.theme.colorScheme.primary 
                : AppTheme.theme.colorScheme.onBackground.withAlpha(240)
            )
          ),
      ),
      onTap: widget.action,
    );
  }
}