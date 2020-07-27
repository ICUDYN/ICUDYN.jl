using ICUDYN.Enums
using ..Enums.AppUserType, ..Enums.RoleCodeName
using ICUDYN.Controller.User


#
# Create a doctor AppUser
#

Controller.deleteAlike(AppUser(;login = "elherr"))

doctor = AppUser(;lastname = "L'Herr",
                      login = "doctor",
                      password = "test5678",
                      appuserType = AppUserType.healthcare_professional)

role_doctor = retrieveOneEntity(Role(codeName = RoleCodeName.doctor))
doctor.composedRolesAssos = [AppUserRoleAsso(;role = role_doctor)]
persist!(doctor)


User.authenticate("doctor","test5678")
