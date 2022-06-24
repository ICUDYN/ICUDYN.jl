include("../../runtests-prerequisite.jl")

@testset "Test get_patient_df_from_csv" begin

    patientCodeName = ICUDYNUtil.getConf("test","patient_code_name")
    patientsDir = ICUDYNUtil.getConf("test","patients_dir")
    patientFilename = joinpath(patientsDir,"all_events_$patientCodeName.csv.xlsx")
    isfile(patientFilename)
    df = XLSX.readtable(patientFilename,1) |> n -> DataFrame(n...)
    typeof(df)

    patient_dir = INCUDYNUtil.getDataInputDir()
    patient_csv_filename = patient_dir * "all_events_" * patient_name * ".csv"
    return DataFrame(CSV.File(patient_csv_filename))
end



@testset "Test cut_patient_df" begin

    # Check that event at cutting time gets into the next window
    chartTime = [
            DateTime("2022-01-01T14:01:00"),
            DateTime("2022-01-01T10:00:00"),
            DateTime("2022-01-01T11:00:00"),
            DateTime("2022-01-01T13:59:59"),
            DateTime("2022-01-01T14:00:00"),
            ]
    df = DataFrame(
        chartTime = chartTime,
        a = ones(length(chartTime))
    )
    result = ETL.cutPatientDF(df)

    @test length(result) == 2
    @test (result |> n -> isempty.(n) |> n -> .!(n) |> n -> all(n)) == true


    # Check border case
    chartTime = [
            DateTime("2022-01-01T10:00:00"),
            DateTime("2022-01-01T11:00:00"),
            DateTime("2022-01-01T13:59:59"),
            DateTime("2022-01-01T14:00:00"),
            ]
    df = DataFrame(
        chartTime = chartTime,
        a = ones(length(chartTime))
    )
    result = ETL.cutPatientDF(df)

    @test length(result) == 2
    @test (result |> n -> isempty.(n) |> n -> .!(n) |> n -> all(n)) == true

    # Check empty windows
    chartTime = [
            DateTime("2022-01-01T10:00:00"),
            DateTime("2022-01-01T11:00:00"),
            DateTime("2022-01-01T13:59:59"),
            DateTime("2022-01-01T20:00:00"),
            DateTime("2022-01-02T20:00:00"),
            ]
    df = DataFrame(
        chartTime = chartTime,
        a = ones(length(chartTime))
    )
    result = ETL.cutPatientDF(df)

    @test length(result) == 3
    @test (result |> n -> isempty.(n) |> n -> .!(n) |> n -> all(n)) == true


    chartTime = [
            DateTime("2019-01-01T00:00:00"),
            DateTime("2019-01-02T00:00:00"),
            DateTime("2019-01-02T18:26:00"),
            DateTime("2019-01-02T18:27:00"),
            ]
    df = DataFrame(
        chartTime = chartTime,
        a = ones(length(chartTime))
    )
    result = ETL.cutPatientDF(df)

    @test length(result) == 3
    @test (result |> n -> isempty.(n) |> n -> .!(n) |> n -> all(n)) == true

end


@testset "Test ETL.refineWindow1stPass!" begin

    chartTime = [
        DateTime("2022-01-01T14:01:00"),
        DateTime("2022-01-01T10:00:00"),
        DateTime("2022-01-01T11:00:00"),
        DateTime("2022-01-01T13:59:59"),
        DateTime("2022-01-01T14:00:00"),
        ]
    window = DataFrame(
        chartTime = chartTime,
        attributeDictionaryPropName = string.(ones(length(chartTime))),
        interventionLongLabel = string.(ones(length(chartTime))),
        interventionBaseLongLabel = string.(ones(length(chartTime))),
        interventionPropName = string.(ones(length(chartTime))),
        verboseForm = string.(ones(length(chartTime))),
        terseForm = ones(length(chartTime)),
        interventionShortLabel = string.(ones(length(chartTime))),
    )
    refinedWindow = ETL.initializeWindow(window)
    ETL.refineWindow1stPass!(refinedWindow,window)

    ETL.refineWindow1stPass!(refinedWindow,window,ETL.Misc)

end

@testset "Test ETL.orderColmunsOfRefinedHistory!" begin
    df = DataFrame(
        Misc_EndTime = [],
        Physiological_weight = [],
        Physiological_height = [],
        Misc_xxxx = [],
        Misc_StartTime = [],
    )

    @test ETL.orderColmunsOfRefinedHistory!(df) |> names == [
        "Misc_StartTime",
        "Misc_EndTime",
        "Misc_xxxx",
        "Physiological_height",
        "Physiological_weight"
        ]

end


@testset "Test ETL.getPatientIDsInSrcDB" begin

    @test ETL.getPatientIDsInSrcDB(
        ICUDYNUtil.getConf("test","patient_firstname"),
        ICUDYNUtil.getConf("test","patient_lastname"),
        Date(ICUDYNUtil.getConf("test","patient_birthdate"))
    ) |> n -> n isa Vector{Integer}

end

@testset "Test ETL.getPatientDFFromSrcDB" begin

    @test ETL.getPatientRawDFFromSrcDB([12695,13022])

end


@testset "Test ETL.getPatientsCurrentlyInUnitFromSrcDB" begin

    grs = ETL.getPatientsCurrentlyInUnitFromSrcDB() |>
    n -> groupby(n, [:firstname,:lastname,:birthdate])

    dfClean = DataFrame()
    for g in grs
        dfTmp = DataFrame(
            patientIDs = [g.encounterId],
            firstname = first(g).firstname,
            lastname = first(g).lastname,
            birthdate = first(g).birthdate,
            inTimes = [g.inTime],
            outTimes = [g.outTime]
        )
        append!(
            dfClean,
            dfTmp
        )
    end

    dfClean

end
