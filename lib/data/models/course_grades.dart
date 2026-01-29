import '../../core/utils/date_utils.dart' as date_utils;
import '../../core/utils/grade_utils.dart';

/// Grade exam/test model
class Epreuve {
  final int? id;
  final String? libelle;
  final DateTime? dateDebutEvt;
  final bool estAbsent;
  final String? intervenants;
  final DateTime? dateObtention;
  final String? noteString;
  final bool estNonNoter;
  final List<String>? appreciation;
  
  const Epreuve({
    this.id,
    this.libelle,
    this.dateDebutEvt,
    this.estAbsent = false,
    this.intervenants,
    this.dateObtention,
    this.noteString,
    this.estNonNoter = false,
    this.appreciation,
  });
  
  factory Epreuve.fromJson(Map<String, dynamic> json) {
    return Epreuve(
      id: json['id'] as int?,
      libelle: json['libelle'] as String?,
      dateDebutEvt: date_utils.DateUtils.parseApiDate(json['date_debut_evt'] as String?),
      estAbsent: json['est_absent'] as bool? ?? false,
      intervenants: json['intervenants'] as String?,
      dateObtention: date_utils.DateUtils.parseApiDate(json['date_obtention'] as String?),
      noteString: json['note'] as String?,
      estNonNoter: json['est_non_noter'] as bool? ?? false,
      appreciation: (json['appreciation'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
  
  /// Get parsed grade as double
  double? get grade => GradeUtils.parseGrade(noteString);
  
  /// Get formatted grade for display
  String get displayGrade {
    if (estAbsent) return 'ABS';
    if (estNonNoter) return 'N/A';
    return GradeUtils.formatGrade(grade);
  }
  
  /// Get appreciation text
  String? get appreciationText => appreciation?.join(', ');
}

/// Course inscription details
class InscriptionCours {
  final String? nombreCreditsObtenus;
  final String? nombreCreditsPotentiels;
  final String? moyenne;
  final bool? estValidee;
  
  const InscriptionCours({
    this.nombreCreditsObtenus,
    this.nombreCreditsPotentiels,
    this.moyenne,
    this.estValidee,
  });
  
  factory InscriptionCours.fromJson(Map<String, dynamic> json) {
    return InscriptionCours(
      nombreCreditsObtenus: json['nombre_credits_obtenus'] as String?,
      nombreCreditsPotentiels: json['nombre_credits_potentiels'] as String?,
      moyenne: json['moyenne'] as String?,
      estValidee: json['est_validee'] as bool?,
    );
  }
  
  /// Get potential credits as int
  int? get potentialCredits => int.tryParse(nombreCreditsPotentiels ?? '');
  
  /// Get obtained credits as int
  int? get obtainedCredits => int.tryParse(nombreCreditsObtenus ?? '');
}

/// Course with grades model
class CourseGrades {
  final int? id;
  final String? coursCode;
  final String? coursLibelle;
  final String? intervenants;
  final InscriptionCours? inscriptionCours;
  final List<Epreuve> epreuves;
  
  const CourseGrades({
    this.id,
    this.coursCode,
    this.coursLibelle,
    this.intervenants,
    this.inscriptionCours,
    this.epreuves = const [],
  });
  
  factory CourseGrades.fromJson(Map<String, dynamic> json) {
    return CourseGrades(
      id: json['id'] as int?,
      coursCode: json['cours_code'] as String?,
      coursLibelle: json['cours_libelle'] as String?,
      intervenants: json['intervenants'] as String?,
      inscriptionCours: json['inscription_cours'] != null
          ? InscriptionCours.fromJson(json['inscription_cours'] as Map<String, dynamic>)
          : null,
      epreuves: (json['epreuves'] as List<dynamic>?)
              ?.map((e) => Epreuve.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  
  /// Get course display name
  String get displayName => coursLibelle ?? 'Untitled Course';
  
  /// Get average grade from all graded epreuves
  double? get averageGrade {
    final gradedEpreuves = epreuves.where((e) => e.grade != null).toList();
    if (gradedEpreuves.isEmpty) return null;
    
    final sum = gradedEpreuves.fold<double>(0, (prev, e) => prev + e.grade!);
    return sum / gradedEpreuves.length;
  }
  
  /// Get number of graded exams
  int get gradedExamsCount => epreuves.where((e) => e.grade != null).length;
  
  /// Get total exams count
  int get totalExamsCount => epreuves.length;
}
