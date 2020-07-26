mutable struct Role <: IRole

    id::Union{Missing,String}
    codeName::Union{Missing, RoleCodeName.ROLE_CODE_NAME}
    name::Union{Missing,String}
    composed::Union{Bool,Missing}

    restrictedToAppUserType::Union{Missing,AppUserType.APPUSER_TYPE}

    # RoleRoleAssos where this role is the handler role
    roleRoleAssos_as_handler::Union{Missing,Vector{IRoleRoleAsso}}

    # RoleRoleAssos where this role is the handled role
    roleRoleAssosAsHandled::Union{Missing,Vector{IRoleRoleAsso}}

    creator::Union{Missing,IAppUser}
    lastEditor::Union{Missing,IAppUser}
    creationTime::Union{DateTime,Missing}
    updateTime::Union{DateTime,Missing}

    # Convenience constructor that allows us to create a vector of instances
    #   from a JuliaDB.table using the dot syntax: `Myclass.(a_JuliaDB_table)`
    Role(args::NamedTuple) = Role(;args...)
    Role(;id = missing,
          codeName = missing,
          name = missing,
          composed = missing,
          restrictedToAppUserType = missing,
          roleRoleAssos_as_handler = missing,
          roleRoleAssosAsHandled = missing,
          creator = missing,
          lastEditor = missing,
          creationTime = missing,
          updateTime = missing) = (
                x = new(missing,missing,missing,missing,
                        missing,missing,missing,
                        missing,missing,missing,missing);
                x.id = id;
                x.codeName = codeName;
                x.name = name;
                x.composed = composed;
                x.restrictedToAppUserType = restrictedToAppUserType;

                x.roleRoleAssos_as_handler = roleRoleAssos_as_handler;
                x.roleRoleAssosAsHandled = roleRoleAssosAsHandled;

                x.creator = creator;
                x.lastEditor = lastEditor;
                x.creationTime = creationTime;
                x.updateTime = updateTime;
                return x)
end
