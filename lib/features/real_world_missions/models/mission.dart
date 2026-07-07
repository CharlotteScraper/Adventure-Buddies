import 'package:flutter/material.dart';

class MissionRecord {
  final int? id;
  final int profileId;
  final String missionId;
  final String title;
  final bool isCompleted;
  final DateTime assignedAt;
  final DateTime? completedAt;

  MissionRecord({
    this.id,
    required this.profileId,
    required this.missionId,
    required this.title,
    this.isCompleted = false,
    DateTime? assignedAt,
    this.completedAt,
  }) : assignedAt = assignedAt ?? DateTime.now();
}