/// Absences response model
class AbsencesResponse {
  final int nbrTotalAbsenceExcuser;
  final int nbrTotalAbsenceNonExcuser;
  final String dureeTotaleAbsenceExcuser;
  final String dureeTotaleAbsenceNonExcuser;
  final List<Absence> absences;

  const AbsencesResponse({
    required this.nbrTotalAbsenceExcuser,
    required this.nbrTotalAbsenceNonExcuser,
    required this.dureeTotaleAbsenceExcuser,
    required this.dureeTotaleAbsenceNonExcuser,
    required this.absences,
  });

  factory AbsencesResponse.fromJson(Map<String, dynamic> json) {
    return AbsencesResponse(
      nbrTotalAbsenceExcuser: json['nbr_total_absence_excuser'] as int,
      nbrTotalAbsenceNonExcuser: json['nbr_total_absence_non_excuser'] as int,
      dureeTotaleAbsenceExcuser: json['duree_totale_absence_excuser'] as String,
      dureeTotaleAbsenceNonExcuser:
          json['duree_totale_absence_non_excuser'] as String,
      absences: (json['absences'] as List<dynamic>)
          .map((e) => Absence.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nbr_total_absence_excuser': nbrTotalAbsenceExcuser,
      'nbr_total_absence_non_excuser': nbrTotalAbsenceNonExcuser,
      'duree_totale_absence_excuser': dureeTotaleAbsenceExcuser,
      'duree_totale_absence_non_excuser': dureeTotaleAbsenceNonExcuser,
      'absences': absences.map((e) => e.toJson()).toList(),
    };
  }
}

/// Individual absence model
class Absence {
  final int id;
  final String duree;
  final MotifAbsence motifAbsence;
  final Evenement evenement;

  const Absence({
    required this.id,
    required this.duree,
    required this.motifAbsence,
    required this.evenement,
  });

  factory Absence.fromJson(Map<String, dynamic> json) {
    return Absence(
      id: json['id'] as int,
      duree: json['duree'] as String,
      motifAbsence:
          MotifAbsence.fromJson(json['motif_absence'] as Map<String, dynamic>),
      evenement:
          Evenement.fromJson(json['evenement'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duree': duree,
      'motif_absence': motifAbsence.toJson(),
      'evenement': evenement.toJson(),
    };
  }
}

/// Absence reason model
class MotifAbsence {
  final int id;
  final String libelle;
  final bool estExcuser;

  const MotifAbsence({
    required this.id,
    required this.libelle,
    required this.estExcuser,
  });

  factory MotifAbsence.fromJson(Map<String, dynamic> json) {
    return MotifAbsence(
      id: json['id'] as int,
      libelle: json['libelle'] as String,
      estExcuser: json['est_excuser'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'est_excuser': estExcuser,
    };
  }
}

/// Event model for absence
class Evenement {
  final String dateDebut;
  final String dateFin;
  final String intervenants;
  final String libelleConstruit;

  const Evenement({
    required this.dateDebut,
    required this.dateFin,
    required this.intervenants,
    required this.libelleConstruit,
  });

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      dateDebut: json['date_debut'] as String,
      dateFin: json['date_fin'] as String,
      intervenants: json['intervenants'] as String,
      libelleConstruit: json['libelle_construit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_debut': dateDebut,
      'date_fin': dateFin,
      'intervenants': intervenants,
      'libelle_construit': libelleConstruit,
    };
  }
}
