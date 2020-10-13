ICUDYN.greet()

ICUDYNUtil.getDataDir()

RoleCodeName.doctor

let
queryString = "select uuid,pgp_sym_decrypt(firstname_crypt,'super long key') from patient WHERE lower(pgp_sym_decrypt(firstname_crypt,'super long key')) = 'vincent'"
ICUDYNUtil.openDBConnectionAndExecuteQuery(queryString,[])

end
