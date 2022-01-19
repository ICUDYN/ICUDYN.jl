include("../../../runtests-prerequisite.jl")

@testset "Test computeBloodCellsUnits" begin

    #
    df = DataFrame(
        terseForm = [
            1,
            2,
            "",
            4,
            5,
            10,
            "",
            20,
            30],
        interventionShortLabel = [
            "var",
            "var",
            "PtIntake_Culot GR 1",
            "PtIntake_Culot GR 2",
            "PtIntake_Culot GR 3",
            "var",
            "PtIntake_Culot GR 4",
            "PtIntake_Culot GR 5",
            "PtIntake_Culot GR 6",
            ],
        attributeDictionaryPropName = [
            "var",
            "PtIntake_bloodProductInt.N_de_lot",
            "PtIntake_bloodProductInt.N_de_lot",
            "PtIntake_bloodProductInt.N_de_lot",
            "PtIntake_bloodProductInt.N_de_lot",
            "PtIntake_bloodProductInt.intakeVolume",
            "PtIntake_bloodProductInt.intakeVolume",
            "PtIntake_bloodProductInt.intakeVolume",
            "PtIntake_bloodProductInt.intakeVolume",
            ]
        )
    result = ETL.Transfusion.computeBloodCellsUnits(df)

    @test result == Dict(
        :redBloodCellsUnits => 3,
        :redBloodCellsVolume => 50
        )
end