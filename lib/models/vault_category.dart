enum VaultCategory { note, secret, link, code, document }

extension VaultCategoryX on VaultCategory {
  String get emoji {
    switch (this) {
      case VaultCategory.note:
        return '📝';
      case VaultCategory.secret:
        return '🔑';
      case VaultCategory.link:
        return '🔗';
      case VaultCategory.code:
        return '💻';
      case VaultCategory.document:
        return '📄';
    }
  }

  String get label {
    switch (this) {
      case VaultCategory.note:
        return 'Note';
      case VaultCategory.secret:
        return 'Secret';
      case VaultCategory.link:
        return 'Link';
      case VaultCategory.code:
        return 'Code';
      case VaultCategory.document:
        return 'Document';
    }
  }
}

VaultCategory categoryFromString(String value) {
  return VaultCategory.values.firstWhere(
    (c) => c.name == value,
    orElse: () => VaultCategory.note,
  );
}
