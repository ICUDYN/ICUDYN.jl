mutable struct ScheduledTaskExecution <: IScheduledTaskExecution

    id::Union{Missing,String}
    name::Union{Missing,String}
    startTime::Union{Missing,ZonedDateTime}

    # Convenience constructor that allows us to create a vector of instances
    #   from a JuliaDB.table using the dot syntax: `Myclass.(a_JuliaDB_table)`
    ScheduledTaskExecution(args::NamedTuple) = ScheduledTaskExecution(;args...)
    ScheduledTaskExecution(;id = missing,
                            name = missing,
                            startTime = missing) = (
                x = new(missing, missing, missing);
                x.id = id;
                x.name = name;
                x.startTime = startTime;
                return x)
end
