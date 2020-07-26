function Controller.updateVectorProps!(object::Role,
                                       dbconn::LibPQ.Connection
                                      ;editor::Union{AppUser, Missing} = missing)
      PostgresqlDAO.Controller.
        update_vector_property!(object, # updated_object
                               :roleRoleAssos_as_handler, # updated_property
                               dbconn;
                               editor = editor)
      PostgresqlDAO.Controller.
        update_vector_property!(object, # updated_object
                                :roleRoleAssosAsHandled, # updated_property
                                dbconn;
                                editor = editor)
end

function getComposedRolesAccessibleToUser(
        appuser::AppUser
       ;appuserType::Union{Missing,AppUserType.APPUSER_TYPE} = missing)

    dbconn = openDBConnAndBeginTransaction()
    try
        query_string =
           "SELECT
            -- 'DISTINCT' is needed because the user can have several roles
            --   handling the same role
            DISTINCT handled_role.*
            FROM utilisateur.role handler_role
            INNER JOIN utilisateur.role_role_asso rrasso
              ON rrasso.handler_role_id = handler_role.id
            INNER JOIN utilisateur.role handled_role
              ON rrasso.handled_role_id = handled_role.id
            WHERE
                  handled_role.composed = 't'
              AND handler_role.id = ANY(\$1)"

        if !ismissing(appuserType)
            query_string *= " AND handled_role.restricted_to_appuser_type = \$2"
        end

        composed_roles_ids = map(x -> getproperty(getproperty(x,:role),:id),
                                 appuser.composedRolesAssos)
        @info join(composed_roles_ids,",")

        # @info getproperty.(appuser.composedRolesAssos,:role)

        # Create the array of query arguments
        query_args = []
        push!(query_args,composed_roles_ids)
        if !ismissing(appuserType)
            push!(query_args,Int8(appuserType))
        end

        result = PostgresqlDAO.Controller.
            execute_query_and_handle_result(query_string,
                                            Role,
                                            query_args, # query_args
                                            false, # retrieve_complex_props
                                            dbconn::LibPQ.Connection)
        commitDBTransaction(dbconn)
        return(result)
    catch e
        rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end

end


function getComposedRolesForListing(appuser::AppUser)

    if (!hasRole(appuser,RoleCodeName.can_search_roles))
            error("unauthorized_access")
    end

    dbconn = openDBConnAndBeginTransaction()
    try
        queryString =
           "-- We need a 'WITH' query because of the WHERE clause
            WITH roles_assos AS (
            SELECT role.id AS role_id,
            	   string_agg(DISTINCT related_noncomposed_role.code_name::text, ', '::text) AS noncomposed_roles_code_names,
            	   string_agg(DISTINCT related_composed_role.code_name::text, ', '::text) AS composed_roles_code_names,
            	   string_agg(DISTINCT related_noncomposed_role.name_en::text, ', '::text) AS noncomposed_roles_names_en,
            	   string_agg(DISTINCT related_noncomposed_role.name_fr::text, ', '::text) AS noncomposed_roles_names_fr,
            	   string_agg(DISTINCT related_composed_role.name_en::text, ', '::text) AS composed_roles_names_en,
            	   string_agg(DISTINCT related_composed_role.name_fr::text, ', '::text) AS composed_roles_names_fr

                        FROM role
                        INNER JOIN role_role_asso rrasso_noncomposed
                          ON rrasso_noncomposed.handler_role_id = role.id
            			INNER JOIN role AS related_noncomposed_role
            			  ON rrasso_noncomposed.handled_role_id = related_noncomposed_role.id
                        INNER JOIN role_role_asso rrasso_composed
                          ON rrasso_composed.handler_role_id = role.id
            			INNER JOIN role AS related_composed_role
            			  ON rrasso_composed.handled_role_id = related_composed_role.id
                        WHERE
                              role.composed = 't'
            			AND   related_noncomposed_role.composed = 'f'
            			AND   related_composed_role.composed = 't'
            		    GROUP BY
            				role.id
            )
            SELECT
                role.id,
            	role.code_name,
                role.restricted_to_appuser_type,
                role.name_en,
                role.name_fr,
            	roles_assos.noncomposed_roles_code_names,
            	roles_assos.composed_roles_code_names,
            	roles_assos.noncomposed_roles_names_en,
            	roles_assos.noncomposed_roles_names_fr,
            	roles_assos.composed_roles_names_en,
            	roles_assos.composed_roles_names_fr
            FROM role
            LEFT JOIN roles_assos
              ON role.id = roles_assos.role_id
            WHERE
              role.composed = 't'
"

        result = PostgresqlDAO.Controller.
            execute_plain_query(queryString,
                                      missing, # queryArgs
                                      dbconn)
        commitDBTransaction(dbconn)
        return(result)
    catch e
        rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end

end
