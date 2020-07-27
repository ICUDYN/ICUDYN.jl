data_type = AppUserRoleAsso
PostgresqlDAO.getdao(x::AppUserRoleAsso) = return(AppUserRoleAssoDAO)
gettablename() = "usersch.appuser_role_asso"
# The format of the mapping is: `property name = "column name"`
const columns_selection_and_mapping = Dict(:id => "id",
                                           :appuser => "appuser_id",
                                           :role => "role_id",
                                           # The rest of the properties are for tracking changes
                                           :creator => "creator_id",
                                           :lastEditor => "last_editor_id",
                                           :creationTime => "creation_time",
                                           :updateTime => "update_time")

const id_property = :id # A Vector of the properties corresponding to ids

# A dictionnary of mapping between fields symbols and overriding types
#   Left hanside is the field symbol ; right hand side is the type override
const types_override = Dict(:appuser => Model.AppUser,
                            :role => Model.Role,
                            # The rest of the properties are for tracking changes
                            :creator => Model.AppUser,
                            :lastEditor => Model.AppUser)

const track_changes = true
const creator_property = :creator
const editor_property = :lastEditor
const creation_time_property = :creationTime
const update_time_property = :updateTime
