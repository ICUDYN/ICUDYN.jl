data_type = RoleRoleAsso
PostgresqlDAO.getdao(x::RoleRoleAsso) = return(RoleRoleAssoDAO)
gettablename() = "usersch.role_role_asso"
# The format of the mapping is: `property name = "column name"`
const columns_selection_and_mapping = Dict(:id => "id",
                                           :handledRole => "handled_role_id",
                                           :handlerRole => "handler_role_id",
                                           # Properties for tracking changes
                                           :creator => "creator_id",
                                           :lastEditor => "last_editor_id",
                                           :creationTime => "creation_time",
                                           :updateTime => "update_time")

const id_property = :id

# A dictionnary of mapping between fields symbols and overriding types
#   Left hanside is the field symbol ; right hand side is the type override
# A dictionnary of mapping between fields symbols and overriding types
#   Left hanside is the field symbol ; right hand side is the type override
const types_override = Dict(:handledRole => Model.Role,
                            :handlerRole => Model.Role,
                            :creator => Model.AppUser,
                            :lastEditor => Model.AppUser)

const track_changes = true

const creator_property = :creator
const editor_property = :lastEditor
const creation_time_property = :creationTime
const update_time_property = :updateTime
