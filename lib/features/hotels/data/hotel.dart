class Hotel {
  final int? id;
  final String adresse;
  final String ville;
  final String pay;   // (pays)
  final int tel;
  final String email;

  const Hotel({
    this.id,
    required this.adresse,
    required this.ville,
    required this.pay,
    required this.tel,
    required this.email,
  });

  factory Hotel.fromMap(Map<String, dynamic> m) => Hotel(
    id: m['id'] as int?,
    adresse: m['adresse'] as String,
    ville: m['ville'] as String,
    pay: m['pay'] as String,
    tel: (m['tel'] as num).toInt(),
    email: m['email'] as String,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'adresse': adresse,
    'ville': ville,
    'pay': pay,
    'tel': tel,
    'email': email,
  };
}
