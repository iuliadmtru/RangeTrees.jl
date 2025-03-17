#=
    Testing.
=#

using JuliaLowering

function RangeNode(ast::JuliaLowering.SyntaxTree; parent::Union{RangeNode, Nothing}=nothing)
    root = RangeNode(JuliaLowering.first_byte(ast):JuliaLowering.last_byte(ast), parent, ast.source.green_tree)

    if isnothing(JuliaLowering.children(ast))
        # @info "return no children" root
        return root
    end

    for child in JuliaLowering.children(ast)
        child_node = RangeNode(child; parent=root)
        # @info "here" child_node
        insert!(root, child_node)
    end
    # @info "finished children for" ast

    # @info "return" root
    return root
end
