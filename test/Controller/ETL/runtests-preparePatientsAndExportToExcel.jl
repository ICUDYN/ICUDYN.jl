include("../../runtests-prerequisite.jl")

@testset "Test ETL.preparePatientsAndExportToExcel" begin

    patientsInSrcDB = ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.getPatientsCurrentlyInUnitOrRecentlyOutFromSrcDB(dbconn)
    end

    patientInSrcDB = patientsInSrcDB[10]
    ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.preparePatientsAndExportToExcel(
            [patientInSrcDB],
            dbconn,
            # ;filepath = "$(tempname()).xlsx"
        )
    end

    ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.preparePatientsAndExportToExcel(
            patientsInSrcDB,
            dbconn,
            ;filepath = "tmp/current_patients.xlsx"
        ) |>
        n -> XLSX.readtable(n,1) |> n -> DataFrame(n...)
    end

end


a = Int[]
push!(a,[3...])
