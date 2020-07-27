using Dates
using OQS.Enums
using ..Enums.AppUserType, ..Enums.RoleCodeName, ..Enums.JourSemaine

# On ajoute des régulations d'intervalles qui se superposent
persist!(RegulationIntervalle(
      noLigne = 1,
      tagMnemo = "lundi au vendredi",
      dateDebut = Date("2019-09-01"),
      dateFin = Date("2019-12-31"),
      jourSemaine = JourSemaine.lundi,
      heureDebut = Time("09:00"),
      heureFin = Time("18:30"),
      intervalle = 300, # 5 minutes
))
persist!(RegulationIntervalle(
       noLigne = 1,
       tagMnemo = "lundi au vendredi",
       dateDebut = Date("2019-09-01"),
       dateFin = Date("2019-12-31"),
       jourSemaine = JourSemaine.mardi,
       heureDebut = Time("09:00"),
       heureFin = Time("18:30"),
       intervalle = 300, # 5 minutes
))
persist!(RegulationIntervalle(
       noLigne = 1,
       tagMnemo = "lundi au vendredi",
       dateDebut = Date("2019-09-01"),
       dateFin = Date("2019-12-31"),
       jourSemaine = JourSemaine.mercredi,
       heureDebut = Time("09:00"),
       heureFin = Time("18:30"),
       intervalle = 300, # 5 minutes
 ))
persist!(RegulationIntervalle(
  noLigne = 1,
  tagMnemo = "lundi au vendredi",
  dateDebut = Date("2019-09-01"),
  dateFin = Date("2019-12-31"),
  jourSemaine = JourSemaine.jeudi,
  heureDebut = Time("09:00"),
  heureFin = Time("18:30"),
  intervalle = 300, # 5 minutes
))
persist!(RegulationIntervalle(
   noLigne = 1,
   tagMnemo = "lundi au vendredi",
   dateDebut = Date("2019-09-01"),
   dateFin = Date("2019-12-31"),
   jourSemaine = JourSemaine.vendredi,
   heureDebut = Time("09:00"),
   heureFin = Time("18:30"),
   intervalle = 300, # 5 minutes
))

#
# Ligne 2
#
persist!(RegulationIntervalle(
      noLigne = 2,
      tagMnemo = "lundi au vendredi",
      dateDebut = Date("2019-09-01"),
      dateFin = Date("2019-12-31"),
      jourSemaine = JourSemaine.lundi,
      heureDebut = Time("09:00"),
      heureFin = Time("18:30"),
      intervalle = 300, # 5 minutes
))
persist!(RegulationIntervalle(
       noLigne = 2,
       tagMnemo = "lundi au vendredi",
       dateDebut = Date("2019-09-01"),
       dateFin = Date("2019-12-31"),
       jourSemaine = JourSemaine.mardi,
       heureDebut = Time("09:00"),
       heureFin = Time("18:30"),
       intervalle = 300, # 5 minutes
))
persist!(RegulationIntervalle(
       noLigne = 2,
       tagMnemo = "lundi au vendredi",
       dateDebut = Date("2019-09-01"),
       dateFin = Date("2019-12-31"),
       jourSemaine = JourSemaine.mercredi,
       heureDebut = Time("09:00"),
       heureFin = Time("18:30"),
       intervalle = 300, # 5 minutes
 ))
persist!(RegulationIntervalle(
  noLigne = 2,
  tagMnemo = "lundi au vendredi",
  dateDebut = Date("2019-09-01"),
  dateFin = Date("2019-12-31"),
  jourSemaine = JourSemaine.jeudi,
  heureDebut = Time("09:00"),
  heureFin = Time("18:30"),
  intervalle = 300, # 5 minutes
))
persist!(RegulationIntervalle(
   noLigne = 2,
   tagMnemo = "lundi au vendredi",
   dateDebut = Date("2019-09-01"),
   dateFin = Date("2019-12-31"),
   jourSemaine = JourSemaine.vendredi,
   heureDebut = Time("09:00"),
   heureFin = Time("18:30"),
   intervalle = 300, # 5 minutes
))
