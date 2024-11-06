function ETL.getPatientsRecentlyOutFromSrcDB(dbconn::Union{ODBC.Connection,MySQL.Connection})

    # Get a first list of patients names
    queryString = "
        SELECT
            vc.encounterId,
            vc.inTime,
            vc.outTime,
            vc.firstname,
            vc.lastname,
            vc.dateOfBirth AS birthdate
        FROM dbo.V_Census vc
        WHERE vc.firstname IS NOT NULL -- it can happen
          AND vc.lastname IS NOT NULL -- it can happen
          AND vc.dateOfBirth IS NOT NULL -- it can happen
          AND vc.outTime >= ?"

    patientsNamesDF = DBInterface.execute(
        dbconn,
        queryString,
        [DateTime(today() - Day(10), Time(0,0,0))]
    ) |> DataFrame

    result = PatientInSrcDB[]
    for r in eachrow(patientsNamesDF)
        patientIDs = ETL.getPatientIDsFromSrcDB(
            r.firstname,
            r.lastname,
            Date(r.birthdate)
        )
        push!(
            result,
            PatientInSrcDB(
                srcDBIDs = patientIDs,
                firstname = r.firstname,
                lastname = r.lastname,
                birthdate = r.birthdate
            )
        )

    end

    return result

end
