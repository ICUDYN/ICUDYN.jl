data_type = PeriodeTopo
PostgresqlDAO.getdao(x::PeriodeTopo) = return(PeriodeTopoDAO)
gettablename() = "misc.periode_topo"
const columns_selection_and_mapping =
  Dict(
     :dateDebut => "date_debut",
    :dateFin => "date_fin",
    :noTopo => "no_topo",
    :id => "id",
    :creationTime => "creation_time",
    :updateTime => "update_time",
    :lastEditor => "last_editor_id",
    :creator => "creator_id"
  )

  const id_property = :id

  const onetomany_counterparts = Dict()

  # A dictionnary of mapping between fields symbols and overriding types
  #   Left hanside is the field symbol ; right hand side is the type override
  const types_override = Dict(:creator => Model.AppUser,
                              :lastEditor => Model.AppUser)

  const track_changes = true
  const creator_property = :creator
  const editor_property = :lastEditor
  const creation_time_property = :creationTime
  const update_time_property = :updateTime
