function ETL.exportPatientsToWebServer()

    filepath = joinpath(ICUDYNUtil.getWebserverOutDir(),"patient-$(now()).xlsx")

    ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.exportPatientsToWebServer(
            dbconn,
            ;filepath = filepath
        )
    end


end

function ETL.exportPatientsToWebServer(
    dbconn::ODBC.Connection,
    ;filepath = "$(tempname()).xlsx"
)

    patientsInSrcDB::Vector{PatientInSrcDB} =
        ETL.getPatientsCurrentlyInUnitOrRecentlyOutFromSrcDB(dbconn)

    patientsInSrcDB = patientsInSrcDB[1:2]

    ETL.preparePatientsAndExportToExcel(
        patientsInSrcDB,
        true, # useCache
        dbconn,
        ;filepath = filepath
    )

end
