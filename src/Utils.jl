module Utils # TestJETLS

# from JETLS/test/jsjl-utils.jl

using JETLS: JS, JL

function parsedstream(s::AbstractString; rule::Symbol=:all)
    stream = JS.ParseStream(s)
    JS.parse!(stream; rule)
    return stream
end

jsparse(s::AbstractString; rule::Symbol=:all, kwargs...) = jsparse(parsedstream(s; rule); kwargs...)
jsparse(parsed_stream::JS.ParseStream; filename::AbstractString=@__FILE__, first_line::Int=1) =
    JS.build_tree(JS.SyntaxNode, parsed_stream; filename, first_line)

jlparse(s::AbstractString; rule::Symbol=:all, kwargs...) = jlparse(parsedstream(s; rule); kwargs...)
jlparse(parsed_stream::JS.ParseStream; filename::AbstractString=@__FILE__, first_line::Int=1) =
    JS.build_tree(JS.SyntaxTree, parsed_stream; filename, first_line)

macro expect_jl_err(ex)
    if JETLS.JETLS_DEBUG_LOWERING
        :(mktemp() do path, io
            val = redirect_stderr(io) do
                $(esc(ex))
            end
            flush(io)
            @test !isempty(read(path, String))
            val
        end)
    else
        esc(ex)
    end
end

# For interactive use
# ===================

# dump all intermediate ctx and st into the global scope for inspection
# use `stop` if some lowering pass mutates ctx in a way you don't want
function jldebug(mod::Module, st0_in::JS.SyntaxTree, stop::Int=5)
    global st0 = st0_in
    global st1, st2, st3, st4, st5
    global ctx1, ctx2, ctx3, ctx4, ctx5
    ctx0 = nothing
    (stop -= 1) < 0 && return ctx0, st0; ctx1, st1 = JL.expand_forms_1(mod, st0_in, true, Base.get_world_counter())
    (stop -= 1) < 0 && return ctx1, st1; ctx2, st2 = JL.expand_forms_2(ctx1, st1)
    (stop -= 1) < 0 && return ctx2, st2; ctx3, st3 = JL.resolve_scopes(ctx2, st2)
    (stop -= 1) < 0 && return ctx3, st3; ctx4, st4 = JL.convert_closures(ctx3, st3)
    (stop -= 1) < 0 && return ctx4, st4; ctx5, st5 = JL.linearize_ir(ctx4, st4)
    return ctx5, st5
end
jldebug(mod::Module, s::AbstractString, stop::Int=5) = jldebug(mod, jlparse(s; rule=:statement), stop)
jldebug(args...) = jldebug(@__MODULE__, args...)

# Select a node by ID from a tree (its underlying graph), graph, or ctx
function jlnode(g::JL.SyntaxGraph, i::JS.NodeId)
    t = JS.SyntaxTree(g, i)
    # show(stdout, MIME("text/x.sexpression"), t)
    return t
end
function jlnode(st::JS.SyntaxTree, i::JS.NodeId)
    return JS.SyntaxTree(st._graph, i)
end
function jlnode(ctx::T where {T<:JL.AbstractLoweringContext}, i::JS.NodeId)
    return JS.SyntaxTree(ctx.graph, i)
end


# from JETLS/test/utils/test_jl_syntax_macros.jl

module lowering_module
end

function jlexpand(mod::Module, code::AbstractString)
    st0 = jlparse(code; rule=:statement)
    world = Base.get_world_counter()
    _, st1 = JL.expand_forms_1(mod, st0, true, world)
    return st1
end
jlexpand(code::AbstractString) = jlexpand(lowering_module, code)

function jlresolve(mod::Module, code::AbstractString)
    st0 = jlparse(code; rule=:statement)
    world = Base.get_world_counter()
    return JETLS.jl_lower_for_scope_resolution(mod, st0, world;
        recover_from_macro_errors=false, convert_closures=true)
end
jlresolve(code::AbstractString) = jlresolve(lowering_module, code)

module test_lowering_module
    using Test
end
test_macro_expand(code::AbstractString) = jlexpand(test_lowering_module, code)
test_macro_lower(code::AbstractString) = jlresolve(test_lowering_module, code)

end # module TestJETLS.Utils
