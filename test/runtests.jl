using RangeTrees
using Test

using JuliaSyntax: @K_str
using JuliaLowering

@testset "RangeTree{JuliaSyntax}" begin
    code = """
    module N
        const y = 2

        function f(x::Int)
            const y = 2
            x = x + y
            return x
        end
    end
    """
    ex = JuliaLowering.parsestmt(JuliaLowering.SyntaxTree, code);
    root = RangeNode(ex)
    @test root.interval == 1:115
    @test root.data.kind === K"module"
    @test find_node(root, (5, 16)).data.kind === K"="

    code = """
    function fun©țión(α)
        x = α + 2

        (x, 2x)
    end
    """
    ex = JuliaLowering.parsestmt(JuliaLowering.SyntaxTree, code);
    root = RangeNode(ex)
    @test find_node(root, (2, 7)).data.kind === K"="
    @test find_node(root, 36:36).data[2].name_val === "+"
    @test find_node(root, 48:48).data[1].name_val === "x"
    @test find_node(root, (4, 9)).data.kind === K"Identifier"
end