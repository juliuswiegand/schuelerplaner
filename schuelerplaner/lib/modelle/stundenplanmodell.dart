final String fachTabelle = 'faecher';
final String montagTabelle = 'montag';
final String dienstagTabelle = 'dienstag';
final String mittwochTabelle = 'mittwoch';
final String donnerstagTabelle = 'donnerstag';
final String freitagTabelle = 'freitag';
final String samstagTabelle = 'samstag';
final String sonntagTabelle = 'sonntag';

class FachFelder {
  static final List<String> werte = [
    id, lehrer, name, farbe
  ];

  static final String id = '_id';
  static final String lehrer = 'lehrer';
  static final String name = 'name';
  static final String farbe = 'farbe';
}

class SchulstundeFelder {
  static final List<String> werte = [
    id, fachid, raum, startzeit, endzeit
  ];

  static final String id = '_id';
  static final String fachid = 'fachid';
  static final String raum = 'raum';
  static final String startzeit = 'startzeit';
  static final String endzeit = 'endzeit';
}

class Fach {
  final int? id;
  final String lehrer;
  final String name;
  final String farbe;

  const Fach ({
    this.id,
    required this.lehrer,
    required this.name,
    required this.farbe,
  });

  Map<String, Object?> zuJson() => {
    FachFelder.id: id,
    FachFelder.lehrer: lehrer,
    FachFelder.name: name,
    FachFelder.farbe: farbe,
  };

  static Fach vonJson(Map<String, Object?> json) => Fach(
    id: json[FachFelder.id] as int,
    lehrer: json[FachFelder.lehrer] as String,
    name: json[FachFelder.name] as String,
    farbe: json[FachFelder.farbe] as String,
  );

  Fach kopie({
    int? id,
    String? lehrer,
    String? name,
    String? farbe,
  }) =>
  Fach(
    id: id ?? this.id,
    lehrer: lehrer ?? this.lehrer,
    name: name ?? this.name,
    farbe: farbe ?? this.farbe,
  );
}

class Schulstunde {
  final int? id;
  final int fachid;
  final String raum;
  final DateTime startzeit;
  final DateTime endzeit;

  const Schulstunde ({
    this.id,
    required this.fachid,
    required this.raum,
    required this.startzeit,
    required this.endzeit
  });

  static Schulstunde vonJson(Map<String, Object?> json) => Schulstunde(
    id: json[SchulstundeFelder.id] as int,
    fachid: json[SchulstundeFelder.fachid] as int,
    raum: json[SchulstundeFelder.raum] as String,
    startzeit: DateTime.parse(json[SchulstundeFelder.startzeit] as String),
    endzeit: DateTime.parse(json[SchulstundeFelder.endzeit] as String),
  );

  Map<String, Object?> zuJson() => {
    SchulstundeFelder.id: id,
    SchulstundeFelder.fachid: fachid,
    SchulstundeFelder.raum: raum,
    SchulstundeFelder.startzeit: startzeit.toIso8601String(),
    SchulstundeFelder.endzeit: endzeit.toIso8601String(),
  };

  Schulstunde kopie({
    int? id,
    int? fachid,
    String? raum,
    DateTime? startzeit,
    DateTime? endzeit,
  }) =>
  Schulstunde(
    id: id ?? this.id,
    fachid: fachid ?? this.fachid,
    raum: raum ?? this.raum,
    startzeit: startzeit ?? this.startzeit,
    endzeit: endzeit ?? this.endzeit,
  );
}