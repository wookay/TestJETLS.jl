module Hovers # JETLS

using Test
using JETLS: JETLS, Hover, Position, filename2uri

# from JETLS/test/test_hover.jl
function get_hover(
        text::AbstractString, pos::Position;
        filename::AbstractString = @__FILE__,
        context_module::Union{Nothing,Module} = nothing
    )
    server = JETLS.Server()
    uri = filename2uri(filename)
    fi = JETLS.cache_file_info!(server, uri, 0, text)
    return JETLS.get_hover(server.state, fi, uri, pos; context_module)
end

function hover_test(
        text::AbstractString, pat::Union{AbstractString, Regex, Nothing};
        context_module::Union{Nothing,Module} = nothing,
        notpat::Union{AbstractString, Regex, Nothing} = nothing,
        broken::Bool = false
    )
    clean_text, positions = JETLS.get_text_and_positions(text)
    @assert length(positions) == 1
    result = get_hover(clean_text, only(positions); context_module)
    if pat === nothing
        @test result === nothing broken=broken
    else
        @test result isa Hover broken=broken
        @test occursin(pat, result.contents.value) broken=broken
        notpat === nothing ||
            @test !occursin(notpat, result.contents.value) broken=broken
    end
end

end # JETLS.Hovers
