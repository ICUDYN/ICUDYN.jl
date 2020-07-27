using ICUDYN.Controller.User

function User.setJWT!(appuser::AppUser)

    # payload = Dict("roles" => ["role1","role2"],
    #                "email" => "vincent.laugier@tekliko.com")

    payload = Dict("roles" => getproperty.(appuser.allRoles,:codeName),
                   "login" => appuser.login,
                   "firstname" => appuser.firstname,
                   "lastname" => appuser.lastname,
                   "fullname" => appuser.firstname * " " * appuser.lastname,
                   "userId" => appuser.id)

    jwt = JWT(;payload=payload)

    keyset = JWKSet(getConf("security","jwt_signing_keys_uri"));
    refresh!(keyset)
    keyid = first(first(keyset.keys))

    sign!(jwt, keyset, keyid)
    appuser.jwt = string(jwt)

end

function User.enrichWithMD5Password!(appuser::AppUser)

    if !ismissing(appuser.password) && length(appuser.password) != 32
        appuser.password = bytes2hex(md5(appuser.password))
    end
end

function Controller.prePersist!(appuser::AppUser)
    User.enrichWithMD5Password!(appuser)
end

function Controller.preUpdate!(appuser::AppUser)
    User.enrichWithMD5Password!(appuser)
end


function Controller.updateVectorProps!(object::AppUser,
                                       dbconn::LibPQ.Connection
                                      ;editor::Union{AppUser, Missing} = missing)
    User.updateAppUserRoleAssos!(object,dbconn
                           ;editor = editor)

    # On recharge les roles pour casser la réfeéence cyclique :
    #   AppUserRoleAsso - AppUser - AppUserRoleAsso - etc...
    #   qui empêche la serialisation JSON
    User.enrichUserWithRoles!(object,dbconn)
end

function Controller.enrichWithVectorProps!(object::AppUser,
                                dbconn::LibPQ.Connection)
    User.enrichUserWithRoles!(object,dbconn)
end

function User.updateAppUserRoleAssos!(object::AppUser,
                                 dbconn::LibPQ.Connection,
                                ;editor::Union{AppUser, Missing} = missing)

    PostgresqlDAO.Controller.update_vector_property!(object, # updated_object
                             :composedRolesAssos, # updated_property
                             dbconn;
                             editor = editor)

end

function User.enrichUserWithRoles!(appuser::AppUser,
                              dbconn::Union{Missing, LibPQ.Connection} = missing)

    # Open a db connection if none is given in argument
    need_to_close_dbconn = false
    if ismissing(dbconn)
        dbconn = openDBConnAndBeginTransaction()
        need_to_close_dbconn = true
    end

    try
        #
        # Retrieve the composed roles
        #
        filterObjectFor_rolesAssos = AppUserRoleAsso(;appuser = appuser)
        appuserRoleAssos = PostgresqlDAO.Controller.
            retrieve_entity(filterObjectFor_rolesAssos,
                             true, # Retrieve_complex_props, so that
                                   #   we get the details of the role
                             dbconn)
        appuser.composedRolesAssos = appuserRoleAssos

        # Initialize with the composed roles
        appuser.allRoles = getproperty.(appuser.composedRolesAssos,:role)

        #
        # Add the the user type as a role
        #
        appuserTypeAsRoleCodeName =
            string2enum(RoleCodeName.ROLE_CODE_NAME,string(appuser.appuserType))
        push!(appuser.allRoles, Role(codeName = appuserTypeAsRoleCodeName))

        #
        # Retrieve the non-composed roles as well
        #
        for composedRole in getproperty.(appuser.composedRolesAssos, :role)

            filterObjectForRoleRoleAssos = RoleRoleAsso(;handlerRole = composedRole)

            roleRoleAssos = PostgresqlDAO.Controller.
                retrieve_entity(filterObjectForRoleRoleAssos,
                                                true, # Retrieve_complex_props, so that
                                                      #   we get the details of the role
                                                dbconn)

            handledRoles =
                getproperty.(roleRoleAssos,
                             :handledRole)

            # Only keep the non composed roles
            filter!(x -> x.composed == false, handledRoles)
            push!(appuser.allRoles, handledRoles...)

        end

        if need_to_close_dbconn
            commitDBTransaction(dbconn)
        end
        return appuser

    catch e
        rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        # Close the connection if needed
        if need_to_close_dbconn
            closeDBConn(dbconn)
        end
    end

end


function User.authenticate(login::String, password::String)
    filterUser = AppUser(;login = login,
                         password = bytes2hex(md5(password)))
    appuser = Controller.retrieveOneEntity(filterUser,
                                            true # includeVectorProps
                                            )

    if ismissing(appuser)
        return(missing)
    end

    User.setJWT!(appuser)

    return(appuser)
end


function User.getAllUsers(appuser::AppUser)

    dbconn = openDBConnAndBeginTransaction()


    try
        # NOTE: Cannot make an alias with uppercase like 'user.creationTime',
        #         it arrives null on the client side.

        queryString = ""
        queryArgs = []

        queryString *= "SELECT appuser.id AS \"appuser_id\",
            appuser.lastname AS \"appuser_lastname\",
            appuser.firstname AS \"appuser_firstname\",
            appuser.login AS \"appuser_login\",
            appuser.avatar_id AS \"appuser_avatar_id\",
            appuser.creation_time AS \"appuser_creation_time\",
            appuser.update_time AS \"appuser_update_time\",
            appuser.appuser_type AS \"appuser_type\",
            STRING_AGG(DISTINCT role.code_name, ', ')  AS \"appuser_roles\",
            STRING_AGG(DISTINCT role.name, ', ')  AS \"appuser_roles_names\"
            FROM usersch.appuser appuser "

        queryString *= "
                INNER JOIN usersch.appuser_role_asso role_asso
                    ON appuser.id = role_asso.appuser_id
                INNER JOIN usersch.role role
                    ON role.id = role_asso.role_id"

        # Les utilisateurs 'exploitant' ne peuvent voir que les utilisateurs 'exploitant'
        if !hasRole(appuser,RoleCodeName.collaborateur_direction_transport)
            queryString *= "
                WHERE appuser.appuser_type = 2
            "
        end

        queryString *= "
            GROUP BY appuser.id,
                     appuser.lastname,
                     appuser.firstname,
                     appuser.login,
                     appuser.avatar_id,
                     appuser.creation_time,
                     appuser.update_time "

         result = PostgresqlDAO.Controller.
            execute_plain_query(queryString,
                                queryArgs, # query_args
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
