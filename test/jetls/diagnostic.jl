module test_jetls_diagnostic

using Test
using JETLS: LSP
using TestJETLS.Diagnostic: get_lowering_diagnostics

# from JETLS/test/test_lowering_diagnostic.jl

diagnostics = get_lowering_diagnostics("""
    y = let x = 42
        sin(42)
    end
    """)
d1 = only(diagnostics)
@test d1 isa LSP.Diagnostic
@test d1.message == "Unused local binding `x`"


diagnostics = get_lowering_diagnostics("""
import Test: @testset
macro testset(_expr::Expr...)
end
    """)
@test isempty(diagnostics)


diagnostics = get_lowering_diagnostics("""
module M
macro m1(expr)
    println(expr)
end
end # module M

import .M: @m1

macro m1(expr::Expr)
    println("expr: ", expr)
end
    """)
@test isempty(diagnostics)


diagnostics = get_lowering_diagnostics("""
abstract type AbstractScopedValue{T} end
struct LazyScopedValue{T} <: AbstractScopedValue{T}
end
function f(::AbstractScopedValue{T}) where T
end
f(LazyScopedValue{Int}())
""")
(d1, ) = diagnostics
@test d1.message == "`TestJETLS.Diagnostic.lowering_module.AbstractScopedValue` is not defined"
# @test d1.message == "Value assigned to `T` is never used"

end # module test_jetls_diagnostic
