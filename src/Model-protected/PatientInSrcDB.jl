Base.@kwdef mutable struct PatientInSrcDB
    srcDBIDs::Vector{Integer}
    firstname::String
    lastname::String
    birthdate::Date
end
