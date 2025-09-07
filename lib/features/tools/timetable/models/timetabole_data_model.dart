// models/timetable_models.dart
class TimeTableResponse {
  final List<TimeTableEntry> entries;
  final int total;
  final int page;
  final int pages;

  TimeTableResponse({
    required this.entries,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory TimeTableResponse.fromJson(Map<String, dynamic> json) {
    return TimeTableResponse(
      entries: (json['entries'] as List)
          .map((entry) => TimeTableEntry.fromJson(entry))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      pages: json['pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((entry) => entry.toJson()).toList(),
      'total': total,
      'page': page,
      'pages': pages,
    };
  }
}

class TimeTableEntry {
  final String id;
  final String courseTitle;
  final String level;
  final String session;
  final String semester;
  final String courseCode;
  final int creditUnits;
  final List<DaySchedule> days;
  final List<String> lecturers;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimeTableEntry({
    required this.id,
    required this.courseTitle,
    required this.level,
    required this.session,
    required this.semester,
    required this.courseCode,
    required this.creditUnits,
    required this.days,
    required this.lecturers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeTableEntry.fromJson(Map<String, dynamic> json) {
    return TimeTableEntry(
      id: json['id'] as String,
      courseTitle: json['courseTitle'] as String,
      level: json['level'] as String,
      session: json['session'] as String,
      semester: json['semester'] as String,
      courseCode: json['courseCode'] as String,
      creditUnits: json['creditUnits'] as int,
      days: (json['days'] as List)
          .map((day) => DaySchedule.fromJson(day))
          .toList(),
      lecturers: (json['lecturers'] as List).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseTitle': courseTitle,
      'level': level,
      'session': session,
      'semester': semester,
      'courseCode': courseCode,
      'creditUnits': creditUnits,
      'days': days.map((day) => day.toJson()).toList(),
      'lecturers': lecturers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class DaySchedule {
  final String day;
  final String startTime;
  final String endTime;

  DaySchedule({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      day: json['day'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}