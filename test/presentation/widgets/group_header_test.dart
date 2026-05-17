import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libreotp/presentation/widgets/group_header.dart';

void main() {
  test('uses supplied colors for themed group headers', () {
    const backgroundColor = Colors.black;
    const textColor = Colors.white;

    final header = GroupHeader(
      groupName: 'Default',
      backgroundColor: backgroundColor,
      textColor: textColor,
      isCollapsed: false,
    );

    expect(header.color?.resolve({}), equals(backgroundColor));

    final iconCell = header.cells[0];
    final icon = iconCell.child as Icon;
    expect(icon.icon, equals(Icons.expand_more));

    final groupNameCell = header.cells[1];
    final paddedText = groupNameCell.child as Padding;
    final text = paddedText.child as Text;

    expect(text.data, equals('Default'));
    expect(text.style?.color, equals(textColor));
  });
}
