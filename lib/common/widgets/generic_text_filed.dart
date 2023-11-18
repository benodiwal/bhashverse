import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/constants/app_constants.dart';
import '../../utils/theme/app_text_style.dart';
import '../../utils/theme/app_theme_provider.dart';

class GenericTextField extends StatelessWidget {
  const GenericTextField({
    super.key,
    required TextEditingController controller,
    FocusNode? focusNode,
    int lines = 1,
    String hintText = '',
    final Function(String value)? onChange,
  })  : _controller = controller,
        _focusNode = focusNode,
        _lines = lines,
        _hintText = hintText,
        _onChange = onChange;

  final TextEditingController _controller;
  final FocusNode? _focusNode;
  final int _lines;
  final String _hintText;
  final Function(String value)? _onChange;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: regular18Primary(context),
      maxLines: _lines,
      maxLength: TextField.noMaxLength,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      minLines: _lines,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: _hintText,
        hintStyle:
            regular24(context).copyWith(color: context.appTheme.hintTextColor),
        hintMaxLines: 4,
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(textFieldRadius),
            ),
            borderSide: BorderSide.none),
        counterText: '',
        contentPadding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 12.w),
        filled: true,
      ),
      onChanged: _onChange,
    );
  }
}
