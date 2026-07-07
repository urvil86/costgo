/// Alias dictionary: maps Costco receipt abbreviations to plain-English
/// tokens. Seeded from a bundled JSON asset, grown by user confirmations.
library;

class AliasDictionary {
  AliasDictionary(Map<String, String> seed)
      : _aliases = {
          for (final e in seed.entries) e.key.toUpperCase().trim(): e.value
        };

  final Map<String, String> _aliases;

  /// Expands known abbreviated tokens in a receipt name.
  /// `KS ORG PNT BTR` → `kirkland organic peanut butter`.
  String expand(String receiptName) {
    final tokens = receiptName.toUpperCase().split(RegExp(r'\s+'));
    // Longest-phrase-first: try multi-word aliases before single tokens.
    final out = <String>[];
    var i = 0;
    while (i < tokens.length) {
      String? replacement;
      var consumed = 1;
      for (var len = 3; len >= 1; len--) {
        if (i + len > tokens.length) continue;
        final phrase = tokens.sublist(i, i + len).join(' ');
        final hit = _aliases[phrase];
        if (hit != null) {
          replacement = hit;
          consumed = len;
          break;
        }
      }
      out.add(replacement ?? tokens[i].toLowerCase());
      i += consumed;
    }
    return out.join(' ');
  }

  /// Records a user confirmation: the whole receipt name now maps to the
  /// list item's name. Also learns unseen individual tokens when the
  /// confirmation is unambiguous (single-token both sides).
  void learn(String receiptName, String plainName) {
    _aliases[receiptName.toUpperCase().trim()] = plainName.toLowerCase().trim();
  }

  Map<String, String> toJson() => Map.of(_aliases);

  static const Map<String, String> defaultSeed = {
    // Brand / house shorthand
    'KS': 'kirkland', 'KIRK': 'kirkland', 'KLND': 'kirkland',
    // Common abbreviations — seed set; grows from the receipt corpus and
    // user confirmations post-launch.
    'ORG': 'organic', 'ORGN': 'organic',
    'PNT': 'peanut', 'PNUT': 'peanut',
    'BTR': 'butter', 'BUTTR': 'butter',
    'CHKN': 'chicken', 'CHCKN': 'chicken', 'CHK': 'chicken',
    'BRST': 'breast',
    'GRND': 'ground', 'BF': 'beef',
    'CHS': 'cheese', 'CHZ': 'cheese', 'SHRD': 'shredded',
    'MZZRL': 'mozzarella', 'CHDDR': 'cheddar', 'PARM': 'parmesan',
    'MLK': 'milk', 'ALMND': 'almond', 'OATMLK': 'oat milk',
    'EGGS': 'eggs', 'LG': 'large', 'XL': 'extra large', 'CAGE FR': 'cage free',
    'BRD': 'bread', 'WHT': 'wheat', 'SRDGH': 'sourdough',
    'TLT': 'toilet', 'TP': 'toilet paper', 'BATH TISSUE': 'toilet paper',
    'PPR': 'paper', 'TWL': 'towel', 'TWLS': 'towels', 'PAPER TWL': 'paper towels',
    'LNDRY': 'laundry', 'DTRGNT': 'detergent', 'DTG': 'detergent',
    'DSH': 'dish', 'SP': 'soap',
    'WTR': 'water', 'SPRK': 'sparkling', 'BTL': 'bottle', 'BTLS': 'bottles',
    'JCE': 'juice', 'ORNG': 'orange', 'OJ': 'orange juice',
    'STRWB': 'strawberries', 'STRAWB': 'strawberries', 'BLUBRY': 'blueberries',
    'RSPBRY': 'raspberries', 'BNNS': 'bananas', 'BAN': 'bananas',
    'AVOC': 'avocados', 'AVCDO': 'avocados', 'HASS': 'hass avocados',
    'SPIN': 'spinach', 'SPNCH': 'spinach', 'SLD': 'salad', 'MX': 'mix',
    'TOM': 'tomatoes', 'TMTO': 'tomatoes', 'GRP': 'grape',
    'ONYN': 'onions', 'YLW': 'yellow', 'GRN': 'green',
    'PTATO': 'potatoes', 'RUSSET': 'russet potatoes',
    'RTSS': 'rotisserie', 'ROT CHKN': 'rotisserie chicken',
    'SLMN': 'salmon', 'ATLNTC': 'atlantic', 'TLPIA': 'tilapia',
    'SHRMP': 'shrimp', 'FRZ': 'frozen', 'FRZN': 'frozen',
    'PZZ': 'pizza', 'PZA': 'pizza', 'PEPP': 'pepperoni',
    'YGRT': 'yogurt', 'GRK': 'greek', 'VAN': 'vanilla',
    'CFF': 'coffee', 'CFFE': 'coffee', 'WHL BN': 'whole bean',
    'CRML': 'caramel', 'CHOC': 'chocolate', 'CHCLT': 'chocolate',
    'ALM': 'almonds', 'CSHW': 'cashews', 'PSTCH': 'pistachios',
    'MXD NUT': 'mixed nuts', 'TRL MX': 'trail mix',
    'CRCKR': 'crackers', 'CHP': 'chips', 'TORT': 'tortilla',
    'GRNLA': 'granola', 'BR': 'bar', 'BRS': 'bars', 'PROT': 'protein',
    'OLV': 'olive', 'EVOO': 'extra virgin olive oil',
    'VINGR': 'vinegar', 'BLSMC': 'balsamic',
    'RCE': 'rice', 'JASM': 'jasmine', 'QNOA': 'quinoa',
    'PSTA': 'pasta', 'SPGHT': 'spaghetti', 'MRNRA': 'marinara',
    'CRL': 'cereal', 'OTML': 'oatmeal',
    'HNY': 'honey', 'MPL': 'maple', 'SYRP': 'syrup',
    'BCN': 'bacon', 'SSGE': 'sausage', 'TRKY': 'turkey', 'HM': 'ham',
    'VIT': 'vitamin', 'VITC': 'vitamin c', 'FSH OIL': 'fish oil',
    'BTRY': 'battery', 'BTRYS': 'batteries', 'AA': 'aa batteries',
    'KCUP': 'k-cups', 'POD': 'pods',
    'WNE': 'wine', 'CAB': 'cabernet', 'CHARD': 'chardonnay',
    'SLTD': 'salted', 'UNSLTD': 'unsalted', 'RSTD': 'roasted',
    'GF': 'gluten free', 'WHP': 'whipped', 'CRM': 'cream',
    'HVY': 'heavy', 'HLF': 'half', 'H&H': 'half and half',
    'PB': 'peanut butter',
  };
}
