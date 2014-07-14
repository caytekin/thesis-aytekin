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
//	set[Declaration] projectASTs =  createAstsFromEclipseProject(|project://InheritanceSamples|, true);
	loc projectLoc = |project://InheritanceSamples|;
	M3 projectM3 = createM3FromEclipseProject(projectLoc);	
	loc aMethod = |java+constructor:///edu/uva/analysis/samples/DowncallRunner/DowncallRunner()|;
	//loc aMethod = |java+constructor:///edu/uva/analysis/samples/D/D()|;
	methodAST = getMethodASTEclipse(aMethod, model = projectM3);
	bool superCall = false;
	visit (methodAST) {
		case c1:\constructorCall(isSuper:_,_,_) : {
			if (isSuper) {superCall = true; } 
		}
		case c2:\constructorCall(isSuper:_,_) : {
			if (isSuper) {superCall = true; }
		}
	}
	println("Is there a super call? <superCall>");
}

