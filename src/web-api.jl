using Pkg
Pkg.activate(".")
using Revise

using Distributed

# addprocs(Sys.CPU_THREADS - 1) # Add the number of processors minus one (for the
#                               #  current process)

@everywhere using Distributed # Add Distributed to all processes because we
                              #   want to use Distributed.myid() in the processes

# Ajout du chemin vers PostgresqlDAO dans le path de julia
@everywhere push!(LOAD_PATH, ENV["POSTGRESQLDAO_PATH"])

@everywhere using Mux, HTTP, HttpCommon, UUIDs

# Overwrite some packages
# For handling file upload in Mux
# include("package-overwrite/HTTP-overwrite.jl")
@everywhere include("src/package-overwrite/Mux-overwrite.jl")

# Run all the required 'using'
@everywhere include("src/using.jl")

# ################# #
# BlindBake - BEGIN #
# ################# #
if OQSUtil.blindBakeIsRequired()
  # Temporarily change the configuration
  OQSUtil.overwriteConfForPrecompilation()
  include("precompile.jl")
  # Restore configuration
  OQSUtil.restoreConfAfterPrecompilation()
end
# ################# #
# BlindBake - ENDOF #
# ################# #

# The loggers need to be declared once the modules are loaded because they have
#   a reference to them
@everywhere include("src/logging/loggers.jl")
logger = createLogger() # see logging/loggers.jl for other values

# Start the scheduler (on proc 1)
# OQS.startScheduler()

with_logger(logger) do

  @show "test log"

  # Reference:
  # https://github.com/JuliaWeb/JuliaWebAPI.jl/issues/73

  # Source the following file when it has been changed or that something in the
  #   module used by the API has changed.
  # NOTE: Do not restart Mux.serve()

  @everywhere include("src/web-api-definition.jl")

  for i in 1:nprocs()
    # Start the server (only once per julia session)
    @spawnat i Mux.serve(web_api, Mux.localhost, 8083
             ;reuseaddr = true)
  end

  # The following is commented out because we want to have access to the REPL
  # Base.JLOptions().isinteractive == 0 && wait()

end # with_logger
