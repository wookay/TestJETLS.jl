module Completions # TestJETLS

using Test
using JETLS: JETLS
using .JETLS: CompletionItem

# from JETLS/test/test_completions.jl

module lowering_module
end

function get_cursor_bindings(
        fi::JETLS.FileInfo, b::Int;
        context_module::Module = lowering_module,
        soft_scope::Bool = false,
        world::UInt = Base.get_world_counter()
    )
    st0 = JETLS.build_syntax_tree(fi)
    cb = JETLS.cursor_bindings(st0, b, context_module, world; soft_scope)
    return isnothing(cb) ? [] : cb
end

function get_cursor_bindings(marked_text::AbstractString; kwargs...)
    text, positions = JETLS.get_text_and_positions(marked_text)
    fi = JETLS.FileInfo(#=version=#0, text, @__FILE__)
    b = JETLS.xy_to_offset(fi, positions[1])
    return get_cursor_bindings(fi, b; kwargs...)
end

function get_local_completions(s::AbstractString, b::Int)
    uri = JETLS.URIs2.filepath2uri(@__FILE__)
    fi = JETLS.FileInfo(#=version=#0, s, @__FILE__)
    return map(get_cursor_bindings(fi, b)) do ((bi, st, dist))
        JETLS.to_completion(bi, st, dist, uri, fi)
    end
end

# Test that completion vector contains CompletionItems with all of `expected`
# labels (with `kind` if provided).
# Note that completions are filtered on the client side, so we expect a completion
# for "x" in "let x = 1; abc|; end"
function cv_has(cs::Vector{CompletionItem}, expected; kind=nothing)
    cdict = Dict(zip(map(c -> c.label, cs), cs))
    for e in expected
        if e isa String
            name = e
            f = nothing
        else
            f, name = e
        end
        c = get(cdict, name, nothing)
        @test !isnothing(c)
        if !isnothing(c)
            if !isnothing(kind)
                @test JETLS.completion_is(c, kind)
            end
            isnothing(f) || f(c)
        end
    end
end

# Test that completion vector does not contain any of `unexpected` labels.
function cv_nhas(cs::Vector{CompletionItem}, unexpected)
    cnames = Set(map(cs -> cs.label, cs))
    for ne in unexpected
        @test !(String(ne) in cnames)
    end
end

function with_completion(f, text::String; kwargs...)
    clean_code, positions = JETLS.get_text_and_positions(text; kwargs...)
    for (i, pos) in enumerate(positions)
        cv = get_local_completions(clean_code, JETLS.xy_to_offset(clean_code, pos, @__FILE__))
        f(i, cv)
    end
end

# shorthand for testing single cursor completion
function test_single_cv(
        code::String, expected::Vector{String};
        unexpected::Vector{String} = String[], kind = nothing,
        matcher::Regex = r"│", kwargs...
    )
    @assert count(matcher, code) == 1 "test_single_cv requires exactly one cursor marker"
    with_completion(code; matcher, kwargs...) do _, cv
        cv_has(cv, expected; kind)
        cv_nhas(cv, unexpected)
    end
end

end # module TestJETLS.Completions
