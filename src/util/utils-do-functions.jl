function ICUDYNUtil.createSrcDBConnAndExecute(fct::Function,args...; kwargs...)

    dbconn = ICUDYNUtil.openSrcDBConn()
    try
        fct(args...,dbconn; kwargs...)
    catch e
        rethrow(e)
    finally
        ICUDYNUtil.closeDBConn(dbconn)
    end
end

function ICUDYNUtil.createDBConnAndExecute(fct::Function,args...; kwargs...)

    dbconn = ICUDYNUtil.openDBConn()
    try
        fct(args...,dbconn; kwargs...)
    catch e
        rethrow(e)
    finally
        ICUDYNUtil.closeDBConn(dbconn)
    end
end

function ICUDYNUtil.createDBConnAndExecuteWithTransaction(fct::Function,args...; kwargs...)

    dbconn = ICUDYNUtil.openDBConnAndBeginTransaction()
    try
        result = fct(args...,dbconn; kwargs...)
        ICUDYNUtil.commitDBTransaction(dbconn)
        return result
    catch e
        ICUDYNUtil.rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        ICUDYNUtil.closeDBConn(dbconn)
    end
end

# https://richardanaya.medium.com/how-to-create-a-multi-threaded-http-server-in-julia-ca12dca09c35
function ICUDYNUtil.executeOnWorkerTwoOrHigher(fct::Function,args...;kwargs...)

    # Get a worker greater than worker 1
    _procid = if nprocs() > 1
        rand(2:nprocs())
    else
        1
    end

    # res = with_logger(Medilegist.to_file_and_console_logger) do
        res = fetch(@spawnat _procid begin
                fct(args...;kwargs...)
            end)
        # return res
    # end

    # res = fetch(@spawnat _procid do
    #     # with_logger(Medilegist.to_file_and_console_logger) do
    #         fct(args...;kwargs...)
    #     # end
    # end)

    if res isa RemoteException
        throw(res)
    end

    return res
end
