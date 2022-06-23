include("../runtests-prerequisite.jl")

@testset "Test openining ICCA connection" begin
    dbconn = ICUDYNUtil.openDBConnICCA()
    ICUDYNUtil.closeDBConn(dbconn)
end
