module inheritance::GraphExample

import analysis::graphs::Graph;
import IO;

public void getAllPredecessors() {
	rel [int, int] r = { <1,2>}; 
	Graph g = {<1, 2>, <1, 3>, <2, 4>, <3, 4> };
	set [int] immPredecessors = predecessors(g, 4);
	iprintln(immPredecessors); 
}