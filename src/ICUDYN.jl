module ICUDYN


greet() = print("Hello World!")


module Model

    using Dates, TimeZones, UUIDs, PostgresqlDAO, PostgresqlDAO.Model
    using ..Enums, ..Enums.AppUserType, ..Enums.RoleCodeName,
end

module DAO
    using ..Model, PostgresqlDAO
end

module Controller

    using ..OQS, ..Model, ..OQSUtil, ..Enums, ..Enums.OrigineDonnees
    using PostgresqlDAO, PostgresqlDAO.Controller,
          PostgresqlDAO.Model.Enums.CRUDType,
          Tables, LibPQ, Dates


    module Utilisateur
      using MD5, JSON, JWTs
      using EzXML, Dates, TimeZones, Distributed, CSV
      using PostgresqlDAO,
            PostgresqlDAO.PostgresqlDAOUtil,
            PostgresqlDAO.Model.Enums.CRUDType, LibPQ
      using ..Model, ..OQSUtil, ..Controller, ..OQS, ..Enums.AppUserType,
            ..Enums.RoleCodeName
      # include("./controller/utilisateur/Role-controller.jl")
      # include("./controller/utilisateur/AppUser-controller.jl")
    end
end

end # module
