data_type = Role
PostgresqlDAO.getdao(x::Role) = return(RoleDAO)
gettablename() = "usersch.role"
# The format of the mapping is: `property name = "column name"`
const columns_selection_and_mapping = Dict(:id => "id",
                                           :codeName => "code_name",
                                           :name_en => "name_en",
                                           :name_fr => "name_fr",
                                           :composed => "composed",
                                           :restrictedToAppUserType =>
                                                "restricted_to_appuser_type",
                                           # Properties for tracking changes
                                           :creator => "creator_id",
                                           :lastEditor => "last_editor_id",
                                           :creationTime => "creation_time",
                                           :updateTime => "update_time")

const id_property = :id

const onetomany_counterparts =
    Dict(:roleRoleAssos_as_handler => (data_type = RoleRoleAsso,
                                         property = :handlerRole,
                                         action_on_remove = CRUDType.delete),
         :roleRoleAssosAsHandled => (data_type = RoleRoleAsso,
                                         property = :handledRole,
                                         action_on_remove = CRUDType.delete))

# A dictionnary of mapping between fields symbols and overriding types
#   Left hanside is the field symbol ; right hand side is the type override
const types_override = Dict()

const track_changes = true

const creator_property = :creator
const editor_property = :lastEditor
const creation_time_property = :creationTime
const update_time_property = :updateTime
