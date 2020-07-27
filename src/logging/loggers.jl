using Logging, IOLogging
using Logging: Debug, Info, Warn, Error, BelowMinLevel, with_logger, min_enabled_level

using PostgresqlDAO, ICUDYN

function createLogger(logtype = "default")

    logger = current_logger()

    # If no logtype is given we use the one in the configuration
    if ismissing(logtype)
        @info "No logtype was given, we use the one found in the configuration."
        logtype = getConf("logging","output")
    end

    #
    # In development: use a logger that also displays the line number
    #
    if logtype == "default"
        @info "Use current logger"

    elseif logtype == "console_with_line_number"
        logger = SimpleLogger(stdout, Logging.Info)
        # global_logger(logger)

    #
    # In production
    #
    elseif logtype == "multifiles"

        @info "Setting-up multifiles logger"

        # Load the modules in case they haven't been loaded yet, especially for modules
        #  that are dependences of other modules and therefore not explicitely available

        logFileMain = FileDefForMultifilesLogger("Main.log",
                                                 [(Main,Info)];
                                                 append = false
                                                 )

         logFilePostgresqlDAO = FileDefForMultifilesLogger("PostgresqlDAO.log",
                                                  [(PostgresqlDAO,Info)];
                                                  append = false
                                                  )

         logger =
             MultifilesLogger([logFileMain,logFilePostgresqlDAO])

         # global_logger(multifilesLogger)

    end

    return logger

end
