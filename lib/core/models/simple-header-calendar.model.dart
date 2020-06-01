import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class SimpleHeaderCalendarStyle {
  EdgeInsets padding;
  EdgeInsets margin;
  Color leftChevronContainer;
  Constraints leftChevronConstraintsContainer;
  IconData leftChevronIcon;
  double leftChevronSizeIcon;
  Color leftChevronColorIcon;

  Color rightChevronContainer;
  Constraints rightChevronConstraintsContainer;
  IconData rightChevronIcon;
  double rightChevronSizeIcon;
  Color rightChevronColorIcon;

  SimpleHeaderCalendarStyle({
    this.margin = const EdgeInsets.only(
      bottom: 24,
    ),
    this.padding,
    this.leftChevronContainer,
    this.leftChevronConstraintsContainer = const BoxConstraints(
      minWidth: 20,
      minHeight: 20,
    ),
    this.leftChevronIcon = CupertinoIcons.left_chevron,
    this.leftChevronSizeIcon = 12,
    this.leftChevronColorIcon = const Color(0xFF585858),
    this.rightChevronContainer,
    this.rightChevronConstraintsContainer = const BoxConstraints(
      minWidth: 20,
      minHeight: 20,
    ),
    this.rightChevronIcon = CupertinoIcons.right_chevron,
    this.rightChevronSizeIcon = 12,
    this.rightChevronColorIcon = const Color(0xFF585858),
  });
}
