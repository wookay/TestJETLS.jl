module test_jetls_hover

using Test
using TestJETLS.Hovers: hover_test

# from JETLS/test/test_hover.jl
hover_test("""
    let xs = collect(1:10)
        Any[Core.Const(x│) for x in xs]
    end
""", "(local) x")

end # module test_jetls_hover
