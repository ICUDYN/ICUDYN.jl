function ETL.exportPatientsToWebServer(
    ;maxNumberOfPatients::Union{Missing,Integer} = missing
)

    packageVersion = Pkg.project().version |> string

    filepath = joinpath(ICUDYNUtil.getWebserverOutDir(),"patient-$(now())-V$packageVersion.xlsx")

    ICUDYNUtil.createSrcDBConnAndExecute() do dbconn
        ETL.exportPatientsToWebServer(
            dbconn,
            ;filepath = filepath,
            maxNumberOfPatients = maxNumberOfPatients
        )
    end


end

function ETL.exportPatientsToWebServer(
    dbconn::ODBC.Connection,
    ;filepath = "$(tempname()).xlsx",
    maxNumberOfPatients::Union{Missing,Integer} = missing
)

    patientsInSrcDB::Vector{PatientInSrcDB} =
        ETL.getPatientsCurrentlyInUnitOrRecentlyOutFromSrcDB(dbconn)

    # Limit the number of patients if needed
    if !ismissing(maxNumberOfPatients)
        patientsInSrcDB = patientsInSrcDB[1:minimum([maxNumberOfPatients,length(patientsInSrcDB)])]
    end

    ETL.preparePatientsAndExportToExcel(
        patientsInSrcDB,
        true, # useCache
        dbconn,
        ;filepath = filepath
    )

end
