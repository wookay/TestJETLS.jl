module Analysis # TestJETLS

# from JETLS/test/analysis/test_TypeAnnotation.jl

using Test
using JETLS: JETLS
using .JETLS: JS
using .JETLS: TypeAnnotation as TA

# Run the full TypeAnnotation pipeline through its exported driver and return
# `(fi, ctx)` for the toplevel containing byte 1 — i.e. the *first* top-level
# statement in `code`. The tests below either pass single-toplevel snippets
# (the common case) or place the statement under test first. `fi` is returned
# so tests can use `xy_to_offset` etc. against the source.
function type_annotate(code::AbstractString, mod::Module = Main)
    fi = JETLS.FileInfo(1, code, @__FILE__)
    st0_top = JETLS.build_syntax_tree(fi)
    ctx = build_inferred_context_at(st0_top, mod, 1:1)
    @test ctx !== nothing
    return fi, ctx
end

# Byte range of the literal substring `s` inside `code`, in `JS.byte_range`
# coordinates. Tests use ASCII so char and byte indices coincide.
range_of(code::AbstractString, s::AbstractString) =
    @something findfirst(s, code) error(lazy"`$s` is not found in $code")

end # module TestJETLS.Analysis
