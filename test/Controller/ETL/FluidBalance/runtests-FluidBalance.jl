include("../../../runtests-prerequisite.jl")

@testset "Test computeVolumeInOut" begin

    #
    df = DataFrame(
        terseForm = [
            1.63,
            1.83,
            2.53,
            "",
            2.63,
            2.83,
            3.53,
            ""],
        attributeDictionaryPropName = [
            "var",
            "PtTotalBalance_Total apports (24h)",
            "PtTotalBalance_Total apports (24h)",
            "PtTotalBalance_Total apports (24h)",
            "",
            "PtTotalBalance_Total pertes (24h)",
            "PtTotalBalance_Total pertes (24h)",
            "PtTotalBalance_Total pertes (24h)"]
        )
    result = ETL.FluidBalance.computeVolumeInOut(df)

    @test result == Dict(
        :volumeIn => 4.4,
        :volumeOut => 6.4
        )

end


@testset "Test computeVolumePerfusion" begin

    #
    df = DataFrame(
        terseForm = [
            1.63,
            1.83,
            2.53,
            ""],
        attributeDictionaryPropName = [
            "var",
            "PtTotalBalance_Perfusion IV, 24h",
            "PtTotalBalance_Perfusion IV, 24h",
            "PtTotalBalance_Perfusion IV, 24h"]
        )
    result = ETL.FluidBalance.computeVolumePerfusion(df)

    @test result == Dict(:volumePerfusion => 4.4)

end







@testset "Test computeVolumeAndTypeVascularFilling" begin

    #
    df = DataFrame(
        terseForm = [
            500,
            "",
            500,
            1000,
            1000,
            1000],
        attributeDictionaryPropName = [
            "var",
            "PtIntake_colloidsInt.intakeVolume",
            "PtIntake_colloidsInt.intakeVolume",
            "PtIntake_colloidsInt.intakeVolume",
            "PtIntake_colloidsInt.intakeVolume",
            "PtIntake_colloidsInt.intakeVolume"],
        interventionLongLabel = [
            "PtIntake_IV NaCl 0.9% (500 ml)",
            "PtIntake_IV NaCl 0.9% (500 ml)",
            "PtIntake_IV NaCl 0.9% (500 ml)",
            "PtIntake_IV Ringer (1000 ml)",
            "PtIntake_IV Ringer (1000 ml)",
            "PtIntake_IV Ringer (1000 ml)",
        ]
        )
    result = ETL.FluidBalance.computeVolumeAndTypeVascularFilling(df)

    @test result == Dict(
        :vascularFillingVolumeIn => 3500,
        :vascularFillingType => "NaCl, Ringer"
        )

end

@testset "Test computeVolumeMedecine" begin

    #
    df = DataFrame(
        terseForm = [
            1.63,
            1.83,
            2.53,
            ""],
        attributeDictionaryPropName = [
            "var",
            "PtTotalBalance_Médicaments, PSE et analgésie, 24h",
            "PtTotalBalance_Médicaments, PSE et analgésie, 24h",
            "PtTotalBalance_Médicaments, PSE et analgésie, 24h"]
        )
    result = ETL.FluidBalance.computeVolumeMedecine(df)

    @test result == Dict(:volumeMedecine => 4.4)

end



@testset "Test computeVolumeEnteralFeeding" begin

    #
    df = DataFrame(
        terseForm = [
            1.63,
            1.83,
            2.53,
            ""],
        attributeDictionaryPropName = [
            "var",
            "PtTotalBalance_Apports entéraux, 24h",
            "PtTotalBalance_Apports entéraux, 24h",
            "PtTotalBalance_Apports entéraux, 24h"]
        )
    result = ETL.FluidBalance.computeVolumeEnteralFeeding(df)

    @test result == Dict(:volumeEnteralFeeding => 4.4)

end



@testset "Test computeVolumeParentalFeeding" begin

    #
    df = DataFrame(
        terseForm = [
            1.63,
            1.83,
            2.53,
            ""],
        attributeDictionaryPropName = [
            "var",
            "PtIntake_tpnInt.intakeVolume",
            "PtIntake_tpnInt.intakeVolume",
            "PtIntake_tpnInt.intakeVolume"]
        )
    result = ETL.FluidBalance.computeVolumeParentalFeeding(df)

    @test result == Dict(:volumeParentalFeeding => 4.4)

end

