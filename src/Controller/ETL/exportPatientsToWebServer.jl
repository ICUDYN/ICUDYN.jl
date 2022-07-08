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

    # DEBUG: Limit the number of patients
    # patientsInSrcDB = patientsInSrcDB[1:2]

    ETL.preparePatientsAndExportToExcel(
        patientsInSrcDB,
        false, # useCache
        dbconn,
        ;filepath = filepath
    )

end
