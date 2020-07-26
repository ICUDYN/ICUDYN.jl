module AppUserType
    export APPUSER_TYPE
    @enum APPUSER_TYPE begin
         collaborateur_direction_transport = 1
         collaborateur_exploitant = 2
    end
end

module RoleCodeName
    export ROLE_CODE_NAME
    @enum ROLE_CODE_NAME begin

        # Equivalents to AppUserTypes (for convenience, so that we can use
        # function 'hasRole()')
        collaborateur_direction_transport = 1001
        collaborateur_exploitant = 1002

        # Composed roles
        superadmin = 1
        utilisateur_classique_exploitant = 2

        # Non-composed roles
        peut_creer_un_utilisateur = 101
        peut_accorder_une_exoneration = 102
        peut_modifier_la_configuration = 103

    end
end
