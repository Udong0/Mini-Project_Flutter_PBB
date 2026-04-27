class Glitch {
  int? id;
  String title;
  String description;
  String imagePath;
  String dateCaught;

  Glitch({
    this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.dateCaught,
  });

  // Convert a Glitch object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'description': description,
      'image_path': imagePath,
      'date_caught': dateCaught,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Extract a Glitch object from a Map object
  factory Glitch.fromMap(Map<String, dynamic> map) {
    return Glitch(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['image_path'],
      dateCaught: map['date_caught'],
    );
  }
}
