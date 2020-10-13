@testset "Test Utilisateur.createAppuser!" begin
   # createAppuser!(newObject::AppUser, creator::AppUser)
end

@testset "Test Utilisateur.authenticate" begin
   Controller.Utilisateur.authenticate("exploitant", "test1234")
end

@testset "Test retrieveOneEntity" begin

   superadmin = Controller.
      retrieveOneEntity(AppUser(login = "superadmin")
                       ;includeVectorProps = true)
end


@testset "Test update!" begin
   superadmin = Controller.
      retrieveOneEntity(AppUser(login = "superadmin")
                       ;includeVectorProps = true)
   superadmin.preferences = Dict("tata" => 5)
   Controller.update!(superadmin)
end


@testset "Test Utilisateur.getAllUsers" begin
   superadmin =
      Controller.retrieveOneEntity(AppUser(login = "superadmin")
                               ;includeVectorProps = true)
   Utilisateur.getAllUsers(superadmin)
end
