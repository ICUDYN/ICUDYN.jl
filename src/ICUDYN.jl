module ICUDYN

using XLSX: isempty
using DataFrames: Dict
using Base: String, lowerbound
greet() = print("Hello World!")

function greet(name::String)
    @info "greet $name"
    return name
end

module Toto
    greet() = print("Hello World!")

    function greet(name::String)
        @info "greet $name"
        return name
    end
end

module ICUDYNUtil

    using ConfParser,PostgresORM,
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
             getFilePathAnalyseLignesPourJourneeExploitation, isMissing,
             getNumericValueFromWindowTerseForm, rmAccentsAndLowercaseAndStrip,
             getNonMissingValues,convertToFloatIfPossible, checkIfContainsNonStrict

     include("./util/utils-def.jl")

end

module Model

    using Dates, TimeZones, UUIDs, PostgresORM

end


module Controller

    using ..ICUDYN, ..Model, ..ICUDYNUtil
    using PostgresORM, LibPQ, Dates

    module Stay
      include("./Controller/Stay/Stay-controller-def.jl")
    end

    "Contient les fonctions pour l'execution automatique des scripts"
    module Scheduler
     # include("./controller/scheduler/Scheduler-def.jl")
    end

    module ETL
    include("Controller/ETL/ETL-def.jl")

      module Misc
         include("Controller/ETL/Misc/Misc-def.jl")
      end
      module Physiological
         include("Controller/ETL/Physiological/Physiological-def.jl")
      end
      module Transfusion
         include("Controller/ETL/Transfusion/Transfusion-def.jl")
      end
      module FluidBalance
         include("Controller/ETL/FluidBalance/FluidBalance-def.jl")
      end
      module Dialysis
         include("Controller/ETL/Dialysis/Dialysis-def.jl")
      end
      module Nutrition
        include("Controller/ETL/Nutrition/Nutrition-def.jl")
      end

      module Ventilation end
      module Prescription end
      module Biology end
    end

end # ENDOF Controller

#
include("imp-using.jl")

# Utils
include("./util/utils-imp.jl")

# Stay controllers
include("./Controller/Stay/Stay-controller-imp.jl")

# ETL controllers
include("Controller/ETL/ETL-imp.jl")


"ICUDYN configuration (of type `ConfigParse`)"
config = ICUDYNUtil.loadConf()

end # module ICUDYN
