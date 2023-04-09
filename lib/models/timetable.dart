class Timetable implements Comparable<Timetable> {
  final DateTime? startTime;
  final DateTime? endTime;
  final String? subject;
  final String? faculty;
  final String? semester;

  Timetable({
    this.startTime,
    this.endTime,
    this.subject,
    this.faculty,
    this.semester,
  });

  @override
  int compareTo(Timetable other) {
    return startTime!.compareTo(other.startTime!);
  }
}