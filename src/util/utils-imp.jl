# For handling whitespaces in INI files
include("../package-overwrite/ConfParser-overwrite.jl")

# No choice...calling 'using' with in the module block does not work
using Dates, Base.StackTraces, TimeZones, ICUDYN, ICUDYN.ICUDYNUtil, LibPQ, InfoZIP,
      DataFrames, XLSX, Decimals
using PostgresqlDAO.PostgresqlDAOUtil, PostgresqlDAO.Controller
using Dates, TimeZones, Distributed, CSV, DataFrames, InfoZIP, Query, TimeZones
using PostgresqlDAO, PostgresqlDAO.Controller, PostgresqlDAO.PostgresqlDAOUtil,
      PostgresqlDAO.Model.Enums.CRUDType, LibPQ
using ..Model, ..ICUDYNUtil, ..Controller, ..ICUDYN, ..Enums
using ICUDYN.Enums.AppUserType, ICUDYN.Enums.RoleCodeName, ICUDYN.Model, ICUDYN

# see ~/.julia/config/startup.jl for setting the environment variable
function ICUDYNUtil.loadConf()::ConfParse

    environment_variable_name = "ICUDYN_CONFIGURATION_FILE"

    if haskey(ENV,environment_variable_name)
        @info "loading configuration file[$(ENV[environment_variable_name])]"
        conf_file = ENV[environment_variable_name]
    else
        throw(DomainError("The application requires the environment"
                          * " variable[$environment_variable_name] to be set."))
    end

    conf = ConfParse(conf_file)
    parse_conf!(conf)
    return(conf)

end

function ICUDYNUtil.getConf(category_name::String,property_name::String)
    ConfParser.retrieve(ICUDYN.config,
                        category_name,
                        property_name)
end

function ICUDYNUtil.getDataDir()
    getConf("default","data_dir")
end

function ICUDYNUtil.getMissingFilePath()
    return "asset/missing-file.jpg"
end

function ICUDYNUtil.blindBakeIsRequired()
    return parse(Bool,getConf("default","blind_bake"))
end

function ICUDYNUtil.getETLAIntegrerDir()
    getConf("etl","a_integrer")
end

function ICUDYNUtil.getETLDejaIntegreDir()
    getConf("etl","deja_integre")
end

function ICUDYNUtil.getETLDejaIntegreDir(nomSousDossier)
    dirPath = joinpath(ICUDYNUtil.getETLDejaIntegreDir(),nomSousDossier)
    if !ispath(dirPath)
        mkdir(dirPath)
    end
    return dirPath
end


function ICUDYNUtil.getETLMaxSizeBeforeDBCommit()
    parse(Int,getConf("etl","max_size_before_db_commit"))
end


function ICUDYNUtil.getETLTnterruptionFilepath()
    joinpath(getConf("default","data_dir"),
             getConf("etl","interruption_filename"))
end

function ICUDYNUtil.getTimeZone()
    # TimeZones.TimeZone(getConf("default","timezone"))
    TimeZones.TimeZone("Europe/Paris")
end

function ICUDYNUtil.openDBConn()
    database = getConf("database","database")
    user = getConf("database","user")
    host = getConf("database","host")
    port = getConf("database","port")
    password = getConf("database","password")

    conn = LibPQ.Connection("host=$(host)
                             port=$(port)
                             dbname=$(database)
                             user=$(user)
                             password=$(password)
                             "; throw_error=true)
    # We want Postgresql planner to optimize the query over the partitions
    # https://www.postgresql.org/docs/12/ddl-partitioning.html#DDL-PARTITION-PRUNING
    # The property is set for the SESSION
    execute(conn, "SET enable_partition_pruning = on;")
    execute(conn, "SET TIMEZONE='Europe/Paris';")

    return conn
end

function ICUDYNUtil.openDBConnAndBeginTransaction()
    conn = ICUDYNUtil.openDBConn()
    ICUDYNUtil.beginDBTransaction(conn)
    return conn
end

function ICUDYNUtil.beginDBTransaction(conn)
    execute(conn, "BEGIN;")
end

function ICUDYNUtil.commitDBTransaction(conn)
    execute(conn, "COMMIT;")
end

function ICUDYNUtil.rollbackDBTransaction(conn)
    execute(conn, "ROLLBACK;")
end

function ICUDYNUtil.closeDBConn(conn)
    close(conn)
end


function ICUDYNUtil.json2Entity(datatype::DataType,
                     dict::Dict{String,Any})
    dict = dictstringkeys2symbol(dict)
    dict = dictnothingvalues2missing(dict)
    util_dict2entity(dict,
                     datatype,
                     false, # building_from_database_result::Bool,
                     false, # retrieve_complex_props::Bool,
                     missing #dbconn::Union{LibPQ.Connection,Missing}
                     )
end


function ICUDYNUtil.initialize_http_response_status_code(req)
    # The status code is by default 200 and we look if a filter wants
    #   to overwrite it
    status_code = 200
    if (haskey(req,:params)
        && haskey(req[:params],:status))
         status_code = req[:params][:status]
     end
     return status_code
end

function ICUDYNUtil.sendemail(recipients::Vector{String},subject::String,message::String)

    unique!(recipients)

    # Exit if recipients is empty
    if length(recipients) == 0
        return
    end

    if parse(Bool,getConf("email","noemail")) == true
        @info "Do not send email because 'noemail' is set to true in the configuration."
        return
    end

    userid=getConf("email","userid")
    fromaddress=userid
    userpwd=getConf("email","userpwd")
    smtpserver=getConf("email","smtpserver")

    sendemailcmd = `sendemail -l email.log
        -f $fromaddress
        -u $subject
        -t $(join(recipients,","))
        -s $smtpserver
        -o tls=yes
        -o message-content-type=html
        -xu $userid
        -xp $userpwd
        -m $message`

    # We don't want to wait for the email to be sent
    # The try-catch block is not really needed because the @async block already
    #  has the side effect of not making the database transation fail
    @async begin
        try
            run(sendemailcmd);
        catch e
            formatExceptionAndStackTrace(e,
                                         stacktrace(catch_backtrace()))
        end
    end

end

"""
Supported data types are Union{Missing, Bool, Float64, Int64, Date, DateTime,
  Time, String} or XLSX.CellValue."
"""
function ICUDYNUtil.prepareDataFrameForExcel!(df::DataFrame)

    for col in names(df)
      type = PostgresqlDAOUtil.get_nonmissing_typeof_uniontype(eltype(df[col]))
      if !(type in [Missing, Bool, Float64, Int64, Date, DateTime, Time, String])
          if (type <: Integer && type != Int64)
              df[col] = convert(Vector{Union{Missing, Int64}}, df[col])
          elseif type <: Decimals.Decimal
              df[col] = convert(Vector{Union{Missing, Float64}}, df[col])
          elseif (type <: AbstractFloat && type != Float64)
              df[col] = convert(Vector{Union{Missing, Float64}}, df[col])
          end
      end
    end

end

function ICUDYNUtil.exportToExcel(data::Any)

    ICUDYNUtil.prepareDataFrameForExcel!(data)

    filepath = tempname()

    XLSX.openxlsx(filepath, mode="w") do xf
       sheet = xf[1]
       XLSX.writetable!(sheet,
                        collect(DataFrames.eachcol(data)),
                        string.(names(data)),
                        anchor_cell=XLSX.CellRef("A1"))
    end

    return filepath
end

using TickTock
function ICUDYNUtil.exportToExcel(sheetNamesAndDataFrames::Dict{String,DataFrame}
                              ;filepath = tempname())
    # filepath = tempname()

    tick()

    XLSX.openxlsx(filepath, mode="w") do xf

       counter = 0
       for (sheetName, df) in sheetNamesAndDataFrames


           ICUDYNUtil.prepareDataFrameForExcel!(df)

           @info "Elapsed time after prepareDataFrameForExcel[$(peektimer())]"

           counter += 1
           sheet::Union{XLSX.Worksheet, Missing} = missing
           if counter == 1
               sheet = xf[1]
               XLSX.rename!(sheet, sheetName)
           else
               sheet = XLSX.addsheet!(xf, sheetName)
           end

           @info "Elapsed time before writetable[$(peektimer())]"

           XLSX.writetable!(sheet,
                            collect(DataFrames.eachcol(df)),
                            string.(names(df)),
                            anchor_cell=XLSX.CellRef("A1"))
           @info "Elapsed time after writetable[$(peektimer())]"
       end
    end

    tock()

    return filepath
end

function ICUDYNUtil.formatDate(dt::Missing)
    return missing
end

function ICUDYNUtil.formatDateTime(dt::Missing)
    return missing;
end

function ICUDYNUtil.formatDate(dt::Dates.TimeType)
    Dates.format(dt, "yyyy-mm-dd")
end

function ICUDYNUtil.formatDateTime(dt::Dates.TimeType)
    Dates.format(dt, "yyyy-mm-dd HH:MM:SS")
end

function ICUDYNUtil.formatExceptionAndStackTrace(ex::Exception,
                          stackTrace::StackTrace
                          ;maxLines = 20,
                           stopAt = "(::getfield(Mux")
    message = ICUDYNUtil.formatExceptionAndStackTraceCore(ex,
                              stackTrace
                              ;maxLines = maxLines,
                               stopAt = stopAt)
    @error message
end

function ICUDYNUtil.formatExceptionAndStackTraceCore(ex::Exception,
                          stackTrace::StackTrace
                          ;maxLines = 20,
                           stopAt = "(::getfield(Mux")
    # @info length(stackTrace)
    message = string(ex)
    counter = 0
    for stackFrame in stackTrace
        counter += 1
        if counter > maxLines
            break
        end
        stackFrameAsStr = string(stackFrame)
        if occursin(stopAt,stackFrameAsStr)
            break
        end
        message *= "\n" * string(stackFrame)
    end
    message
end

function ICUDYNUtil.setToMissing(str::String)
    return missing
end


function ICUDYNUtil.convertStringToBool(str::String)
    firstChar = lowercase(str[1])
    if firstChar in ['y','t','o']
        return true
    elseif firstChar in ['n','f']
        return false
    else
        error("Unable to convert $str to Bool")
    end
end

function ICUDYNUtil.convertStringToDate(str::String)

    # yyyy-mm-dd
    formatString = "yyyy-mm-dd" # This is actually the default
    dateMatch = match(r"^([0-9]{4}-[0-9]{2}-[0-9]{2})", str)
    # dd/mm/yyyy
    if isnothing(dateMatch)
        formatString = "dd/mm/yyyy"
        dateMatch = match(r"^([0-9]{2}/[0-9]{2}/[0-9]{4})", str)
    end
    Date(dateMatch.match,formatString)
end

function ICUDYNUtil.convertStringOfTimeWithHoursPassed24HoursTo1970DateTime(str::String)

    dateMatch = match(r"^([0-9]{2}:[0-9]{2}:[0-9]{2})", str)
    if isnothing(dateMatch)
        throw("String[$str] does not match time pattern HH:MM:SS")
    end
    baseDateTime = DateTime("1970-01-01T00:00:00")

    hoursMinsSecs = parse.(Int8,string.(split(str,':')))
    if hoursMinsSecs[1] >= 24
            baseDateTime += Dates.Day(1)
            hoursMinsSecs[1] = hoursMinsSecs[1] - 24
    end
    baseDateTime += Dates.Hour(hoursMinsSecs[1])
    baseDateTime += Dates.Minute(hoursMinsSecs[2])
    baseDateTime += Dates.Second(hoursMinsSecs[3])

end

function ICUDYNUtil.convertStringOfTimeToSeconds(str::String)

    # Matches HH:MM:SS or -HH:MM:SS
    dateMatch = match(r"^(\-?[0-9]{2}:[0-9]{2}:[0-9]{2})", str)
    if isnothing(dateMatch)
        throw("String[$str] does not match time pattern HH:MM:SS")
    end
    hoursMinsSecs = string.(split(str,':'))
    multiplier = 1
    if first(hoursMinsSecs[1]) == '-'
        multiplier = -1
        hoursMinsSecs[1] = replace(hoursMinsSecs[1],"-" => "")
    end
    hoursMinsSecs = parse.(Int8,string.(split(str,':')))
    result = hoursMinsSecs[1] * 3600 + hoursMinsSecs[2] * 60 + hoursMinsSecs[3]
    result = result * multiplier
    return result
end

function ICUDYNUtil.convertStringToDateTime(str::String)
    # yyyy-mm-ddTHH:MM:SS
    formatString = "yyyy-mm-ddTHH:MM:SS" # This is actually the default
    dateMatch = match(r"^([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2})", str)
    # yyyy-mm-dd HH:MM:SS
    if isnothing(dateMatch)
        formatString = "yyyy-mm-dd HH:MM:SS"
        dateMatch = match(r"^([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2})", str)
    end
    # dd/mm/yyyy HH:MM:SS
    if isnothing(dateMatch)
        formatString = "dd/mm/yyyy HH:MM:SS"
        dateMatch = match(r"^([0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2})", str)
    end
    DateTime(dateMatch.match,formatString)
end

# eg. "1970-01-01T12:35:00+01:00"
function ICUDYNUtil.convertStringToZonedDateTime(str::String)

    # yyyy-mm-dd ....
    dateMatch = match(r"^([0-9]{4}-[0-9]{2}-[0-9]{2})", str)
    if !isnothing(dateMatch)
        formatString = "yyyy-mm-ddTHH:MM:SSzzz"
        return ZonedDateTime(str, formatString)
    end

    # dd/mm/yyyy....
    dateMatch = match(r"^([0-9]{2}/[0-9]{2}/[0-9]{4})", str)
    if !isnothing(dateMatch)
        formatString = "dd/mm/yyyy HH:MM:SS"
        return ZonedDateTime(ICUDYNUtil.convertStringToDateTime(str),
                             ICUDYNUtil.getTimeZone())
    end

end


"""
Create a zip file from a vector of file paths
"""
function ICUDYNUtil.createZip(filesPaths::Vector{String})::Vector{UInt8}
    return InfoZIP.create_zip(filesPaths)
end

# Returns the path of the temp directory containing the unziped files
function ICUDYNUtil.unzipFileInTempDir(zipFilePath)
    tempDir = mktempdir(ICUDYNUtil.getICUDYNTempDir())
    InfoZIP.unzip(zipFilePath, tempDir)
    tempDir
end

function ICUDYNUtil.readdirWithFullpath(dir)
    joinpath.(abspath(dir), readdir(dir))
end

function ICUDYNUtil.extension(url::Any)
   result = try
           match(r"\.[A-Za-z0-9]+$", url).match
       catch e
           ""
       end
   result
end

function ICUDYNUtil.hasRole(roleCodeName::ROLE_CODE_NAME,appuser::AppUser)
    ICUDYNUtil.hasRole(appuser,roleCodeName)
end

function ICUDYNUtil.hasRole(appuser::AppUser,roleCodeName::ROLE_CODE_NAME)
    if any(x -> (x.codeName == roleCodeName), appuser.allRoles)
        return true
    else
        return false
    end
end

function ICUDYNUtil.diffInSecondsAsInt(before::ZonedDateTime, after::ZonedDateTime)
    timediff = after - before
    convert(Int64,timediff / Millisecond(1000))
end

function ICUDYNUtil.nowInCurrentTimeZone()
    TimeZones.ZonedDateTime(Dates.now(),
                            getTimeZone())
end

function ICUDYNUtil.nowInUTC()
    return now(Dates.UTC)
end

# TODO: We should manage to specify that the datatype is an Enum
function ICUDYNUtil.listEnums(enumType::DataType
                          ;appuser::Model.AppUser)

    tupleOfEnums = instances(enumType)

    return [tupleOfEnums...]
end

function ICUDYNUtil.addTimeToZonedDateTime(zdt::ZonedDateTime, time::Time)
    return zdt + Hour(time) + Minute(time) + Second(time)
end


function ICUDYNUtil.addTimeToDate(date::Date, time::Time)
    zdt = ZonedDateTime(DateTime(date),getTimeZone())
    return addTimeToZonedDateTime(zdt, time)
end

function ICUDYNUtil.getDateOfZonedDateTime(zdt::ZonedDateTime)
    Date(Dates.year(zdt),
        Dates.month(zdt),
        Dates.dayofmonth(zdt))
end

function ICUDYNUtil.agregerEnStringJSON(df::DataFrame, groupCol::Symbol)
    dfAsVectorOfNamedTuples = dataframe2vector_of_namedtuples(df)
    dict = Dict{Any,Vector{Any}}() # Important d'autoriser n'importe quel type de tuple
                                   #   car il peut y avoir des valeurs vides
    for row in dfAsVectorOfNamedTuples
        key = getproperty(row,groupCol)
        if !haskey(dict,key)
            dict[key] = [row]
        else
            push!(dict[key], row)
        end
    end
    df = DataFrame()
    df[groupCol] = collect(keys(dict))
    df[:json] = JSON.json.(collect(values(dict)))
    df
end

function ICUDYNUtil.openDBConnectionAndExecuteQuery(queryString::String,
                                                 queryArgs::Vector)


    # Execute the query
    dbconn = openDBConnAndBeginTransaction()
    queryResult = try
         queryResult =
            execute_plain_query(queryString,
                                queryArgs, # queryArgs
                                dbconn)
         commitDBTransaction(dbconn)
         queryResult
    catch e
        rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end

    queryResult

end

# Credit https://discourse.julialang.org/t/concatenate-dataframe-columns-dynamically/29106/5
function ICUDYNUtil.
            fusionColumnsInNewColum!(df::DataFrame, newColumnName::Symbol,
                                     cols_to_concat::Vector, separator::String)
	t = string.(df[!, cols_to_concat[1]])
	for col in cols_to_concat[2:end]
		t = t .* separator .* string.(df[!, col])
	end
	df[!, newColumnName] = t
	return df
end


function ICUDYNUtil.addPrefixToColNames!(df::DataFrame,
                                      prefix::String
                                     ;exclude::Union{Symbol,Vector{Symbol}} = [])
    # Handle the case where the exclude argument is not a vector
    if isa(exclude, Symbol)
        exclude = [exclude]
    end

    for n in names(df)
        if !(n in exclude)
            rename!(df, n => Symbol(string(prefix,n)))
        end
    end

end


function ICUDYNUtil.getFileFullPath(file::File)
    fullPath = joinpath(getDataDir(),file.pathFromDataDir)
    return fullPath
end


function ICUDYNUtil.getICUDYNTempDir()
    dirPath = joinpath(ICUDYN.getDataDir(),"tmp")
    if !ispath(dirPath)
        mkdir(dirPath)
    end
    return dirPath
end

function ICUDYNUtil.getICUDYNTempFile()
      return joinpath(ICUDYNUtil.getICUDYNTempDir(), basename(tempname()))
end

function ICUDYNUtil.getICUDYNTempFile(prefix::String, extension::String)
    if !occursin(".", extension)
        extension = ".$extension"
    end
    return joinpath(ICUDYNUtil.getICUDYNTempDir(),
                    string(prefix,"-",basename(tempname()),extension))
end

function ICUDYNUtil.cancelFile!(file::File,appuser::AppUser)

    # Cancel the file
    file.cancelled = true
    Controller.update!(file;
                       editor = appuser)

end


function ICUDYNUtil.replaceMissingsBy0s!(df::DataFrame)

    #
    # Transforme le dataframe pour faciliter les tests et les calculs
    #
    # Remplace les missing des colonnes numériques par des 0
    # NOTE : - On ne peut pas utiliser directement map! (on ne sait pas pourquoi)
    #        - On aurait aussi pu boucler sur les noms de colonnes donnés par
    #             names(df)
    # namesBK = names(df) # map va nous faire perdre les colonnes
    # df = map(col ->  begin
    #         if get_nonmissing_typeof_uniontype(eltype(col)) <: Real
    #             x = collect(Missings.replace(col,0)) # Replace missings by 0s
    #         else
    #             col
    #         end
    #     end, eachcol(df)) |>
    #     DataFrame
    # # Renomme le dataframe
    # names!(df, namesBK)

    for colName in names(df)
        if get_nonmissing_typeof_uniontype(eltype(df[colName])) <: Real
            df[colName] = collect(Missings.replace(df[colName],0)) # Replace missings by 0s
        end
    end

end

function ICUDYNUtil.getTimeZone(journeeExploitation::Date)
    midi = DateTime(journeeExploitation) + Hour(12)
    ICUDYNUtil.getTimeZone(ZonedDateTime(midi,
                                      ICUDYNUtil.getTimeZone()))
end


function ICUDYNUtil.getTimeZone(zdt::ZonedDateTime)

      tzUTC = TimeZones.TimeZone("UTC")

      zdtUTC = ZonedDateTime(DateTime(TimeZones.year(zdt),
                                      TimeZones.month(zdt),
                                      TimeZones.day(zdt),
                                      TimeZones.hour(zdt)),
                             tzUTC)
      timediff = zdtUTC - zdt
      shiftInHours = convert(Int8,convert(Int64,timediff / Millisecond(1000))/3600)
      if (shiftInHours > 0) shiftInHours = "+$shiftInHours"
      end
      TimeZones.TimeZone("UTC$shiftInHours")

end

"""

    createAllTablesPartitionsIfNextYearIsClose()

Vérifie que les partitions de l'année qui vient existent
"""
function ICUDYNUtil.createAllTablesPartitionsIfNextYearIsClose()

    _today = today()
    inAFewDays = _today + Day(15)
    if year(_today) != year(inAFewDays)
        ICUDYNUtil.createAllTablesPartitions(year(inAFewDays),
                                          year(inAFewDays))
    end

end

function ICUDYNUtil.createAllTablesPartitions(startYear::Integer,
                                           endYear::Integer)

    tablesAsDF = ICUDYNUtil.getTablesPartitionnees()

    for row in eachrow(tablesAsDF)
        for year in startYear:endYear
            ICUDYNUtil.createTablePartition("$(row.table_schema).$(row.table_name)",
                                         year::Integer)
        end
    end

end

function ICUDYNUtil.createTablePartition(tableName::String,
                                      year::Integer)

  for month in 1:12
      ICUDYNUtil.createTablePartition(tableName,
                                   year,
                                   month)
  end

end

function ICUDYNUtil.createTablePartition(tableNameWithSchema::String,
                                      year::Integer,
                                      month::Integer)

    # Initialise le nom du schema et de la table comme si on avait pas donné
    #   le schéma
    schemaName = "public"
    tableName = tableNameWithSchema

    schemaNameAndTableName = split(tableNameWithSchema, '.')
    if length(schemaNameAndTableName) == 2
        schemaName = string(schemaNameAndTableName[1])
        tableName = string(schemaNameAndTableName[2])
    end

    partitionTable = ICUDYNUtil.getTablePartitionName(tableName,
                                                   year,
                                                   month)

    @info "Create table partition $schemaName.$partitionTable"

    # Vérifie que la partition n'existe pas déjà
    if ICUDYNUtil.tableOrPartitionExists(schemaName, partitionTable)
        @info "La partition $schemaName.$partitionTable existe déjà"
        return
    end

    # Définie les bornes de la partition
    startDate = Dates.Date(year,month,01)
    endDate = startDate + Month(1)
    queryArgs = []

    # @info "default vector persist!"
    dbconn = openDBConnAndBeginTransaction()

    result::Int64 = 0
    try
         queryString = "CREATE TABLE $schemaName.$partitionTable
                         PARTITION OF $tableNameWithSchema
                         FOR VALUES FROM ('$startDate') TO ('$endDate')"

         preparedQuery = LibPQ.prepare(dbconn,
                                       queryString)

         # Prepare the query aruments
         queryResult = execute(preparedQuery,
                                queryArgs
                               ;throw_error=true)


         # Return the number of rows inserted
         # result = LibPQ.num_affected_rows(queryResult)
         commitDBTransaction(dbconn)

    catch e
       rollbackDBTransaction(dbconn)
       formatExceptionAndStackTrace(e,
                                    stacktrace(catch_backtrace()))
       # rethrow(e) # On ne veut pas relancer d'exception parce que cette fonction
                    #   a peut-être été appelée dans une boucle et on ne veut pas
                    #   que les autres créations de partitions échouent
    finally
       closeDBConn(dbconn)
    end
end

"""
    vacuumAndReindexTablesPartitionnees(schema::String,
                                        tableName::String
                                        journeeExploitation::Date)

Opérations de maintenance sur la partition de la table correspondant à la
journée d'exploitation donnée
"""
function ICUDYNUtil.vacuumAndReindexTablesPartitionnees(schema::String,
                                                     tableName::String,
                                                     journeeExploitation::Date)


     partitionName = ICUDYNUtil.getTablePartitionName(tableName,
                                                   Dates.year(journeeExploitation),
                                                   Dates.month(journeeExploitation))
     @info "Vaccum and reindex $(schema).$(partitionName)"
     queryStringVacuum = "VACUUM (ANALYZE) $(schema).$(partitionName)"
     queryStringReindex = "REINDEX TABLE $(schema).$(partitionName)"
     dbconn = ICUDYNUtil.openDBConn()
     try
         PostgresqlDAO.Controller.execute_plain_query(queryStringVacuum,
                                                      missing,
                                                      dbconn)
         PostgresqlDAO.Controller.execute_plain_query(queryStringReindex,
                                                      missing,
                                                      dbconn)
     catch e
         rethrow(e)
     finally
         closeDBConn(dbconn)
     end

     return nothing
end

"""
    vacuumAndReindexTablesPartitionnees(schema::String,
                                        journeeExploitation::Date)

Opérations de maintenance sur les partitions des tables d'un schéma donné pour les
partitions correspondant à la journée d'exploitation donnée
"""
function ICUDYNUtil.vacuumAndReindexTablesPartitionnees(schema::String,
                                                     journeeExploitation::Date)

    year = Dates.year(journeeExploitation)
    month = Dates.month(journeeExploitation)

    # Récupère la liste de toutes les tables partitionnées
    tablesPartitionneesDF = ICUDYNUtil.getTablesPartitionnees()

    for r in eachrow(tablesPartitionneesDF)
        # Si la table est dans le schéma d'intérêt on s'en occupe
        if r.table_schema == schema
            ICUDYNUtil.vacuumAndReindexTablesPartitionnees(schema,
                                                        r.table_name,
                                                        journeeExploitation)
        end
    end

end

function ICUDYNUtil.getTablePartitionName(tableName::String,
                                       year::Integer,
                                       month::Integer)
    # Add the trailing 0 if the month is inferior to 10
    monthStr = lpad(month,2,"0")
    partitionTable = "$(tableName)_$(year)$(monthStr)"

    return partitionTable
end



function ICUDYNUtil.tableOrPartitionExists(schema::String, tableName::String)
    queryString = "SELECT EXISTS (
                   SELECT FROM information_schema.tables
                   WHERE  table_schema = '$schema'
                   AND    table_name   = '$tableName'
                   );"
    queryResult = ICUDYNUtil.openDBConnectionAndExecuteQuery(queryString,[])
    return queryResult[1,1]
end


function ICUDYNUtil.getTables()

    queryString = "
       SELECT table_schema, table_name
       FROM information_schema.tables
       WHERE table_catalog = \$1
           AND table_type = 'BASE TABLE'
           AND table_schema NOT IN ('pg_catalog', 'information_schema')
       ORDER BY table_schema, table_name"

    queryArgs = [getConf("database","database")]
    tables = ICUDYNUtil.openDBConnectionAndExecuteQuery(queryString, queryArgs)

    # Retire les tables correspondant à des partitions
    filter!(x -> !occursin(r"_[0-9]{6}$",x.table_name), tables)

    return tables
end

"""
    getTablesPartitionnees()

Renvoie la liste de toutes les tables qui doivent être partitionnées.
"""
function ICUDYNUtil.getTablesPartitionnees()
    conf = getConf("database","tables_non_partitionnees")
    schemasCompletementExclus = conf |>
            v -> filter(x -> occursin("*",x), v) |>
            v -> map(x -> replace(x,".*" => ""), v)
    schemasPartiellementExclus = filter(x -> !occursin("*",x), conf)

    tables = ICUDYNUtil.getTables()

    tables = tables |>
      # Supprime toutes les tables dont les schémas sont complètement exclus
      v -> filter(x -> !(x.table_schema in schemasCompletementExclus),v) |>
      v -> filter(x -> !("$(x.table_schema).$(x.table_name)" in schemasPartiellementExclus), v)

    return tables

end


function ICUDYNUtil.getCurrentFrontendVersion()

    dbconn = ICUDYNUtil.openDBConn()
    result = try
        query_string =
           "SELECT * FROM misc.frontend_version
            ORDER BY name DESC
            LIMIT 1
            "

        result = PostgresqlDAO.Controller.
            execute_query_and_handle_result(query_string,
                                            FrontendVersion,
                                            [], # query_args
                                            false, # retrieve_complex_props
                                            dbconn::LibPQ.Connection)
        result
    catch e
        rethrow(e)
    finally
        ICUDYNUtil.closeDBConn(dbconn)
    end

    if isempty(result)
        return missing
    end

    return result[1]

end


function ICUDYNUtil.overwriteConfForPrecompilation()

    for i in 1:nprocs()
        @spawnat i begin
            @info "Overwrite configuration for compilation on process ID[$(Distributed.myid())]"
            # Backup the initial values for restoration
            ICUDYN.config._data["database"]["user_bk"] =
                ICUDYN.config._data["database"]["user"]

            # Set temporary values
            ICUDYN.config._data["database"]["user"] =
                ICUDYN.config._data["database"]["user_readonly"]
        end
    end

end

function ICUDYNUtil.restoreConfAfterPrecompilation()
    for i in 1:nprocs()
        @spawnat i begin
            @info "Restore configuration after precompilation on process ID[$(Distributed.myid())]"
            # Backup the initial values for restoration
            ICUDYN.config._data["database"]["user"] =
                ICUDYN.config._data["database"]["user_bk"]

        end
    end
end
