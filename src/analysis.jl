module Analysis # TestJETLS

using Test
using JETLS: JETLS
using .JETLS: JS
using .JETLS: TypeAnnotation as TA

# Run the full pipeline a typical caller would: parse → lower → infer, then
# wrap the thunk's inferred tree (and `st3`, used to identify user-written
# return values) in an `InferredTreeContext` ready for byte-range queries.
# Returns `(fi, ctx)` so the test can also access `fi` for `xy_to_offset` etc.
function type_annotate(code::AbstractString, mod::Module = Main; expect_degrade::Bool=false)
    fi = JETLS.FileInfo(1, code, @__FILE__)
    st0_top = JETLS.build_syntax_tree(fi)
    st3_ref = Ref{JETLS.SyntaxTreeC}()
    inferred = Ref{JETLS.SyntaxTreeC}()
    JETLS.iterate_toplevel_tree(st0_top) do st0::JS.SyntaxTree
        result = @something TA.get_inferrable_tree(st0, mod) return nothing
        (; ctx3, st3) = result
        st3_ref[] = st3
        inferred[] = TA.infer_toplevel_tree(ctx3, st3, mod)
        return nothing
    end
    if expect_degrade
        @test !isassigned(inferred)
        return nothing
    else
        @test isassigned(inferred)
    end
    return fi, TA.InferredTreeContext(inferred[], st3_ref[])
end

# Byte range of the literal substring `s` inside `code`, in `JS.byte_range`
# coordinates. Tests use ASCII so char and byte indices coincide.
range_of(code::AbstractString, s::AbstractString) =
    @something findfirst(s, code) error(lazy"`$s` is not found in $code")

end # module TestJETLS.Analysis
