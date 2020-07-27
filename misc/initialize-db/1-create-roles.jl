using ICUDYN.Enums
using ..Enums.AppUserType, ..Enums.RoleCodeName
using ICUDYN.Controller.User

#
# Create composed Roles
#

# doctor
role_doctor = Role(;codeName = RoleCodeName.doctor,
                        name="doctor",
                        composed = true,
                        restrictedToAppUserType = AppUserType.healthcare_professional)
persist!(role_doctor)


#
# Create non-composed Roles
#
can_modify_user = Role(;codeName = RoleCodeName.can_modify_user, composed = false)
persist!(can_modify_user)


#
# Create assos between roles
#

# Retrieve all non-composed roles so that we have them at hand
can_modify_user = retrieveOneEntity(Role(codeName = RoleCodeName.can_modify_user, composed = false))

# Retrieve all composed roles so that we have them at hand
role_doctor = retrieveOneEntity(Role(codeName = RoleCodeName.doctor,composed = true))

# Create roles-assos for composed role 'superadmin'
role_doctor.roleRoleAssos_as_handler = [
      # Assos to non-composed roles
      RoleRoleAsso(;handledRole = can_modify_user),

      # Assos to composed roles
      RoleRoleAsso(;handledRole = role_doctor),
      ]
update!(role_doctor; updateVectorProps = true)
