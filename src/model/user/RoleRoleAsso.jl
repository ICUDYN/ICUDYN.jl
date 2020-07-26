mutable struct RoleRoleAsso <: IRoleRoleAsso

    id::Union{Missing,String}
    handledRole::Union{Missing,IRole}
    handlerRole::Union{Missing,IRole}

    creator::Union{Missing,IAppUser}
    lastEditor::Union{Missing,IAppUser}
    creationTime::Union{DateTime,Missing}
    updateTime::Union{DateTime,Missing}

    RoleRoleAsso(args::NamedTuple) = RoleRoleAsso(;args...)
    RoleRoleAsso(;id = missing,
                  handledRole = missing,
                  handlerRole = missing,
                  creator = missing,
                  lastEditor = missing,
                  creationTime = missing,
                  updateTime = missing
                  ) = (
                x = new(missing,missing,missing,
                        missing,missing,missing,missing);
                x.id = id;
                x.handledRole = handledRole;
                x.handlerRole = handlerRole;

                x.creator = creator;
                x.lastEditor = lastEditor;
                x.creationTime = creationTime;
                x.updateTime = updateTime;

                return x)
end
