# using Revise

using Mux
using JSON
using HTTP
using Serialization
using JWTs

jwtkeyset = JWKSet(getConf("security","jwt_signing_keys_uri"));
refresh!(jwtkeyset)
jwtkeyid = first(first(jwtkeyset.keys))

# Set the apis that will not be checked for a valid JWT
# This is a vector of strings vectors because we compare paths and not URIs
# eg: URIs '/unsecure/authenticate/' and  '/unsecure/authenticate' will have the
#     same following path: ["unsecure","authenticate"]
apis_paths_wo_jwt = [
  ["authenticate"],
  ["file-upload","get-file-inreqauth"]
  # ["message","getLastMessagesOfDesigns"]
 ]

# Initialize the tuple of routes
api_routes = ()
mux_filters = ()
# Loop over the files in "/src/web/" to populate the  api routes and the mux filters
folderFor_web_src = pwd() * "/src/web/"
for f in filter(x -> occursin(r".jl$", x),
                readdir(pwd() * "/src/web"))
  # println(f)
  include(folderFor_web_src * f)
end

function respFor_OPTIONS_req()

  Dict(
     :headers => Dict("Access-Control-Allow-Origin" => "*" ,
                      "Access-Control-Allow-Headers" => "origin, content-type, accept, authorization",
                      "Access-Control-Allow-Credentials" => "true",
                      "Access-Control-Allow-Methods" => "GET, POST, PUT, DELETE, OPTIONS, HEAD"
                  )
      )

end

@app web_api = (
  Mux.defaults,
  mux_filters...,
  api_routes...,
  # stack(access_control_allow_origin),

  # eg.
  # curl -d '{"key1":"value1", "key2":"value2"}' -H "Content-Type: application/json" -X POST http://localhost:8082/testjson/process/
  route("/testjson/process/", req -> begin
    obj = JSON.parse(String(req[:data]))

    @show req

    Dict(:body => String(JSON.json(obj)),
         :headers => Dict("Content-Type" => "application/json")
         )
  end),

  Mux.notfound())
