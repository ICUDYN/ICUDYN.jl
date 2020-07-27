using Dates
using OQS.Enums
using ..Enums.AppUserType, ..Enums.RoleCodeName, ..Enums.JourSemaine

# Détection des courses trop en retard
anomalieDefRetard =
      AnomalieDef(nom = "retard",
                  seuil = 180.0,
                  seuilCritique = 360.0,
                  nomFonction = "calculerLesRetards",
                  applicableDateDebut = Date("1970-01-01"),
                  applicableDateFin = Date("2050-01-01"))
persist!(anomalieDefRetard)

# Détection des courses trop en avance
anomalieDefAvance =
      AnomalieDef(nom = "avance",
                  seuil = 60.0,
                  seuilCritique = 180.0,
                  nomFonction = "calculerLesAvances",
                  applicableDateDebut = Date("1970-01-01"),
                  applicableDateFin = Date("2050-01-01"))
persist!(anomalieDefAvance)

# Détection des courses pour lesquels l'arrêt au terminus d'arrivée n'a pas été
#  marqué
anomalieDefAbsenceArretTerminusArrivee =
      AnomalieDef(nom = "absence_terminus_arrivee",
                  nomFonction = missing, # cf calculerLesAbsencesAuxArret
                  applicableDateDebut = Date("1970-01-01"),
                  applicableDateFin = Date("2050-01-01"))
persist!(anomalieDefAbsenceArretTerminusArrivee)

anomalieDefAbsenceArretTerminusDepart =
      AnomalieDef(nom = "absence_terminus_depart",
                  nomFonction = missing, # cf calculerLesAbsencesAuxArret
                  applicableDateDebut = Date("1970-01-01"),
                  applicableDateFin = Date("2050-01-01"))
persist!(anomalieDefAbsenceArretTerminusDepart)

calculerAbsenceTotaleArret =
      AnomalieDef(nom = "aucun_arret",
                  nomFonction = missing, # cf calculerLesAbsencesAuxArret
                  applicableDateDebut = Date("1970-01-01"),
                  applicableDateFin = Date("2050-01-01"))
persist!(calculerAbsenceTotaleArret)

# Détection des arrêts des courses à intervalles avec un intervalle trop éloigné
#  de l'intervalle cible
anomalieDefManquesDeRegularite =
      AnomalieDef(nom = "manque_de_regularite",
                  seuil = 60.0,
                  seuilCritique = 180.0,
                  nomFonction = "calculerLesManquesDeRegularite",
                  applicableDateDebut = Date("1970-01-01"),
                  applicableDateFin = Date("2050-01-01"))
persist!(anomalieDefManquesDeRegularite)
