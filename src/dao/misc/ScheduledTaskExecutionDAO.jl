data_type = ScheduledTaskExecution
PostgresqlDAO.getdao(x::ScheduledTaskExecution) = return(ScheduledTaskExecutionDAO)
gettablename() = "misc.scheduled_task_execution"
# The format of the mapping is: `property name = "column name"`
const columns_selection_and_mapping = Dict(:id => "id",
                                           :name => "name",
                                           :startTime => "start_time")

const id_property = :id

const onetomany_counterparts = Dict()

# A dictionnary of mapping between fields symbols and overriding types
#   Left hanside is the field symbol ; right hand side is the type override
const types_override = Dict()

const track_changes = false
