mutable struct FrontendVersion <: IFrontendVersion

    id::Union{Missing,String}
    name::Union{Missing,String}
    forceReloadIfDifferentVersion::Union{Bool,Missing}

    # Convenience constructor that allows us to create a vector of instances
    #   from a JuliaDB.table using the dot syntax: `Myclass.(a_JuliaDB_table)`
    FrontendVersion(args::NamedTuple) = FrontendVersion(;args...)
    FrontendVersion(;id = missing,
                     name = missing,
                     forceReloadIfDifferentVersion = missing) = (
                x = new(missing,missing,missing);
                x.id = id;
                x.name = name;
                x.forceReloadIfDifferentVersion = forceReloadIfDifferentVersion;
                return x)
end
