data_type = File
PostgresqlDAO.getdao(x::File) = return(FileDAO)
gettablename() = "misc.file"
# The format of the mapping is: `property name = "column name"`
const columns_selection_and_mapping = Dict(:id => "id",
                                           :name => "name",
                                           :pathFromDataDir => "path_from_datadir",
                                           :cancelled => "cancelled",
                                           :creator => "creator_id",
                                           :lastEditor => "last_editor_id",
                                           :creationTime => "creation_time",
                                           :updateTime => "update_time",
                                           :causeAnomalie => "cause_anomalie_id"
                                           )

const id_property = :id

# A dictionnary of mapping between fields symbols and overriding types
#   Left hanside is the field symbol ; right hand side is the type override
const types_override = Dict(:causeAnomalie => Model.CauseAnomalie,
                            :creator => Model.AppUser,
                            :lastEditor => Model.AppUser)
const track_changes = true
const creator_property = :creator
const editor_property = :lastEditor
const creation_time_property = :creationTime
const update_time_property = :updateTime
