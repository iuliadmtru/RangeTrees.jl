module RangeTrees

# Existing similar package: https://github.com/BioJulia/IntervalTrees.jl. Not maintained, outdated.
# Might be useful: https://github.com/JuliaMath/IntervalSets.jl

using AbstractTrees

#=
    Definition and constructors.
=#

struct RangeNode{T} <: AbstractNode{T}
    interval::UnitRange # Should keep `low` and `high` instead?
    left_child::Union{RangeNode, Nothing}
    right_child::Union{RangeNode, Nothing}
    parent::Union{RangeNode, Nothing}
    max::Int
    data::T # Extra data. In our case, the corresponding `GreenNode`.
end
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

#=
    Getters and setters.
=#

AbstractTrees.children(node::RangeNode) = [node.left_child, node.right_child]

AbstractTrees.nodevalue(node::RangeNode) = node.interval

AbstractTrees.ParentLinks(::RangeNode) = AbstractTrees.StoredParents()
AbstractTrees.parent(node::RangeNode) = node.parent

nodedata(node::RangeNode) = node.data

#=
    Tree manipulation.
=#

function Base.insert!(root::Union{RangeNode, Nothing}, interval::UnitRange, data::T) where T
    if isnothing(root)
        return RangeNode(interval, data)
    end

    if interval.start < root.interval.start
        insert!(root.left_child, interval, data)
    end
end

end # module RangeTrees
