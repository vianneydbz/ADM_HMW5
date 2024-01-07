#!/bin/bash

#Define the edgelist file
edgelist_file="citation_graph.edgelist"

#1. Script to find important connector nodes in the Citation Graph based on degree centrality
#Extract the top 10 nodes with high degrees
top_nodes=$(sort -k2 -nr "$edgelist_file" | awk '{print $1}' | uniq -c | sort -k1,1nr | head -n 10)

#Print the result
if [ -n "$top_nodes" ]; then
    echo "Important Connector Nodes (Top 10):"
    echo "$top_nodes"
else
    echo "No important connector nodes found."
fi

#Blank line
echo

#2. Script to analyze the degree of citation in the Citation Graph
#Extract edges and source nodes from the edgelist file
edges=$(awk '{print $1, $2}' $edgelist_file)

#Extract and count the in-degrees and out-degrees of each node
in_degrees=$(echo "$edges" | awk '{print $2}' | sort | uniq -c | awk '{print $1}' | sort -n)
out_degrees=$(echo "$edges" | awk '{print $1}' | sort | uniq -c | awk '{print $1}' | sort -n)

#Function to print the list of degrees with counts
print_degree_counts() {
    local degrees=$1
    local degree_counts=($(echo $degrees))
    local max_degree=${degree_counts[-1]}

    for ((degree = 1; degree <= max_degree; degree++)); do
        count=$(echo "$degrees" | grep -wc $degree)
        echo -n "$degree: $count, "
    done
    echo  #Newline
}

#Print the in-degrees
echo "In-degree counts:"
print_degree_counts "$in_degrees"

#Blank line
echo

#Print the out-degrees
echo "Out-degree counts:"
print_degree_counts "$out_degrees"

#Blank line
echo

#3. Script to calculate the average shortest path length in the Citation Graph

#Calculate the average shortest path length for the largest strongly connected component
avg_shortest_path_length=$(awk '{print $1, $2}' $edgelist_file | sort -u | python3 -c "
import networkx as nx
import sys

#Read edges from stdin and create a directed graph
G = nx.DiGraph()
for line in sys.stdin:
    source, target = map(int, line.split())
    G.add_edge(source, target)

#Find the largest strongly connected component
largest_component = max(nx.strongly_connected_components(G), key=len)

#Create a subgraph with only the largest strongly connected component
G_largest_component = G.subgraph(largest_component)

#Calculate average shortest path length
avg_shortest_path_length = nx.average_shortest_path_length(G_largest_component)
print(f'{avg_shortest_path_length:.2f}')
")

#Print the result
echo "Average Shortest Path Length: $avg_shortest_path_length"
