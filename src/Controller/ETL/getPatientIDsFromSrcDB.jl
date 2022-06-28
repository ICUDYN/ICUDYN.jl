function ETL.getPatientIDsFromSrcDB(
    firstname::String,
    lastname::String,
    birthdate::Date)::Vector{Integer}

    queryString = "
        SELECT DISTINCT
            vc.firstname,
            vc.lastname,
            vc.encounterid,
            convert(varchar,vc.dateOfBirth,121) AS terseForm
        FROM dbo.V_Census vc
        WHERE vc.firstname = ? AND vc.lastname = ? AND vc.dateOfBirth = ?"

    params = [firstname, lastname, birthdate]

    dbconn = ICUDYNUtil.openSrcDBConn()

    try
        df = DBInterface.execute(dbconn, queryString,params) |> DataFrame
        return df.encounterid
    catch e
        rethrow(e)
    finally
        ICUDYNUtil.closeDBConn(dbconn)
    end


end
