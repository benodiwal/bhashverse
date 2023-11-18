import 'dart:math' show pi;

import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/widgets/generic_text_filed.dart';
import '../../../models/feedback_type_model.dart';
import '../../../utils/constants/app_constants.dart';
import '../../../utils/theme/app_text_style.dart';
import '../../../utils/theme/app_theme_provider.dart';

class RatingWidget extends StatefulWidget {
  const RatingWidget({
    super.key,
    required this.feedbackTypeModel,
    this.onTextChanged,
    this.onRatingChanged,
  });

  final FeedbackTypeModel feedbackTypeModel;
  final Function(double value)? onRatingChanged;
  final Function(String value)? onTextChanged;

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    // _feedbackController = Get.find();
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: defaultAnimationTime,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: pi,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            widget.feedbackTypeModel.isExpanded.value =
                !widget.feedbackTypeModel.isExpanded.value;
            widget.feedbackTypeModel.isExpanded.value
                ? _controller.forward()
                : _controller.reverse();
          },
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.feedbackTypeModel.question,
                    style: semibold16(context),
                  ),
                ),
              ),
              AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(
                          _animation.value,
                        ),
                      child: SvgPicture.asset(iconArrowDown,
                          color: context.appTheme.highlightedTextColor),
                    );
                  }),
            ],
          ),
        ),
        Obx(
          () => AnimatedSwitcher(
            duration: defaultAnimationTime,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: widget.feedbackTypeModel.isExpanded.value
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 12.w),
                      Obx(
                        () => RatingBar(
                          filledIcon: Icons.star,
                          emptyIcon: Icons.star_border,
                          filledColor: context.appTheme.primaryColor,
                          onRatingChanged: widget.onRatingChanged,
                          initialRating:
                              widget.feedbackTypeModel.taskRating.value ?? 0.0,
                          maxRating: 5,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      Obx(
                        () => Visibility(
                          visible: widget.feedbackTypeModel.taskRating.value !=
                                  null &&
                              (widget.feedbackTypeModel.taskRating.value ??
                                      0.0) <
                                  4 &&
                              widget.feedbackTypeModel.taskRating.value != 0,
                          child: Column(
                            children: [
                              SizedBox(height: 20.w),
                              if (widget.feedbackTypeModel.taskType == 'asr' ||
                                  widget.feedbackTypeModel.taskType ==
                                      'translation')
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.feedbackTypeModel
                                            .suggestedOutputTitle !=
                                        null)
                                      Text(
                                        widget.feedbackTypeModel
                                            .suggestedOutputTitle!,
                                        style: semibold14(context).copyWith(
                                            color: context
                                                .appTheme.secondaryTextColor,
                                            height: 1.5),
                                      ),
                                    SizedBox(height: 14.w),
                                    GenericTextField(
                                      controller: widget
                                          .feedbackTypeModel.textController,
                                      focusNode:
                                          widget.feedbackTypeModel.focusNode,
                                      onChange: widget.onTextChanged,
                                    ),
                                  ],
                                ),
                              ...widget.feedbackTypeModel.granularFeedbacks
                                  .map((feedback) {
                                return feedback.supportedFeedbackTypes
                                            .contains('rating') ||
                                        feedback.supportedFeedbackTypes
                                            .contains('rating-list')
                                    ? DepthRatings(
                                        question: feedback.question,
                                        rating: feedback.mainRating,
                                        isRating: feedback
                                            .supportedFeedbackTypes
                                            .contains('rating'),
                                        onRatingChanged: (value) =>
                                            feedback.mainRating = value,
                                        depthRatings: feedback
                                                .supportedFeedbackTypes
                                                .contains('rating-list')
                                            ? feedback.parameters
                                                .map((parameter) {
                                                return DepthRatings(
                                                  question: parameter.paramName,
                                                  rating: parameter.paramRating,
                                                  isRating: true,
                                                  showAsRow: true,
                                                  onRatingChanged: (value) {
                                                    parameter.paramRating =
                                                        value;
                                                  },
                                                );
                                              }).toList()
                                            : null,
                                      )
                                    : const SizedBox.shrink();
                              })
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.w),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        const Divider(),
        SizedBox(height: 20.w),
      ],
    );
  }
}

class DepthRatings extends StatelessWidget {
  const DepthRatings({
    super.key,
    required String question,
    required bool isRating,
    showAsRow = false,
    double? rating,
    required Function(double value) onRatingChanged,
    List<DepthRatings>? depthRatings,
  })  : _question = question,
        _rating = rating,
        _isRating = isRating,
        _showAsRow = showAsRow,
        _depthRatings = depthRatings,
        _onRatingChanged = onRatingChanged;

  final String _question;
  final double? _rating;
  final bool _isRating, _showAsRow;
  final List<DepthRatings>? _depthRatings;
  final Function(double value) _onRatingChanged;

  @override
  Widget build(BuildContext context) {
    Widget question() => Text(_question, style: regular16(context));
    Widget ratingBar() => RatingBar(
          filledIcon: Icons.star,
          emptyIcon: Icons.star_border,
          filledColor: context.appTheme.primaryColor,
          initialRating: _rating ?? 0,
          maxRating: 5,
          onRatingChanged: (value) {
            _onRatingChanged(value);
          },
        );
    return Padding(
      padding: const EdgeInsets.all(6).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_depthRatings != null && _depthRatings!.isNotEmpty)
            const Divider(),
          _showAsRow
              ? Row(
                  children: [
                    Expanded(child: question()),
                    SizedBox(width: 8.w),
                    if (_isRating) ratingBar()
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.w),
                    question(),
                    SizedBox(height: 14.w),
                    if (_isRating) ratingBar()
                  ],
                ),
          if (_depthRatings != null && _depthRatings!.isNotEmpty)
            Column(
              children: [
                ..._depthRatings!.map((e) => e),
                const Divider(),
              ],
            ),
        ],
      ),
    );
  }
}
