module TestJETLS

# from JETLS/test/jsjl-utils.jl
#      JETLS/test/utils/test_jl_syntax_macros.jl
include("Utils.jl")

# from JETLS/test/analysis/test_TypeAnnotation.jl
include("Analysis.jl")

# from JETLS/test/test_completions.jl
include("Completions.jl")

# from JETLS/test/test_code_lens.jl
include("HandleCodeLens.jl")

# from JETLS/test/test_code_action.jl
include("CodeActions.jl")

end # module TestJETLS
