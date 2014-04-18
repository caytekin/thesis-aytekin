module inheritance::GraphExample

import analysis::graphs::Graph;
import IO;




//private rel [inheritanceKey, inheritanceType] getCC_CI_II_NonFR_Relations (rel [loc child, loc parent] inheritRelation, M3 projectM3) {
//	rel [inheritanceKey, inheritanceType] CC_CI_II_NonFR_Relations = {};
//	set [loc] allClassesAndInterfacesInProject = getAllClassesAndInterfacesInProject(projectM3);
//	set [inheritanceKey] allInheritanceRels = getInheritanceRelations(projectM3);
//	CC_CI_II_NonFR_Relations += {<<child, parent>, CLASS_CLASS> | <child, parent> <- inheritRelation, isClass(child), isClass(parent)};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, CLASS_INTERFACE> | <child, parent> <- inheritRelation, isClass(child), isInterface(parent)};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, INTERFACE_INTERFACE> | <child, parent> <- inheritRelation, isInterface(child), isInterface(parent)};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, NONFRAMEWORK_CC> | <child, parent> <- inheritRelation, isClass(child), isClass(parent), parent in allClassesAndInterfacesInProject};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, NONFRAMEWORK_CI> | <child, parent> <- inheritRelation, isClass(child), isInterface(parent), parent in allClassesAndInterfacesInProject};
//	CC_CI_II_NonFR_Relations += {<<child, parent>, NONFRAMEWORK_II> | <child, parent> <- inheritRelation, isInterface(child), isInterface(parent), parent in allClassesAndInterfacesInProject};
//	return CC_CI_II_NonFR_Relations;
//}




public void getAllPredecessors() {
	rel [int, int] r = { <1,2>}; 
	Graph g = {<1, 2>, <1, 3>, <2, 4>, <3, 4> };
	set [int] immPredecessors = predecessors(g, 4);
	iprintln(immPredecessors); 
}





set [loc] getGenericParentCanidates (set [Declaration] projectASts) {
	set [loc] retSet = {};
	for ( Declaration anAST <- projectASTs) {
		list [Expression] passedArguments = [];
		visit (anAST) {
			case methCall1:methodCall(_,_,args:_) : {
				passedArguments = args;
			}
			case methCall2:methodCall(_,_,_,args:_) : {
				passedArguments = args;
			}
		}
		
	}
	return retSet;
}


