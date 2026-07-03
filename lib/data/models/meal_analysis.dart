class MealItem {
  final String name;
  final String note;
  final int kcal;

  const MealItem({required this.name, this.note = '', required this.kcal});

  factory MealItem.fromJson(Map<String, dynamic> json) => MealItem(
        name: json['name'] ?? '',
        note: json['note'] ?? '',
        kcal: (json['kcal'] as num?)?.round() ?? 0,
      );
}

class MealSuggestion {
  final String label;
  final int deltaKcal; // dương = thêm, âm = giảm

  const MealSuggestion({required this.label, required this.deltaKcal});

  factory MealSuggestion.fromJson(Map<String, dynamic> json) =>
      MealSuggestion(
        label: json['label'] ?? '',
        deltaKcal: (json['delta_kcal'] as num?)?.round() ?? 0,
      );
}

class MealAnalysis {
  final int totalKcal;
  final String confidence; // cao | trung bình | thấp
  final List<MealItem> items;
  final int proteinG;
  final int carbG;
  final int fatG;
  final int fiberG;
  final String comment;
  final List<MealSuggestion> suggestions;

  const MealAnalysis({
    required this.totalKcal,
    required this.confidence,
    required this.items,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    required this.fiberG,
    required this.comment,
    required this.suggestions,
  });

  factory MealAnalysis.fromJson(Map<String, dynamic> json) => MealAnalysis(
        totalKcal: (json['total_kcal'] as num?)?.round() ?? 0,
        confidence: json['confidence'] ?? 'trung bình',
        items: ((json['items'] as List?) ?? [])
            .map((e) => MealItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        proteinG: (json['protein_g'] as num?)?.round() ?? 0,
        carbG: (json['carb_g'] as num?)?.round() ?? 0,
        fatG: (json['fat_g'] as num?)?.round() ?? 0,
        fiberG: (json['fiber_g'] as num?)?.round() ?? 0,
        comment: json['comment'] ?? '',
        suggestions: ((json['suggestions'] as List?) ?? [])
            .map((e) =>
                MealSuggestion.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}
