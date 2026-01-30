enum PersonType {
  individual,
  juristic;

  String get label => switch (this) {
    individual => 'บุคคลธรรมดา',
    juristic => 'นิติบุคคล',
  };

  String get value => name;
}
