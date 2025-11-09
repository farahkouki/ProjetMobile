// lib/core/utils/country_utils.dart

const Map<String, String> countryCodeMap = {
  '+216': 'Tunisie',
  '+213': 'Algérie',
  '+212': 'Maroc',
  '+33': 'France',
  '+1': 'USA',
  '+44': 'Royaume-Uni',
  '+49': 'Allemagne',
  '+34': 'Espagne',
  '+39': 'Italie',
  '+966': 'Arabie Saoudite',
};

String getCountryFromPhone(String phone) {
  for (final code in countryCodeMap.keys) {
    if (phone.startsWith(code)) {
      return countryCodeMap[code]!;
    }
  }
  return 'Inconnu';
}

// --- DRAPEAUX RÉELS ---
const Map<String, String> countryFlags = {
  'Tunisie': 'Tunisia flag',
  'Algérie': 'Algeria flag',
  'Maroc': 'Morocco flag',
  'France': 'France flag',
  'USA': 'USA flag',
  'Royaume-Uni': 'UK flag',
  'Allemagne': 'Germany flag',
  'Espagne': 'Spain flag',
  'Italie': 'Italy flag',
  'Arabie Saoudite': 'Saudi Arabia flag',
  'Inconnu': 'Unknown flag',
};