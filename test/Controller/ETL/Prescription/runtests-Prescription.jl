include("../../../runtests-prerequisite.jl")


@testset "Test computePrescriptionBaseVars" begin
df = DataFrame(
    terseForm = [
        15,
        100,
        30,
        "",
        200,
        6,
        100,
        15,
        200,
        15,
        30,
        6,

        1000,
        1000,
        1,
        600,
        1000,
        1,
        600,
        1000,
        1,
        "NULL",
        1,
        1000,
        ],
    attributeDictionaryPropName = [
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",
        "PtMedication_dripAdmIntervention.formularyAdditiveDoseRate",

        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        "PtMedication_formularyDiscreteDoseInt.formularyAdditiveDose",
        ],
    interventionLongLabel = [
        "PtMedication_Cisatracurium. (Nimbex®) mg/h 5 mg/ml",
        "PtMedication_PSE Propofol à 200 mg/h à 20 ml/h (500 mg/50 ml)",
        "PtMedication_Sufentanil citrate (Sufentanil®) µg/h 5 µg/ml",
        "PtMedication_Midazolam (Hypnovel®) mg/h 1 mg/ml",
        "PtMedication_PSE Propofol à 200 mg/h à 20 ml/h (500 mg/50 ml)",
        "PtMedication_Midazolam (Hypnovel®) mg/h 1 mg/ml",
        "PtMedication_PSE Propofol à 200 mg/h à 20 ml/h (500 mg/50 ml)",
        "PtMedication_Cisatracurium. (Nimbex®) mg/h 5 mg/ml",
        "PtMedication_PSE Propofol à 200 mg/h à 20 ml/h (500 mg/50 ml)",
        "PtMedication_Cisatracurium. (Nimbex®) mg/h 5 mg/ml",
        "PtMedication_Sufentanil citrate (Sufentanil®) µg/h 5 µg/ml",
        "PtMedication_Midazolam (Hypnovel®) mg/h 1 mg/ml",

        "PtMedication_IV Paracétamol (Perfalgan®) 1000 mg (/ 6h)",
        "PtMedication_IV Paracétamol (Perfalgan®) 1000 mg (/ 6h)",
        "PtMedication_Ophtalmique Ac. borique (Dacudose®) 1 dose (/ 24h (matin))",
        "PtMedication_IV Linézolide 600 mg (/ 12h (de 11h))",
        "PtMedication_IV Paracétamol (Perfalgan®) 1000 mg (/ 6h)",
        "PtMedication_Ophtalmique Ac. borique (Dacudose®) 1 dose (/ 24h (matin))",
        "PtMedication_IV Linézolide 600 mg (/ 12h (de 11h))",
        "PtMedication_IV Paracétamol (Perfalgan®) 1000 mg (/ 6h)",
        "PtMedication_Ophtalmique Ac. borique (Dacudose®) 1 dose (/ 24h (matin))",
        "PtMedication_IV Paracétamol (Perfalgan®) 1000 mg (/ 6h)",
        "PtMedication_Ophtalmique Ac. borique (Dacudose®) 1 dose (/ 24h (matin))",
        "PtMedication_IV Paracétamol (Perfalgan®) 1000 mg (/ 6h)",
        

        ]   
    )

    res = ETL.Prescription.computePrescriptionBaseVars(df)
    println(res)
    @test res == Dict(
        :midazolamDrip         => 6.0,
        :sufentanylDiscrete    => missing,
        :sufentanylDrip        => 30.0,
        :paracetamolDiscrete   => 1000.0,
        :propofolDiscrete      => missing,
        :sedative              => true,
        :propofolDrip          => 150.0,
        :atracuriumDrip        => 15.0,
        :atracuriumDiscrete    => missing,
        :paracetamolDrip       => missing,
        :midazolamDiscrete     => missing,
        :cisatracuriumDiscrete => missing,
        :cisatracuriumDrip => 15.0
    )
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