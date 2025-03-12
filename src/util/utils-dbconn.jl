
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

function ICUDYNUtil.openSrcDBConn()

    if getConf("database-icca","type") == "MicrosoftSQL"
        dsnKey = getConf("database-icca","host")*getConf("database-icca","database")*getConf("database-icca","port")
        #dsnKey = "ICCA"
        if !haskey(ODBC.dsns(),dsnKey)
            ODBC.adddriver("MS SQL Driver", getConf("database-icca","driver_path"))
            ODBC.adddsn(
                dsnKey,
                "MS SQL Driver"
                ;SERVER = host = getConf("database-icca","host"),
                DATABASE = host = getConf("database-icca","database"),
                PORT = host = getConf("database-icca","port"),
                TrustServerCertificate="yes"
            )
        end

        dbconn = ODBC.Connection(
            dsnKey
            ;user = getConf("database-icca","user"),
            password = getConf("database-icca","password")
        )


    elseif getConf("database-icca","type") == "MySQL"
        
        dbconn = DBInterface.connect(
            MySQL.Connection,
            getConf("database-icca","host"),
            getConf("database-icca","user"),
            getConf("database-icca","password");
            port=getConf("database-icca","port"))
    end

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

function ICUDYNUtil.closeDBConn(conn::LibPQ.Connection)
    close(conn)
end

function ICUDYNUtil.closeDBConn(conn::ODBC.Connection)
    DBInterface.close!(conn)
end

function ICUDYNUtil.closeDBConn(conn::MySQL.Connection)
    DBInterface.close!(conn)
end
