module AppUserType
    export APPUSER_TYPE
    @enum APPUSER_TYPE begin
         healthcare_professional = 1
         other = 2
    end
end

module RoleCodeName
    export ROLE_CODE_NAME
    @enum ROLE_CODE_NAME begin

        # Equivalents to AppUserTypes (for convenience, so that we can use
        # function 'hasRole()')
        healthcare_professional = 1001
        other = 1002

        # Composed roles
        doctor = 1

        # Non-composed roles
        can_modify_user = 101
    end
end

module JourSemaine
    export JOUR_SEMAINE
    @enum JOUR_SEMAINE begin
         lundi = 1
         mardi = 2
         mercredi = 3
         jeudi = 4
         vendredi = 5
         samedi = 6
         dimanche = 7
    end
end
