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
    result = ETL.cut_patient_df(df) 
    
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
    result = ETL.cut_patient_df(df) 
    
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
    result = ETL.cut_patient_df(df) 
    
    @test length(result) == 3
    @test (result |> n -> isempty.(n) |> n -> .!(n) |> n -> all(n)) == true
    
end