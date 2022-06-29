include("../../runtests-prerequisite.jl")

@testset "Test ETL.preparePatientsAndExportToExcel" begin

    patientsInSrcDB = ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.getPatientsCurrentlyInUnitOrRecentlyOutFromSrcDB(dbconn)
    end

    patientInSrcDB = patientsInSrcDB[10]
    ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.preparePatientsAndExportToExcel(
            [patientInSrcDB],
            true, # useCache
            dbconn,
            # ;filepath = "$(tempname()).xlsx"
        )
    end

    ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.preparePatientsAndExportToExcel(
            # patientsInSrcDB,
            [patientInSrcDB],
            true, # useCache
            dbconn,
            ;filepath = "/usr/share/nginx/html/icudyn-dev/current_patients.xlsx"
        ) |>
        n -> XLSX.readtable(n,1) |> n -> DataFrame(n...)
    end

end
