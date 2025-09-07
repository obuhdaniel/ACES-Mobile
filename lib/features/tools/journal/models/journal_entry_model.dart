import 'package:aces_uniben/features/tools/journal/services/journal_db_helper.dart';
import 'package:flutter/material.dart';
class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final TimeOfDay time;
  final String category;
  final Color color;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.time,
    required this.category,
    required this.color,
  });

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    TimeOfDay? time,
    String? category,
    Color? color,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      JournalFields.id: id,
      JournalFields.title: title,
      JournalFields.content: content,
      JournalFields.date: date.millisecondsSinceEpoch,
      JournalFields.timeHour: time.hour,
      JournalFields.timeMinute: time.minute,
      JournalFields.category: category,
      JournalFields.colorValue: color.value,
    };
  }

  static JournalEntry fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json[JournalFields.id] as String,
      title: json[JournalFields.title] as String,
      content: json[JournalFields.content] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json[JournalFields.date] as int),
      time: TimeOfDay(
        hour: json[JournalFields.timeHour] as int,
        minute: json[JournalFields.timeMinute] as int,
      ),
      category: json[JournalFields.category] as String,
      color: Color(json[JournalFields.colorValue] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JournalEntry &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.date == date &&
        other.time == time &&
        other.category == category &&
        other.color == color;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, content, date, time, category, color);
  }
}
