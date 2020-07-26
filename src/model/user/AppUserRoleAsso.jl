mutable struct AppUserRoleAsso <: IAppUserRoleAsso
    id::Union{Missing,String}
    appuser::Union{Missing,IAppUser}
    role::Union{Missing,IRole}

    creator::Union{Missing,IAppUser}
    lastEditor::Union{Missing,IAppUser}
    creationTime::Union{DateTime,Missing}
    updateTime::Union{DateTime,Missing}

    # Do not use the following contructor because it gets into conflict with
    #   the one with optional arguments :
    # AppUser() = new(missing,missing,missing,missing,missing,missing,missing)

    # Convenience constructor that allows us to create a vector of instances
    #   from a JuliaDB.table using the dot syntax: `Myclass.(a_JuliaDB_table)`
    AppUserRoleAsso(args::NamedTuple) = AppUserRoleAsso(;args...)
    AppUserRoleAsso(;id = missing,
                     appuser = missing,
                     role = missing,
                     creator = missing,
                     lastEditor = missing,
                     creationTime = missing,
                     updateTime = missing
                     ) = (
                  # First call the default constructor with missing values only so that
                  #   there is no risk that we don't assign an argument to the wrong attribute
                  x = new(missing,missing,missing,missing,missing,
                          missing,missing);
                  x.id = id;
                  x.appuser = appuser;
                  x.role = role;

                  x.creator = creator;
                  x.lastEditor = lastEditor;
                  x.creationTime = creationTime;
                  x.updateTime = updateTime;
                  
                  return x )

end
