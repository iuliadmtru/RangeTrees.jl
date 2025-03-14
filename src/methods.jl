# TODO [efficiency]: Make RangeTrees self-balancing?
# TODO [docs]

#=
    Insertion.
=#

function Base.insert!(root::Union{RangeNode, Nothing}, interval::UnitRange, data::T) where T
    if isnothing(root)
        return RangeNode(interval, data)
    end

    left = root.left
    right = root.right
    if interval.start < root.interval.start
        if isnothing(left)
            root.left = RangeNode(interval, root, data)
        elseif left.interval.start == interval.start && left.interval.stop == interval.stop
            @info "Interval $interval already exists."
            return root
        else
            insert!(root.left, interval, data)
        end
    else
        if isnothing(right)
            root.right = RangeNode(interval, root, data)
        elseif right.interval.start == interval.start && right.interval.stop == interval.stop
            @info "Interval $interval already exists."
            return root
        else
            insert!(root.right, interval, data)
        end
    end

    if root.max < interval.stop
        root.max = interval.stop
    end

    return root
end

function Base.insert!(root::Union{RangeNode, Nothing}, node::RangeNode)
    if isnothing(root)
        return node
    end

    left = root.left
    right = root.right
    interval = node.interval
    if interval.start < root.interval.start
        if isnothing(left)
            root.left = node
        elseif left.interval.start == interval.start && left.interval.stop == interval.stop
            @info "Node already exists -- updating data."
            root.left.data = node.data

            return root
        else
            insert!(root.left, node)
        end
    else
        if isnothing(right)
            root.right = node
        elseif right.interval.start == interval.start && right.interval.stop == interval.stop
            @info "Node already exists -- updating data."
            root.right.data = node.data

            return root
        else
            insert!(root.right, node)
        end
    end

    if root.max < interval.stop
        root.max = interval.stop
    end

    return root
end

#=
    Search.
=#

# Base.:(==)(node1::RangeNode, node2::RangeNode) =
#     (@info node1, node2; true) &&
#     node1.interval == node2.interval &&
#     node1.max == node2.max           &&
#     node1.data == node2.data         &&
#     node1.parent == node2.parent     &&
#     # node1.left == node2.left         &&
#     node1.right == node2.right

# function findnode(root::Union{RangeNode, Nothing}, node::RangeNode)
#     if isnothing(root)
#         return nothing
#     end


# end
