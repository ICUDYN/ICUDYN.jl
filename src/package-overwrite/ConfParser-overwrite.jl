using ConfParser
function ConfParser.parse_line(line::String)
    parsed   = String[]
    splitted = split(line, ",")
    for raw = splitted
        if occursin(r"\S+", raw)
            clean = strip(raw)
            push!(parsed, clean)
        end
    end
    parsed
end
