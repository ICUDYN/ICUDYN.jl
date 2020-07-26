data_type = FrontendVersion
PostgresqlDAO.getdao(x::FrontendVersion) = return(FrontendVersionDAO)
gettablename() = "misc.frontend_version"
# The format of the mapping is: `property name = "column name"`
const columns_selection_and_mapping = Dict(:id => "id",
                                           :name => "name",
                                           :forceReloadIfDifferentVersion => "force_reload_if_different_version")

const id_property = :id

const onetomany_counterparts = Dict()

# A dictionnary of mapping between fields symbols and overriding types
#   Left hanside is the field symbol ; right hand side is the type override
const types_override = Dict()

const track_changes = false
