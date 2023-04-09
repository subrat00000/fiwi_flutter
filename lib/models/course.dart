class Course implements Comparable<Course> {
  final String? code;
  final String? name;
  final String? semester;

  Course({
    this.code,
    this.name,
    this.semester,
  });

  @override
  int compareTo(Course other) {
    // Compare courses based on their semester
    return semester!.compareTo(other.semester!);
  }
}