mutable struct AppUser <: IAppUser
    id::Union{Missing,String}
    login::Union{Missing,String}
    password::Union{Missing,String}
    lastname::Union{Missing,String}
    firstname::Union{Missing,String}
    email::Union{Missing,String}
    jwt::Union{Missing,String}

    composedRolesAssos::Union{Missing,Vector{IAppUserRoleAsso}}

    languageCode::Union{Missing,String}
    appuserType::Union{Missing,AppUserType.APPUSER_TYPE}

    avatar::Union{Missing,IFile}

    preferences::Union{Missing,Dict}

    # Convenience attribute for storing all the roles of the appuser (the
    # composed and their children).
    # NOTE: not persisted to database
    allRoles::Union{Missing,Vector{IRole}}

    creator::Union{Missing,IAppUser}
    lastEditor::Union{Missing,IAppUser}
    creationTime::Union{DateTime,Missing}
    updateTime::Union{DateTime,Missing}

    # Do not use the following contructor because it gets into conflict with
    #   the one with optional arguments :
    # AppUser() = new(missing,missing,missing,missing,missing,missing,missing)

    # Convenience constructor that allows us to create a vector of instances
    #   from a JuliaDB.table using the dot syntax: `Myclass.(a_JuliaDB_table)`
    AppUser(args::NamedTuple) = AppUser(;args...)
    AppUser(;id = missing,
             login = missing,
             password = missing,
             lastname = missing,
             firstname = missing,
             email = missing,
             jwt = missing,
             composedRolesAssos = missing,
             languageCode = missing,
             appuserType = missing,
             avatar = missing,
             preferences = missing,
             allRoles = missing,
             creator = missing,
             lastEditor = missing,
             creationTime = missing,
             updateTime = missing) = (
                  # First call the default constructor with missing values only so that
                  #   there is no risk that we don't assign an argument to the wrong attribute
                  x = new(missing,missing,missing,missing,missing,
                          missing,missing,missing,missing, missing,
                          missing,missing,missing,
                          missing,missing, missing, missing);
                  x.id = id;
                  x.login = login;
                  x.password = password;
                  x.lastname = lastname;
                  x.firstname = firstname;
                  x.email = email;
                  x.jwt = jwt;
                  x.appuserType = appuserType;
                  x.composedRolesAssos = composedRolesAssos;
                  x.languageCode = languageCode;
                  x.avatar = avatar;
                  x.preferences = preferences;
                  x.allRoles = allRoles;
                  x.creator = creator;
                  x.lastEditor = lastEditor;
                  x.creationTime = creationTime;
                  x.updateTime = updateTime;

                  return x )

end
