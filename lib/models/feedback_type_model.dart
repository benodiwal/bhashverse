import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackTypeModel {
  final String taskType;
  final String question;
  final String? suggestedOutputTitle;
  final TextEditingController textController;
  final FocusNode focusNode;
  Rxn<double> taskRating;
  RxBool isExpanded;
  List<GranularFeedback> granularFeedbacks;

  FeedbackTypeModel({
    required this.taskType,
    required this.question,
    required this.textController,
    required this.focusNode,
    required this.taskRating,
    required this.isExpanded,
    required this.granularFeedbacks,
    this.suggestedOutputTitle,
  });
}

class GranularFeedback {
  final String question;
  final List<dynamic> supportedFeedbackTypes;
  double? mainRating;
  final List<dynamic> parameters;

  GranularFeedback({
    required this.question,
    required this.supportedFeedbackTypes,
    required this.parameters,
    required this.mainRating,
  });
}

class Parameter {
  final String paramName;
  double? paramRating;

  Parameter({
    required this.paramName,
    required this.paramRating,
  });
}
