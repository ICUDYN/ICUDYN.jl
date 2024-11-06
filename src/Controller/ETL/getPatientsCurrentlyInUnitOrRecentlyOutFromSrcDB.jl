function ETL.getPatientsCurrentlyInUnitOrRecentlyOutFromSrcDB(dbconn::Union{ODBC.Connection,MySQL.Connection})

    patientsCurrentlyInUnit = ETL.getPatientsCurrentlyInUnitFromSrcDB(dbconn)
    patientsRecentlyOut = ETL.getPatientsRecentlyOutFromSrcDB(dbconn)

    # Concatenate both vectors
    # NOTE: The unique shouldnt be needed but there are rare cases where a patient can be in both
    [patientsCurrentlyInUnit..., patientsRecentlyOut...] |>
    n -> unique(x -> x.srcDBIDs, n)

end
