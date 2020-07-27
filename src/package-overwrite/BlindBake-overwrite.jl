using LibPQ, Dates, BlindBake

function BlindBake.invokeMethod(_function::Function, args::Vector, procID::Int64)

    argsTypesForPrinting = join(string.(typeof.(args)),", ")
    @info "Invoke $(_function)($argsTypesForPrinting) on procID[$procID]"

    dbconn::Union{Missing,LibPQ.Connection} = missing
    for arg in args
        if isa(arg,LibPQ.Connection)
            dbconn = arg
        end
    end

    try
        future = @spawnat procID _function(args...)
        fetch(future)
    catch e
        error(e)
    finally
        if !ismissing(dbconn)
            close(dbconn)
        end
    end

end

function BlindBake.createDefaultObject(::Type{Dates.Date})
    return Dates.Date("2019-09-01")
end

function BlindBake.createDefaultObject(::Type{TimeZones.ZonedDateTime})
    return ZonedDateTime(now(),ICUDYNUtil.getTimeZone())
end

function BlindBake.createDefaultObject(::Type{LibPQ.Connection})
    return ICUDYNUtil.openDBConnAndBeginTransaction()
end


using PostgresqlDAO
function BlindBake.createDefaultObject(::Type{T}) where T<:PostgresqlDAO.Model.IEntity
    return T(id = string(UUIDs.uuid4()))
end
