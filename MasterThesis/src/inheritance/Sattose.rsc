module inheritance::Sattose

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;
import DateTime;
import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::AST;


public void run() {
	set[Declaration] projectASTs =  createAstsFromEclipseProject(|project://cobertura-1.9.4.1|, true);
	map [loc, num] methodsMap = ();
	for (anAST <- projectASTs) {
		visit (anAST) {
			case m1:\methodCall(_, _, _, _) : {
				if (m1@decl in methodsMap) {
					methodsMap[m1@decl] = methodsMap[m1@decl] + 1;
				} 
				else {methodsMap += (m1@decl : 1) ; }
			}
			case m2:\methodCall(_,_,_) : {
				if (m2@decl in methodsMap) {
					methodsMap[m2@decl] = methodsMap[m2@decl] + 1;
				} 
				else {methodsMap += (m2@decl : 1); };
			}
		}
	}
	map [loc, num] frequentlyCalledMethods = (aMethod : methodsMap[aMethod] | aMethod <- methodsMap, methodsMap[aMethod] > 400 );	
	println("Frequently called methods:");
	iprintln(frequentlyCalledMethods);
}

