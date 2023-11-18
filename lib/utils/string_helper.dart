import 'package:flutter/material.dart';

void replaceWordWithHint(
    TextEditingController sourceTextController, String hint) {
  String wholeText = sourceTextController.text;
  int cursorPosition = sourceTextController.selection.base.offset;
  int? startingPosition = getStartingIndexOfWord(wholeText, cursorPosition - 1);
  int? endingPosition = getEndIndexOfWord(wholeText, startingPosition ?? 0);
  String firstHalf = wholeText.substring(0, startingPosition);
  String secondHalf = wholeText.substring(endingPosition, (wholeText.length));

  String newSentence = '${firstHalf.trim()} $hint ${secondHalf.trim()}';
  sourceTextController.text = newSentence;

  sourceTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: '${firstHalf.trim()} $hint '.length));
}

int? getStartingIndexOfWord(String text, int cursorPosition) {
  int? startingPosOfWord;
  for (var i = (cursorPosition - 1); i >= 0 && text[i] != ' '; i--) {
    startingPosOfWord = i;
  }
  return startingPosOfWord;
}

int getEndIndexOfWord(String text, int startingPosition) {
  int endPosition = startingPosition;
  for (var i = startingPosition; i < (text.length) && text[i] != ' '; i++) {
    endPosition = i;
  }
  return endPosition + 1;
}

String getWordFromCursorPosition(String text, int cursorPosition) {
  int? startingPosition = getStartingIndexOfWord(text, cursorPosition);
  int endPosition = getEndIndexOfWord(text, startingPosition ?? 0);
  if (startingPosition != null) {
    return text.substring(startingPosition, endPosition);
  } else {
    return '';
  }
}
