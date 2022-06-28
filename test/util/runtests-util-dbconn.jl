include("../runtests-prerequisite.jl")

@testset "Test openining ICCA connection" begin
    dbconn = ICUDYNUtil.openSrcDBConn()
    ICUDYNUtil.closeDBConn(dbconn)
end
