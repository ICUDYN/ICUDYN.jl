include("../../../runtests-prerequisite.jl")

@testset "Test Biology.computeBiologyVars" begin

    df = DataFrame(
        terseForm = [
            "1",
            "1",
            "toto",
            "1,5"],
        attributeDictionaryPropName = [
            "toto",
            "PtLabResult_Acide lactique",
            "PtLabResult_Acide lactique",
            "PtLabResult_Acide urique"],
        interventionLongLabel = [
            "PtLabResult_Acide lactique",
            "PtLabResult_Acide lactique",
            "PtLabResult_Acide lactique",
            "PtLabResult_Acide urique"],
        )

        res = ETL.Biology.computeBiologyVars(df)
        #TODO Bapt : finish it
end


@testset "Test Biology.computeCreatinine" begin


    df = DataFrame(
        terseForm = [
            "1",
            "40, 45.5",
            "50, 55.5"],
        attributeDictionaryPropName = [
            "toto",
            "PtLabResult_CreatinineInt.Variation",
            "PtLabResult_CreatinineInt.Variation"]
        )

        res = ETL.Biology.computeCreatinine(df, 30, 65., "male")

        @test res == Dict(
            :creatinine => 45,
            :cockroftDfg => 198.61
        )


end


@testset "Test Biology.computeUrea" begin

    df = DataFrame(
        terseForm = [
            "1",
            "40.2",
            "40,4",
            "50,2",
            "50.4"],
        attributeDictionaryPropName = [
            "toto",
            "PtLabResult_serumUreaInt.serumUreaMsmt",
            "PtLabResult_serumUreaInt.serumUreaMsmt",
            "PtLabResult_Ure_urinaireInt.Ure_urinairePty",
            "PtLabResult_Ure_urinaireInt.Ure_urinairePty"]
        )

        res = ETL.Biology.computeUrea(df)

        @test res == Dict(
            :bloodUrea => 40.3,
            :urineUrea => 50.3
        )

end
