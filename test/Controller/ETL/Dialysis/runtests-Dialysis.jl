include("../../../runtests-prerequisite.jl")

@testset "Test Dialysis.computeDialysisTypeAndDuration" begin

    # Case 'intermittent dialysis'
    df = DataFrame(
        interventionLongLabel = [
            "PtIntake_Hémodialyse séquentielle 3h",
            "100 ml",],
        attributeDictionaryPropName = [
            "PtIntake_peritonealDiaInt.formularyAdditiveAmount",
            "toto"
            ],
        interventionBaseLongLabel = [
            "PtAssessment_Machine HD",
            "toto"
        ],
        interventionPropName = [
            "",
            ""
        ]
        )
        @test ETL.Dialysis.computeDialysisTypeAndDuration(df) == Dict(
            :type => "intermittent",
            :started => true,
            :durationPrescribed_hours => 3
            )

    # Case 'continuous dialysis'
    df = DataFrame(
        chartTime = [
            DateTime("2022-01-01T09:00:00"),
            DateTime("2022-01-01T09:00:00")
        ],
        terseForm = [
            "02/01/2022 09:00",
            ""
        ],
        interventionLongLabel = [
            "",
            "",],
        attributeDictionaryPropName = [
            "",
            ""
            ],
        interventionBaseLongLabel = [
            "",
            ""
        ],
        interventionPropName = [
            "PtIntakeOrder_Interrompre",
            ""
        ],
        attributeLongLabel = [
            "PtIntakeOrder_2.a. CVVHF.Interface Details.Effective Time",
            ""
        ]
    )
    @test ETL.Dialysis.computeDialysisTypeAndDuration(df) == Dict(
        :type => "continuous",
        :started => true,
        :durationPrescribed_hours => 24
        )



end

@testset "Test Dialysis.computeDialysisMolecule" begin

    # Case 'with values'
    df = DataFrame(
        verboseForm = [
            "toto HNF tata",
            "100 ml",],
        attributeDictionaryPropName = [
            "PtIntakeOrder_hemofiltrationOrd.formularyAdditiveUsageMat",
            "toto"
            ]
        )
    @test ETL.Dialysis.computeDialysisMolecule(df) == "heparin"


end

@testset "Test Dialysis.computeDialysisWaterLoss" begin

    # Case 'with values'
    df = DataFrame(
        verboseForm = [
            "0 ml",
            "100 ml",
            "100 ml",],
        attributeDictionaryPropName = [
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "toto"
            ]
        )
    @test ETL.Dialysis.computeDialysisWaterLoss(df) == 50

    # Case 'no values'
    df = DataFrame(
        verboseForm = [
            "0 ml",
            "100 ml",
            "100 ml",],
        attributeDictionaryPropName = [
            "toto",
            "toto",
            "toto"
            ]
        )
    @test ETL.Dialysis.computeDialysisWaterLoss(df) === missing

end
