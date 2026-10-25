module test_jetlscore_code_action

using Test
using JETLS
const JETLSCore = Base.require(@__MODULE__, :JETLSCore)
using .JETLSCore: JL, JS, LSP

# from JETLS/JETLSCore/test/test_code_action.jl

JETLSCore.get_text_and_positions
@test LSP.PositionEncodingKind.UTF16 == "utf-16"

end # module test_jetlscore_code_action
