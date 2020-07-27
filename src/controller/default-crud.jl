"Action qui précède la mise à jour d'un objet IEntity dans la base de données"
function preUpdate!(object::T) where T <: PostgresqlDAO.Model.IEntity end
"Action qui précède l'ajout d'un objet IEntity dans la base de données"
function prePersist!(object::T) where T <: PostgresqlDAO.Model.IEntity end
"Action qui succède à la mise à jour d'un objet IEntity dans la base de données"
function postUpdate(object::T) where T <: PostgresqlDAO.Model.IEntity end
"Action qui succède à l'ajout d'un objet IEntity dans la base de données"
function postPersist(object::T) where T <: PostgresqlDAO.Model.IEntity end

"Enrichit un objet IEntity avec ses attributs de type Vector"
function enrichWithVectorProps!(object::T,
                                dbconn::LibPQ.Connection) where T <: PostgresqlDAO.Model.IEntity
   # À surcharger si besoin
end

"Met à jour les attributs de type Vector d'un objet IEntity"
function updateVectorProps!(object::T,
                            dbconn::LibPQ.Connection
                           ;editor::Union{Missing, AppUser} = missing) where T <: PostgresqlDAO.Model.IEntity
   # À surcharger si besoin
end

"Ajoute un objet IEntity dans la base de données"
function persist!(newObject::T
                 ;creator::Union{Missing, AppUser} = missing) where T <: PostgresqlDAO.Model.IEntity

    prePersist!(newObject)
    # @info "default persist!"
    dbconn = openDBConnAndBeginTransaction()
    try
       create_entity!(newObject,
                       dbconn;
                       creator = creator)
       # Il n y a pas de risque à faire la mise à jour des attributs de type liste
       #   vu que l'objet n'existe pas encore
       updateVectorProps!(newObject, dbconn
                         ;editor = creator)
       commitDBTransaction(dbconn)
       postPersist(newObject)
       return newObject
   catch e
      rollbackDBTransaction(dbconn)
      rethrow(e)
   finally
      closeDBConn(dbconn)
   end

end


"Met à jour un objet IEntity dans la base de données"
function update!(object::T
                ;updateVectorProps::Union{Missing, Bool} = false,
                 editor::Union{Missing, AppUser} = missing) where T <: PostgresqlDAO.Model.IEntity

    preUpdate!(object)

    dbconn = openDBConnAndBeginTransaction()

    try

        # Update the entity itself
        update_entity!(object,
                       dbconn
                      ;editor = editor)

        # Update the associations
        if updateVectorProps
            updateVectorProps!(object, dbconn
                              ;editor = editor)
        end

        commitDBTransaction(dbconn)
        postUpdate(object)
        return object
    catch e
        rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end
end

"Récupération d'un objet de type IEntity sur la base d'un filtre"
function retrieveOneEntity(filterObject::T) where T <: PostgresqlDAO.Model.IEntity
    retrieveOneEntity(filterObject
                     ;includeVectorProps = false)
end

function retrieveOneEntity(filterObject::T,
                          includeVectorProps::Bool) where T <: PostgresqlDAO.Model.IEntity
    retrieveOneEntity(filterObject
                     ;includeVectorProps = includeVectorProps)
end

function retrieveOneEntity(filterObject::T
                          ;includeVectorProps::Bool = false) where T <: PostgresqlDAO.Model.IEntity
      results = retrieveEntities(filterObject
                                ;includeVectorProps = includeVectorProps)
      if length(results) > 1
          error("Trop de résultats")
      end
      if length(results) == 0
          return missing
      end
      result = results[1]
      return result
end

"Récupération des objets de type IEntity sur la base d'un filtre"
function retrieveEntities(filterObject::T
                        ;includeVectorProps::Bool = false) where T <: PostgresqlDAO.Model.IEntity
    dbconn = openDBConnAndBeginTransaction()
    try
         result = retrieve_entity(filterObject,
                                 true, # retrieve_complex_props
                                 dbconn)
         # Retrieve other attributes
         if includeVectorProps
             enrichWithVectorProps!.(result, dbconn)
         end
         commitDBTransaction(dbconn)
         return result
    catch e
        rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end
end

"Suppression de la base de données des objets correspondants au filtre IEntity"
function deleteAlike(filterObject::T) where T <: PostgresqlDAO.Model.IEntity
    dbconn = openDBConnAndBeginTransaction()
    try
        delete_entity_alike(filterObject,
                            dbconn)

        commitDBTransaction(dbconn)
    catch e
        rollbackDBTransaction(dbconn)
        rethrow(e)
    finally
        closeDBConn(dbconn)
    end
end

"""
Ajoute un vecteur d'objets IEntity dans la base de données en utilisant la
fonction 'COPY' de Postgresql
"""
function persistInBulkUsingCopy(entities::Vector{T})  where T <: PostgresqlDAO.Model.IEntity

    if isempty(entities)
        @info "Empty vector was passed to persistInBulkUsingCopy. Do nothing"
        return(0)
    end

   dataType = typeof(entities[1])
   dummy = dataType()
   dao = PostgresqlDAO.getdao(dataType())
   tableName = dao.gettablename()

   # @info "default vector persist!"
   dbconn = openDBConnAndBeginTransaction()

   result::Int64 = 0
   try
        props = PostgresqlDAO.Controller.
            util_get_entity_props_for_db_actions(dummy,
                                                 dbconn,
                                                 true # include missing values at insertion
                                                  )
        properties_names = collect(keys(props))
        # Exclude the 'id' property because we don't want to try to insert NULL
        #  as the id, which would fail anyway
        filter!(x -> x != dao.id_property,properties_names)
        column_names = PostgresqlDAO.Controller.
            util_getcolumns(properties_names,dao.columns_selection_and_mapping)

        rowStrings = imap(Tables.rows(entities)) do row
                       rowStringArr = []
                       for p in properties_names

                           propertyValue = getproperty(row,p)

                           # @info "property[$p],
                           #       typeof(propertyValue)[$(typeof(propertyValue))],
                           #       isa(propertyValue, PostgresqlDAO.Model.IEntity)[$(isa(propertyValue, PostgresqlDAO.Model.IEntity))],
                           #       ismissing[$(ismissing(propertyValue))]"

                           if (p == :creationTime)
                               propertyValue = now(Dates.UTC)
                           end

                           if ismissing(propertyValue)
                               # @info "property[$p] is missing"
                               push!(rowStringArr,"")
                           elseif isa(propertyValue, PostgresqlDAO.Model.IEntity)
                              dummyEntity = typeof(propertyValue)()
                              daomodule = getdao(dummyEntity)
                              push!(rowStringArr,
                                    getproperty(propertyValue, daomodule.id_property))
                           else
                               push!(rowStringArr, propertyValue)
                           end
                       end
                       oneRowStr = "$(join(rowStringArr,';'))\n"
                       oneRowStr
                       # "$(row.rechor_id),$(row.rechor_sm),$(row.journeeExploitation)\n"
                     end
        # println(rowStrings)
        copyin =
             LibPQ.CopyIn("COPY $tableName($(join(column_names,',')))
                             FROM STDIN (FORMAT CSV, DELIMITER ';');", rowStrings)

        resultOfExecution = execute(dbconn, copyin; throw_error=false)
        commitDBTransaction(dbconn)

        # Return the number of rows inserted
        result = LibPQ.num_affected_rows(resultOfExecution)

   catch e
      rollbackDBTransaction(dbconn)
      rethrow(e)
   finally
      closeDBConn(dbconn)
   end

   return result

end

# DEPRECATED
function persistInBulkWithoutReturningValues(entities::Vector{T})  where T <: PostgresqlDAO.Model.IEntity

    dataType = typeof(entities[1])
    dummy = dataType()
    dao = PostgresqlDAO.getdao(dataType())
    tableName = dao.gettablename()

    # @info "default vector persist!"
     dbconn = openDBConnAndBeginTransaction()
     try
        props = PostgresqlDAO.Controller.
             util_get_entity_props_for_db_actions(dummy,
                                                  dbconn,
                                                  true # include missing values at insertion
                                                   )
         properties_names = collect(keys(props))
         # Exclude the 'id' property because we don't want to try to insert NULL
         #  as the id, which would fail anyway
         filter!(x -> x != dao.id_property,properties_names)
         column_names = PostgresqlDAO.Controller.
             util_getcolumns(properties_names,dao.columns_selection_and_mapping)

         queryArgs = []
         argsCounter = 0
         entityValuesStrings = []
         for entity in entities
            entityValuesArr = []
             for p in properties_names
                push!(entityValuesArr,"\$$(argsCounter+=1)")
                push!(queryArgs,getproperty(entity,p))
             end
             push!(entityValuesStrings,
                  "(" * join(entityValuesArr,',') * ")")
            #  util_get_entity_props_for_db_actions(dummy,
            #                                               dbconn,
            #                                               true # include missing values at insertion
            #                                                   )
            # properties_values = collect(values(props))
         end



         # Loop over the properties of the object and
         #   build the appropriate list of columns

         commaSeparatedColumnNames = join(column_names,",") # '(lastname,login)'

         queryString = "INSERT INTO $tableName($commaSeparatedColumnNames)
         VALUES $(join(entityValuesStrings,','))"

         # @info queryString
         execute_plain_query(queryString,queryArgs,dbconn)

        commitDBTransaction(dbconn)
        return true
    catch e
       rollbackDBTransaction(dbconn)
       rethrow(e)
    finally
       closeDBConn(dbconn)
    end

end
