include("../../../runtests-prerequisite.jl")


@testset "Test computePrescriptionBaseVars" begin

    #TODO
    @test false
end


@testset "Test computeAmineAgentsAdditionalVars" begin

    df = DataFrame()
    norepinephrineMeanMgHeure = 3
    epinephrineMeanMgHeure = 2
    dobutamineMeanGammaKgMinute = 20
    weightAtAdmission = 70

    res = ETL.Prescription.computeAmineAgentsAdditionalVars(
        df,
        norepinephrineMeanMgHeure,
        epinephrineMeanMgHeure,
        dobutamineMeanGammaKgMinute, 
        weightAtAdmission)

    @test res == Dict(
        :norepinephrineStatus => "HIGH",
        :norepinephrineMeanGammaKgMinute => 0.71,
        :epinephrineStatus => "LOW",
        :epinephrineMeanGammaKgMinute => 0.48,
        :dobutamineStatus => "HIGH",
        :amineAgent => true
    )
    
end


@testset "Test computeSedativeAgentsOtherVars" begin


    df = DataFrame(
        terseForm = [
            "tata",
            "0.4",
            0.7,
            "0.87",
            0.90],
        attributeDictionaryPropName = [
            "toto",
            "PtAssessment_ISO_fe__ISO_in.ISO_fe",
            "PtAssessment_ISO_fe__ISO_in.ISO_fe",
            "PtAssessment_Anaconda.Rglage_dbit",
            "PtAssessment_Anaconda.Rglage_dbit"]
        )

    res = ETL.Prescription.computeSedativeAgentsOtherVars(df)

    @test res == Dict(
        :isofluraneExpiratoryFractionMean => 0.55,
        :isofluraneStatus => "NORMAL",
        :anacondaDebitMean => 0.88
    )
end