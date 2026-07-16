module test_jetls_hover

using Test
using TestJETLS.Hovers: hover_test

# from JETLS/test/test_hover.jl

text = """
    let x│s = collect(1:10)
        Any[Core.Const(x) for x in xs]
    end
"""
hover_test(text, "(local) xs")

text = """
    let xs = c│ollect(1:10)
        Any[Core.Const(x) for x in xs]
    end
"""
hover_test(text, "collect(1:10)")

text = """
    let xs = collect(1:10)
        Any[Core.Const(x│) for x in xs]
    end
"""
hover_test(text, "(local) x")

end # module test_jetls_hover
