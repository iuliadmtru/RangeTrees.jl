module RangeTrees

# Existing similar package: https://github.com/BioJulia/IntervalTrees.jl. Not maintained, outdated.
# Might be useful: https://github.com/JuliaMath/IntervalSets.jl

export RangeNode
export find_node, find_nodes

using AbstractTrees
using JuliaLowering

#=
    Definition and constructors.
=#

# TODO [docs]

mutable struct RangeNode{T} <: AbstractNode{T}
    interval::UnitRange # Should keep `low` and `high` instead?
    left::Union{RangeNode, Nothing}
    right::Union{RangeNode, Nothing}
    parent::Union{RangeNode, Nothing}
    max::Int
    data::T # [optional] Extra data to store in the node.
end

function RangeNode(interval::UnitRange, parent::Union{RangeNode, Nothing}, data::T) where T
    new_node = RangeNode(
        interval,
        nothing,
        nothing,
        parent,
        interval.stop,
        data
    )
    insert!(parent, new_node)

    return new_node
end
RangeNode(interval::UnitRange, parent::RangeNode) = RangeNode(interval, parent, nothing)

function RangeNode(interval::UnitRange, data::T) where T
    return RangeNode(
        interval,
        nothing,
        nothing,
        nothing,
        interval.stop,
        data
    )
end
RangeNode(interval::UnitRange) = RangeNode(interval, nothing)

# TODO: This results in a linked list. (How) Can it be balanced?
function RangeNode(ast::JuliaLowering.SyntaxTree; parent::Union{RangeNode, Nothing}=nothing)
    root = RangeNode(JuliaLowering.first_byte(ast):JuliaLowering.last_byte(ast), parent, ast)

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

#=
    Getters and setters.
=#

AbstractTrees.children(node::RangeNode) =
    isnothing(node.left) && isnothing(node.right) ? RangeNode[]  :
    isnothing(node.left)                          ? [node.right] :
    isnothing(node.right)                         ? [node.left]  : [node.left, node.right]

AbstractTrees.nodevalue(node::RangeNode) = node.interval

AbstractTrees.ParentLinks(::RangeNode) = AbstractTrees.StoredParents()
AbstractTrees.parent(node::RangeNode) = node.parent

nodedata(node::RangeNode) = node.data

#=
    Tree manipulation: insertion, deletion?, search
=#

include("methods.jl")

end # module RangeTrees
