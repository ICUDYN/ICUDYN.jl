RefiningFunctionAllowedValueType = Union{String,Number,Missing,DateTime}
RefiningFunctionResult = Dict{Symbol,RefiningFunctionAllowedValueType}

RefinedModuleResults = Dict{Symbol,RefiningFunctionAllowedValueType}

RefinedWindow = Dict{Module, Any}