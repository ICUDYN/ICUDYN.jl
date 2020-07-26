@everywhere using EzXML, DataFrames, Serialization, TimeZones, Dates
@everywhere using PostgresqlDAO.PostgresqlDAOUtil
@everywhere using Icudyn
@everywhere using OQS.OQSUtil
@everywhere using OQS.Model
@everywhere using OQS.Enums
@everywhere using OQS.DAO
@everywhere using OQS.Controller
@everywhere using OQS.Controller.ETL
@everywhere using OQS.Controller.Qualite
@everywhere using OQS.Controller.Utilisateur
@everywhere using OQS.Controller.Scheduler
# Declare all the enums types modules specifically so that they are available
#   to /enum/posible-values/:enumType (see enum-api.jl)
@everywhere using OQS.Enums.AppUserType, OQS.Enums.RoleCodeName,
                  OQS.Enums.TypeCourse, OQS.Enums.JourSemaine
@everywhere using BlindBake
