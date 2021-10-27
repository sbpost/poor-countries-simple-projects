using DrWatson
@quickactivate "poor-countries-simple-products"

using DataFrames
using Arrow
using Graphs
using MetaGraphs
# using GraphPlot

# Build dependency graph
out1 = datadir("temp", "formatted-blocks", "block-A-all-years.arrow")
dep1 = datadir("temp", "raw-blocks", "A", "block-A-year-2000.arrow")
dep2 = datadir("temp", "raw-blocks", "A", "block-A-year-2001.arrow")


dependencies = [dep1, dep2]
outputs = [out1]

# Create graph:
G = MetaDiGraph(Graph())
set_indexing_prop!(G, :file)

# Get change time:
ctime(datadir("temp", "formatted-blocks", "block-A-all-years.arrow"))
ctime(datadir("temp", "formatted-blocks", "block-B-all-years.arrow"))

readdir(datadir("temp", "raw-blocks", "A"))

function set_target!(G::MetaDiGraph, outputs::Vector{String}, inputs::Vector{String})
    input_dicts = [Dict(:file => i) for i in inputs]
    output_dicts = [Dict(:file => o) for o in outputs]
    verts = vcat(input_dicts, output_dicts)

    # Add vertices to graph:
    for v in verts
        add_vertices!(G, 1)
        set_prop!(G, nv(G), :file, v[:file])
    end

    # Add edges:
    for o in output_dicts
        for i in input_dicts
            out_index = G[o[:file], :file]
            in_index = G[i[:file], :file]
            add_edge!(G, out_index, in_index)
        end
    end
end


set_target!(G, outputs, dependencies)

# Build:
# TODO Check if output file exists
# TODO Check inputs' change time is higher than output change time
