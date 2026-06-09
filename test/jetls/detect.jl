module test_jetls_detect

using Test
using JETLS

ambs = Test.detect_ambiguities(JETLS)
@test !isempty(ambs)

end # module test_jetls_detect
