import 'package:flutter/material.dart';

class Exercise {
  final String id;
  final String title;
  final IconData icon;
  final String durationLabel;
  final String trimesterNote;
  final List<String> benefits;
  final List<String> steps;
  final List<String> cautions;

  const Exercise({
    required this.id,
    required this.title,
    required this.icon,
    required this.durationLabel,
    required this.trimesterNote,
    required this.benefits,
    required this.steps,
    required this.cautions,
  });
}
