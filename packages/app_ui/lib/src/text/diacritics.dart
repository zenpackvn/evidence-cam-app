/// Folds Vietnamese diacritics to base letters, for accent-insensitive
/// search ("hoi" matches "Hội"). Works on lowercase input; pass
/// `s.toLowerCase()` for case-insensitive matching.
String stripDiacritics(String s) {
  const groups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };
  var out = s;
  for (final e in groups.entries) {
    for (final ch in e.value.split('')) {
      out = out.replaceAll(ch, e.key);
    }
  }
  return out;
}
