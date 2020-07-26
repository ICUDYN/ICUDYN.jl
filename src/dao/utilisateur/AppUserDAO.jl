data_type = AppUser
PostgresqlDAO.getdao(x::AppUser) = return(AppUserDAO)
gettablename() = "utilisateur.appuser"
# The format of the mapping is: `property name = "column name"`
const columns_selection_and_mapping = Dict(:id => "id",
                                           :login => "login",
                                           :password => "password",
                                           :lastname => "lastname",
                                           :firstname => "firstname",
                                           :email => "email",
                                           :languageCode => "language_code",
                                           :appuserType => "appuser_type",
                                           :avatar => "avatar_id",
                                           :preferences => "preferences",
                                           :creator => "creator_id",
                                           :lastEditor => "last_editor_id",
                                           :creationTime => "creation_time",
                                           :updateTime => "update_time")

const id_property = :id

const onetomany_counterparts =
    Dict(:composedRolesAssos => (data_type = AppUserRoleAsso,
                                  property = :appuser,
                                  action_on_remove = CRUDType.delete))

# A dictionnary of mapping between fields symbols and overriding types
#   Left hanside is the field symbol ; right hand side is the type override
const types_override = Dict(:avatar => Model.File,
                            :composedRolesAssos => Vector{Model.AppUserRoleAsso},
                            :allRoles => Vector{Model.Role},
                            :creator => Model.AppUser,
                            :lastEditor => Model.AppUser)

const track_changes = true
const creator_property = :creator
const editor_property = :lastEditor
const creation_time_property = :creationTime
const update_time_property = :updateTime
