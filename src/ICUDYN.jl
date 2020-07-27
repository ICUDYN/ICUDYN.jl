module ICUDYN


greet() = print("Hello World!")

"Contient les déclarations des différents `@enum`.
Par praticité chaque `@enum` est placé dans un module."
module Enums
    include("./enum/enums.jl")
end

module ICUDYNUtil

    using ConfParser,PostgresqlDAO,
          PostgresqlDAO.PostgresqlDAOUtil, PostgresqlDAO.Controller,
          LibPQ, Query, JSON, ConfParser, UUIDs, XLSX, Base.StackTraces,
          Dates, TimeZones, InfoZIP

    export openDBConn, openDBConnAndBeginTransaction,commitDBTransaction,
             closeDBConn, rollbackDBTransaction,
             formatExceptionAndStackTrace, formatExceptionAndStackTraceCore,
             getConf, getFrontendURL, getETLMaxSizeBeforeDBCommit,
             getETLTnterruptionFilepath, hasRole,
             getTimeZone, diffInSecondsAsInt,
             getTranslation, json2Entity,
             getDataDir, getICUDYNTempDir, getETLAIntegrerDir, getETLDejaIntegreDir,
             initialize_http_response_status_code,
             convertStringToZonedDateTime, convertStringToDate,
             convertStringOfTimeToSeconds, nowInCurrentTimeZone,
             unzipFileInTempDir, readdirWithFullpath, extension,
             addTimeToZonedDateTime, addTimeToDate, getDateOfZonedDateTime,
             getFilePathAnalyseRefactionsSerialisee,
             getFilePathAnalyseLignesSerialisee,
             getFilePathAnalyseLignesPourJourneeExploitation

     include("./util/utils-def.jl")

end

module Model

    using Dates, TimeZones, UUIDs, PostgresqlDAO, PostgresqlDAO.Model
    using ..Enums, ..Enums.AppUserType, ..Enums.RoleCodeName

    export AppUser, Role, AppUserRoleAsso, RoleRoleAsso,
           File, FrontendVersion, ScheduledTaskExecution

    include("./model/abstract_types.jl")
    include("./model/user/AppUser.jl")
    include("./model/user/Role.jl")
    include("./model/user/RoleRoleAsso.jl")
    include("./model/user/AppUserRoleAsso.jl")
    include("./model/misc/File.jl")
    include("./model/misc/FrontendVersion.jl")
    include("./model/misc/ScheduledTaskExecution.jl")
end

module DAO
    using ..Model, PostgresqlDAO

    # Overwrite the table for PostgresqlDAO.Model.Modification
    include("./package-overwrite/PostgresqlDAO-overwrite.jl")

     module AppUserDAO
       using ..Model, PostgresqlDAO, PostgresqlDAO.Model.Enums.CRUDType
       include("./dao/user/AppUserDAO.jl")
    end
    module AppUserRoleAssoDAO
       using ..Model, PostgresqlDAO, PostgresqlDAO.Model.Enums.CRUDType
       include("./dao/user/AppUserRoleAssoDAO.jl")
    end
    module RoleDAO
       using ..Model, PostgresqlDAO, PostgresqlDAO.Model.Enums.CRUDType
       include("./dao/user/RoleDAO.jl")
    end
    module RoleRoleAssoDAO
       using ..Model, PostgresqlDAO, PostgresqlDAO.Model.Enums.CRUDType
       include("./dao/user/RoleRoleAssoDAO.jl")
    end
    module FileDAO
       using ..Model, PostgresqlDAO, PostgresqlDAO.Model.Enums.CRUDType
       include("./dao/misc/FileDAO.jl")
    end
    module FrontendVersionDAO
       using ..Model, PostgresqlDAO, PostgresqlDAO.Model.Enums.CRUDType
       include("./dao/misc/FrontendVersionDAO.jl")
    end
    module ScheduledTaskExecutionDAO
       using ..Model, PostgresqlDAO, PostgresqlDAO.Model.Enums.CRUDType
       include("./dao/misc/ScheduledTaskExecutionDAO.jl")
    end

end

module Controller

    using ..ICUDYN, ..Model, ..ICUDYNUtil, ..Enums
    using PostgresqlDAO, PostgresqlDAO.Controller,
          PostgresqlDAO.Model.Enums.CRUDType,
          Tables, LibPQ, Dates
    export persist!, update!, retrieveOneEntity, retrieveEntities,
           deleteAlike, persistInBulkWithoutReturningValues,
           persistInBulkUsingCopy, updateVectorProps!

    include("./controller/default-crud.jl")

    module User
      include("./controller/user/Role-controller-def.jl")
      include("./controller/user/AppUser-controller-def.jl")
    end

    "Contient les fonctions pour l'execution automatique des scripts"
    module Scheduler
     # include("./controller/scheduler/Scheduler-def.jl")
    end

end

# Utils
include("./util/utils-imp.jl")

# User controllers
include("./controller/user/user-controller-imp.jl")
include("./controller/user/Role-controller-imp.jl")
include("./controller/user/AppUser-controller-imp.jl")

"ICUDYN configuration (of type `ConfigParse`)"
config = ICUDYNUtil.loadConf()

end # module
