include(joinpath(pwd(),"test/runtests-prerequisite.jl"))

using PostgresqlDAO
using PostgresqlDAO.Tool
using LibPQ


out_dir = (@__DIR__) * "/out"
dbconn = ICUDYNUtil.openDBConnAndBeginTransaction()

PostgresqlDAO.Tool.generateJuliaStructFromTable(dbconn,
                             "public",
                             "actor",
                             "Actor",
                             (out_dir * "/Actor.jl"),
                             (out_dir * "/ActorDAO.jl")
                            ;camelcase_is_default = false
                            )

PostgresqlDAO.Tool.generateJuliaStructFromTable(dbconn,
                             "public",
                             "film",
                             "Film",
                             (out_dir * "/Film.jl"),
                             (out_dir * "/FilmDAO.jl")
                            ;ignored_columns = ["fulltext"],
                            camelcase_is_default = false
                            )

PostgresqlDAO.Tool.generateJuliaStructFromTable(dbconn,
                             "public",
                             "film_actor",
                             "FilmActorAsso",
                             (out_dir * "/FilmActorAsso.jl"),
                             (out_dir * "/FilmActorAssoDAO.jl")
                            ;camelcase_is_default = false
                            )

PagilaUtil.closeDBConn(dbconn)
