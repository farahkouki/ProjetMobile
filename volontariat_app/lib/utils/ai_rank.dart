import 'dart:math' as math;

class LocalEmbedder {
  final int dim;
  final int ngram;
  LocalEmbedder({this.dim = 1024, this.ngram = 3});

  List<double> embed(String text) {
    final v = List<double>.filled(dim, 0.0);
    final t = text.toLowerCase().replaceAll(RegExp(r'[^a-zàâçéèêëîïôûùüÿñæœ0-9 ]', unicode: true), ' ');
    final s = '  $t  '; // padding léger
    for (int i = 0; i <= s.length - ngram; i++) {
      final g = s.substring(i, i + ngram);
      final h = _fnv1a(g) % dim;
      v[h] += 1.0;
    }
    // l2-normalize
    final norm = math.sqrt(v.fold<double>(0.0, (a,b)=>a + b*b));
    if (norm > 0) {
      for (int i=0;i<v.length;i++) v[i] /= norm;
    }
    return v;
  }

  int _fnv1a(String s) {
    int hash = 0x811C9DC5;
    for (int i = 0; i < s.length; i++) {
      hash ^= s.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.abs();
  }
}

double cosine(List<double> a, List<double> b) {
  final n = math.min(a.length, b.length);
  double dot = 0, na = 0, nb = 0;
  for (int i=0;i<n;i++){
    dot += a[i]*b[i];
    na += a[i]*a[i];
    nb += b[i]*b[i];
  }
  if (na==0 || nb==0) return 0;
  return dot / (math.sqrt(na)*math.sqrt(nb));
}

/// Classement IA : renvoie nouvelle liste triée + ajoute `score`
List<Map<String, Object?>> rankByProfile({
  required String profileText,
  required List<Map<String, Object?>> items,
}) {
  final emb = LocalEmbedder(dim: 1024, ngram: 3);
  final ep = emb.embed(profileText);
  final ranked = items.map((it) {
    final txt = '${it['title'] ?? ''}. ${it['category'] ?? ''}. ${it['description'] ?? ''}';
    final ei = emb.embed(txt);
    final s = cosine(ep, ei);
    return {...it, 'score': double.parse((s).toStringAsFixed(4))};
  }).toList()
    ..sort((a,b)=> (b['score'] as double).compareTo(a['score'] as double));
  return ranked;
}
