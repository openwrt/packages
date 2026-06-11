#!/bin/sh
[ "$1" = python3-networkx ] || exit 0
python3 - << 'EOF'
import networkx
assert networkx.__version__, "networkx version is empty"

import networkx as nx

G = nx.Graph()
G.add_nodes_from([1, 2, 3, 4])
G.add_edges_from([(1, 2), (2, 3), (3, 4)])

assert G.number_of_nodes() == 4
assert G.number_of_edges() == 3
assert nx.is_connected(G)

path = nx.shortest_path(G, source=1, target=4)
assert path == [1, 2, 3, 4], f"unexpected path: {path}"

D = nx.DiGraph()
D.add_edges_from([(1, 2), (2, 3)])
assert list(nx.topological_sort(D)) == [1, 2, 3]
EOF
