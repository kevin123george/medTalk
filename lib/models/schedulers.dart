enum ScheduleType {
  Appointment,
  GeneralReminder,
}

enum RepeatType {
  Daily,
  Weekly,
  Monthly, None,
}

class Schedulers {
  int? id;
  String title;
  int? startDateTime;
  int? endDateTime;
  int? reminderTime; // when to remind the user example 10 min before starttime
  String? body;
  ScheduleType? reminderType;
  RepeatType? repeatType;
  int? repeatEndDate;
  bool isRecurrent;

  Schedulers({
    this.id,
    required this.title,
    this.startDateTime,
    this.endDateTime,
    this.body,
    this.reminderType = ScheduleType.GeneralReminder,
    this.repeatType = RepeatType.Daily,
    this.isRecurrent = false,
    this.reminderTime,
    // required DateTime repeatEndDate,
  });

  @override
  String toString() {
    return 'Schedulers{id: $id, title: $title, startDateTime: $startDateTime, endDateTime: $endDateTime, reminderTime: $reminderTime, body: $body, reminderType: $reminderType, repeatType: $repeatType, repeatEndDate: $repeatEndDate, isRecurrent: $isRecurrent}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'reminderTime': reminderTime,
      'body': body,
      'reminderType': reminderType.toString().split('.').last,
      'repeatType': repeatType.toString().split('.').last,
      // 'repeatEndDate': repeatEndDate,
      'isRecurrent': isRecurrent,
    };
  }
}
