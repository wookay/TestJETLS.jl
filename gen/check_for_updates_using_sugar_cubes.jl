# check_for_updates_using_sugar_cubes.jl

using Test
using SugarCubes: code_block_with, has_diff
# https://github.com/wookay/SugarCubes.jl

function check_the_code_block_diff(src_path::String,
                                   src_signature::Expr,
                                   dest_path::String,
                                   dest_signature::Expr ;
                                   skip_lines = (src = Int[], dest = Int[]))
    printstyled(stdout, "✔ ", color = :blue)
    print(stdout, " ", basename(src_path), " ")
    src_filepath = normpath(@__DIR__, "..", src_path)
    dest_filepath = normpath(@__DIR__, "..", dest_path)
    @test isfile(src_filepath)
    @test isfile(dest_filepath)
    src_block = code_block_with(; filepath = src_filepath, signature = src_signature)
    (depth, kind, sig) = src_block.signature.layers[end]
    printstyled(stdout, sig.args[1], color = :cyan)
    dest_block = code_block_with(; filepath = dest_filepath, signature = dest_signature)
    @test has_diff(src_block, dest_block; skip_lines) === false
    println(stdout)
end

check_the_code_block_diff(
    "sources/JETLS/test/analysis/test_TypeAnnotation.jl",
    :(module test_type_annotation function type_annotate(code::AbstractString, context_module::Module = type_annotate_module) end end),
    "src/Analysis.jl",
    :(module Analysis             function type_annotate(code::AbstractString, context_module::Module = type_annotate_module) end end),
    skip_lines = (src = [3], dest = [3])
)

for f in [:(function get_lowering_diagnostics(
                text::AbstractString;
                code::Union{AbstractString,Nothing} = nothing,
                context_module::Module = lowering_module,
                world::UInt = Base.get_world_counter(),
                kwargs...
                ) end),
          :(function get_unused_var_code_actions(marked_text::AbstractString; kwargs...) end)]
    check_the_code_block_diff(
        "sources/JETLS/test/test_code_action.jl", :(module test_code_action $f end),
        "src/CodeActions.jl", :(module CodeActions $f end)
    )
end # for

for f in [:(function get_lowering_diagnostics(
                text::AbstractString;
                code::Union{AbstractString,Nothing} = nothing,
                context_module::Module = lowering_module,
                world::UInt = Base.get_world_counter(),
                kwargs...
                ) end)]
    check_the_code_block_diff(
        "sources/JETLS/test/test_lowering_diagnostic.jl", :(module test_lowering_diagnostics $f end),
        "src/Diagnostic.jl", :(module Diagnostic $f end)
    )
end # for

for f in [:(function get_cursor_bindings(
                fi::JETLS.FileInfo, b::Int;
                context_module::Module = lowering_module,
                soft_scope::Bool = false
                ) end),
          :(function get_cursor_bindings(marked_text::AbstractString; kwargs...) end),
          :(function get_local_completions(s::AbstractString, b::Int) end),
          :(function cv_has(cs::Vector{CompletionItem}, expected; kind=nothing) end),
          :(function cv_nhas(cs::Vector{CompletionItem}, unexpected) end),
          :(function with_completion(f, text::String; kwargs...) end),
          :(function test_single_cv(
                code::String, expected::Vector{String};
                unexpected::Vector{String} = String[], kind = nothing,
                matcher::Regex = r"│", kwargs...
                ) end)]
    check_the_code_block_diff(
        "sources/JETLS/test/test_completions.jl", :(module test_completions $f end),
        "src/Completions.jl", :(module Completions $f end)
    )
end # for

check_the_code_block_diff(
    "sources/JETLS/test/test_code_lens.jl",
    :(module test_code_lens function get_code_lenses_with_counts(code::AbstractString) end end),
    "src/HandleCodeLens.jl",
    :(module HandleCodeLens function get_code_lenses_with_counts(code::AbstractString) end end)
)

for ex in [:(macro expect_jl_err(ex) end),
           :(function jldebug(context_module::Module, st0_in::JS.SyntaxTree, stop::Int=5) end),
           :(function jlnode(g::JL.SyntaxGraph, i::JS.NodeId) end)]
    check_the_code_block_diff(
        "sources/JETLS/test/jsjl-utils.jl", ex,
        "src/Utils.jl", :(module Utils $ex end)
    )
end # for

for f in [:(function jlexpand(context_module::Module, code::AbstractString) end),
          :(function jlresolve(context_module::Module, code::AbstractString) end)]
    check_the_code_block_diff(
        "sources/JETLS/test/utils/test_jl_syntax_macros.jl", f,
        "src/Utils.jl", :(module Utils $f end)
    )
end # for
