using Distributed: serialize, deserialize
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
    
end


using Serialization
@testset "Test CSV to excel" begin

    serialize("tmp/raw_df.jld",ETL.getPatientDFFromExcel("xxx"))
    @time ETL.getPatientDFFromExcel("xxx")
    raw = deserialize("tmp/raw_df.jld")
    ETL.preparePatientsFromRawExcelFile(["xxx"])
    ETL.getPatientDFFromExcel("xxx") |> ETL.processPatientRawHistory
    ETL.getPatientDFFromExcel("xxx") |> df -> ETL.cutPatientDF(df) |> length

    raw |> ETL.processPatientRawHistory
    firstWindow = raw |> df -> ETL.cutPatientDF(df) |> first

    ETL.refineWindow1stPass(firstWindow, ETL.Misc)

    _module = ETL.Misc
    refiningFunctions = names(_module, all=true) |> 
    n -> filter(x -> getproperty(_module,x) isa Function && x ∉ (:eval, :include),n) |>
    n -> filter(x -> getproperty(_module,x) |> methods |> first |> 
                                  m -> length(m.sig.parameters) == 2 ,n) |>
    n -> filter(x -> startswith(string(x),"compute"),n)
    for f in refiningFunctions
        fct = getfield(_module, f)
        fctResult = fct(firstWindow)
        @info fctResult
    end

    getfield(ETL.Misc, :computeDischargeDisposition) |> typeof
    getfield(ETL.Misc, :computeDischargeDisposition)(firstWindow)   
    typeof(getfield(ETL.Misc, :computeDischargeDisposition)) 


    refinedWindow = ETL.initializeWindow(firstWindow)
    ETL.refineWindow1stPass!(refinedWindow,firstWindow)

    refinedWindowForModule = Dict{Symbol, Any}()
    ETL.refineWindow1stPass(firstWindow,ETL.Misc)

    _module = ETL.Misc
    names(_module, all=true) |> 
        n -> filter(x -> getproperty(_module,x) isa Function && x ∉ (:eval, :include),n) |>
        n -> filter(x -> getproperty(_module,x) |> methods |> first |> 
                                      m -> length(m.sig.parameters) == 2 ,n) |>
        n -> filter(x -> startswith(string(x),"compute"),n)

        getproperty(_module,:computeDischargeDisposition) |> methods |> first |> 
                                       m -> length(m.sig.parameters) == 2 

    let 
        refinedWindows = Vector{Dict{Symbol, Any}}()
    for rawWindow in rawWindows
        refinedWindow = ETL.initializeWindow(rawWindow)
        push!(refinedWindows,refinedWindow)
        ETL.refineWindow1stPass!(refinedWindow,rawWindow)
    end
        
    end

end