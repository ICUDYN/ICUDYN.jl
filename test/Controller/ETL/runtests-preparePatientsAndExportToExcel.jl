include("../../runtests-prerequisite.jl")

@testset "Test ETL.preparePatientsAndExportToExcel" begin

    patientInSrcDB = ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.getPatientsCurrentlyInUnitFromSrcDB(dbconn)
    end



    ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.preparePatientsAndExportToExcel(
            [patientInSrcDB...],
            dbconn,
            # ;filepath = "$(tempname()).xlsx"
        ) |>
        n -> XLSX.readtable(n,1) |> n -> DataFrame(n...)
    end

end
