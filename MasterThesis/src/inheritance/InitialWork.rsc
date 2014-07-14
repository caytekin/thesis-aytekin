module inheritance::InitialWork

import IO;
import Set;
import List;
import Map;
import ListRelation;
import Node;
import ValueIO;
import DateTime;
import String;

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::TypeSymbol;
import util::ValueUI;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;
import inheritance::SubtypeInheritance; 
import inheritance::DowncallCases;

data CTree = 	leaf(int n)
					| red (CTree left, CTree right)
					| black (CTree left, CTree right);




public void patternMatch() {
	int i = 8;
	if ( i:= 8) {println("The first i is 8.");}
	if ( y:i := 8) {println("i is <y>");}
	if (/<x:[a-z]+>/ := "1abc3" ) {println("x is: <x>");}  
	
	list [int] myList = [1, 2, 3, 4, 5];
	if ( [l1*, 3, l2*] := myList ) {println("A list match...<l1>, <l2>");}
	if ([e1, e2, 3, l3*] := myList ) {println("Second list match...<e2>");}
	
	set [int] mySet = {6, 7, 8, 9, 0};
	if ({6, aSet*} := mySet) {println("aSet is: <sort(aSet)>");}
	
	list [int] ambiMatch = [1,2];
	if ( [l1*, l2*] := ambiMatch ) { println("l1 is: <l1>, l2 is: <l2>"); }
	
}


public void treeExample() {
	CTree rb = red(	black(
							leaf(1), red (
											leaf(2), leaf(3)
										 ) 
						 ),
					black(	
							leaf(4), leaf(5)
						 )
				  );
//	text(rb);
	//for(/leaf(n) <- rb) { println("Deep matching <n>");}		// prints all leaves
	//for(leaf(n) <- rb) { println("Shallow matching <n>");}		// prints nothing

	//for(red(_,_) := rb) {intln("Shallow red(_,_)... with := ");} // prints once, the root match
	//for(red(_,_) <- rb) {println("Shallow red(_,_)... with \<- ");} // prints nothing


	//for(/red(_,_) := rb) {println("Deep red(_,_)... with := ");} // prints all red nodes
	//for(/red(_,_) <- rb) {println("Deep red(_,_)... with \<- ");} // prints only the first red node
	//	
	// For pattern matching with for, use :=, but not <- ...., <- is confusing...
	
	
	//switch (rb) {
	//	case leaf(_) : {println("Switch - This is a leaf."); }
	//	case black(_,_) : {println("Switch This is black..."); }
	//	case red (_,_) : {println("Switch Red...");}
	//}			
	
	top-down visit (rb) {
		case \red(r,l) : {println("Top down Visit- This is leaf: <r><l> "); }
	}

	top-down-break visit (rb) {
		case black(r,l) : {println("Top down break Visit- This is leaf:<r><l> "); }
	}

	bottom-up visit (rb) {
		case leaf(n) : {println("Bottom up visit- This is leaf: <n>"); }
	}

	
	bottom-up-break visit (rb) {
		case leaf(n) : {println("Bottom up break Visit- This is leaf: <n>"); }
	}
	
	
	
	visit (rb) {
		case leaf(n) : {println("Default Visit- This is leaf: <n>"); 	}
	}
	
}


public void mapExample() {
	rel [loc, int] myLocSet = {<|java+field:///|, 1>, <|java+method:///edu/uva/analysis/samples/N/extReuse()|, 1>};
	map [loc, int] myLocMap = toMapUnique(myLocSet);
}

public void matchWithAST() {
	M3 projectM3 = getM3Model(|project://Inheritancesamples|);
	Declaration methodAST = getMethodASTEclipse(|java+method:///edu/uva/analysis/samples/N/extReuse()|, model = projectM3);
	i = 0;
	     // \declarationExpression(Declaration decl)
	visit (methodAST) {
		//case  dExpr:\declarationExpression(decl) : {
		//	println("Declaration expression...");
		//;}
		//case asgnmnt:\assignment(lhs, operator, rhs) : {
		//	println("Assignment...");		
		//;}
		//case st2:simpleType(_) : {
		//	println("Simple type 2...");
		//}
		case c:class(_, _) : {
			println("Class deep...");
		}
		case st:\simpleType(_) : {
			println("Simple type deep...");
		}		
	}
	for (asgnmnt:/assignment(lhs, operator, rhs) <- methodAST) {
		i = i+1;
		println("Assignment expression <i> is: <asgnmnt>,  lhs: <lhs>, operator: <operator>, rhs: <rhs>");
	}
}


void listNewObjectCalls(M3 projectM3) {
	set [loc] allMethods = {_aMethod | <_, _aMethod> <- projectM3@containment, isMethod(_aMethod)};
	for (aMethod <- allMethods ) {
		methodAST = getMethodASTEclipse(aMethod, model = projectM3);	
		visit (methodAST) {
			case newObject2:\newObject(_,_) : {
				println("2222 at: <newObject2@src>");
			;}
			case newObject3:\newObject(_,_,_) : {
				println("New object 3333 at: <newObject3@src>");
			;}
			case newObject4:\newObject(_,_,_,_) : {
				println("New object 4444 at: <newObject4@src>");			
			;}			
		}
	;}
}



private void getInfoForClass(M3 projectM3, loc classLoc) {
	println("Project for this M3 is: <projectM3.id>");
}


void visitTypeSymbol(TypeSymbol aTypeSymbol) {
	visit(aTypeSymbol) {
		case classType:\class(loc decl, list[TypeSymbol] typeParameters) : {  
			println("A class: <decl>");
			if (size(typeParameters) > 1) {
				println("Many type parameters for class : <decl>. Type parameters : <typeParameters>");
			}		
		}
		case intType:\interface(loc decl, list[TypeSymbol] typeParameters) : {  
			println("An interface: <decl>");
			if (size(typeParameters) > 1) {
				println("Many type parameters for class : <decl>. Type parameters : <typeParameters>");
			}		
		}
	}
}


void searchForComplexTypes(M3 projectM3) {
	 set [Declaration] projectASTs = createAstsFromEclipseProject(projectM3.id, true);
	 for (anAST <- projectASTs) {
	 	visit (anAST) {
	 		case aStmt:\assignment(Expression lhs, str operator, Expression rhs) : {
	 			visitTypeSymbol(lhs@typ);
	 			visitTypeSymbol(rhs@typ);
			}
	 	}
	 }
}


private Expression createMethodCallFromConsCall(Statement consCall) {
	Expression retExp;
	list [Expression] arguments = [];
	visit (consCall) {
	     case consCall1:\constructorCall(_, args:_): {
        //       (bool isSuper, list[Expression] arguments)
			arguments = args; 
        }
        case consCall2:\constructorCall(_, expr:_, args:_): {
        //       (bool isSuper, Expression expr, list[Expression] arguments)
			arguments = args; 
        }
	}
	retExp = methodCall(true, " ", arguments);
	retExp@decl = |java+constructor:///|;	// Waiting for Rascal fix 575.
	return retExp;
}





public void runInitialWork() {
	loc projectLoc = |project://VerySmallProject|;
	M3 projectM3 = getM3Model(projectLoc);
	//text(projectM3@names);
	getInfoForMethod(projectM3, |java+method:///edu/uva/analysis/samples/N/complexMethodCall2()|); 
}







private void getInfoForMethod(M3 projectM3, loc methodName) {
//|java+method:///edu/uva/analysis/samples/H/k(edu.uva.analysis.samples.P)|
	methodAST = getMethodASTEclipse(methodName, model = projectM3);
	map [loc, set [str]] invertedNamesMap = getInvertedNamesMap(projectM3@names);
	// println("Method AST is: <methodAST>");
	//text(methodAST);
	visit(methodAST) {
        case consCall1:\constructorCall(_, arguments:_): {
			//Expression e = createMethodCallFromConsCall(consCall1);
			//println("Method arguments: "); iprintln(e.arguments);
        ;}
        case consCall2:\constructorCall(_, expr:_, arguments:_): {
			//Expression e = createMethodCallFromConsCall(consCall2);
			//println("Method arguments: "); iprintln(e.arguments);
        ;}

		case m1:\methodCall(_,_, args) : {
			println("Method declaration m1:"); println(m1@decl);
			//text(m1);
		;}
		case m2:\methodCall(_, receiver:_, _, args): {
			println("Method declaration m2:"); println(m2@decl);
			loc methodDecl = m2@decl;
			//println("Annotations on m2: <getAnnotations(m2)>");
			/*
path: path name of file on host, as a str
extension: file name extension, as a str
query: query data, as a str
fragment: the fragment name following the path name and query data, as a str
parent : removes the last segment from the path component, if any, as a loc
file : the last segment of the path, as a str
ls :
			*/
			//println("Parent: <methodDecl.parent>");
			//println("Scheme: <methodDecl.scheme>");
			//println("Authority: <methodDecl.authority>");
			//println("Path: <methodDecl.path>");
			//println("Extension: <methodDecl.extension>");
			//println("Query: <methodDecl.query>");
			//println("Fragment: <methodDecl.fragment>");
			//println("Parent: <methodDecl.parent>");
			//println("File: <methodDecl.file>");

			println("declared type symbols:"); iprintln(getArgTypeSymbols(methodDecl.file, invertedNamesMap)); println();
			
			//println("Receivers type symbol is: <receiver@typ>");
			//println("Arguments are:");
			//iprintln(args);
			
		;}
		case enhFor:\foreach(Declaration parameter, Expression collection, Statement body) : {
			//text(enhFor);
			//println("Parameter type symbol is: <parameter@typ>");
			//println("Collection type symbol is: <collection@typ>");
			//println("SUBTYPE LIST OF ENHANCED FOR LOOP:");
			//iprintln(subtypeEnhancedForLoop(parameter@typ, collection@typ));
		;}
		case newObject1:\newObject(Type \type, list[Expression] args) : {
			//text(newObject1);
		;}
		case newObject2:\newObject(Type \type, list[Expression] args, Declaration class) : {
			//text(newObject2);
		;}
		case newObject3:\newObject(Expression expr, Type \type, list[Expression] args) : {
			//text(newObject3);
		;}
		case newObject4:\newObject(Expression expr, Type \type, list[Expression] args, Declaration class) : {
			//text(newObject4);
		;}
		
		case cndStmt:\conditional(logicalExpr, thenBranch, elseBranch) : {
		;}
		case fAccess1:\fieldAccess(isSuper, expression, name) : {
			//text(fAccess1);
		;}
    	case fAccess2:\fieldAccess(bool isSuper, str name) : {
    		//text(fAccess2);
    	;}
    	case quaName:\qualifiedName(qualifier, expression) : {
		;}
		case variables : \variables(typeOfVar, fragments) : {
			;
		}
		case a:\assignment(lhs, operator, rhs) : {  
			;			
        }
		
        case c:\cast(_, _) : { 
			;
        }
        case super1:\super(): {
			;
        }
        case methodDecl : \method(methType, _, _, _, _) :{
        ;
        }
        case returnStmt : \return(retExpr) : {
			;
        }
            
	} // visit
}




private void dealWithMethodCall(Expression methodCallExpr, M3 projectModel) {
	println("Called method is: <methodCallExpr@decl>");
	println("Where in source is it called: <methodCallExpr@src>");
	list [Expression] args= [];
	list [TypeSymbol] passedArgList = [], declaredArgList = [];
	//text(methodCallExpr);
	visit (methodCallExpr)  {
		case m1:\methodCall(_,_,myArgs:_) : {
			//println("I am here with 3 args");
			args = myArgs;
		}
		case m2:\methodCall(_,receiver:_,_,myArgs:_) : {
			//println("I am here with 4 args");
			//println("Is receiver this: <isReceiverThis(receiver)>");
			//text(m2);
			//args = myArgs;
			;
		}
	}
	////println("Passed arguments are: ");
	////iprintln(args);	
	//println("Passed argument type symbols are: ");
	//for ( int i <- [0..(size(args))]) passedArgList += args[i]@typ;
	//iprintln(passedArgList);
	//println("Declared argument type symbols are: ");
	//declaredArgList = getDeclaredParameterTypes (methodCallExpr@decl, projectModel);
	//iprintln(declaredArgList);
	//for (int i <- [0..size(args)]) {
	//	tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(passedArgList[i], declaredArgList[i]);
	//	if (result.isSubtypeRel) {
	//		println("Yes! A subtype relation! At location: <methodCallExpr@src>");
	//		println("	Between child: <result.iKey.child> and parent <result.iKey.parent>. ");
	//	}
	//}
}



private M3 getM3Model(loc projectLoc) {
	println("Starting with M3 creation at <now()>");
	M3 inheritanceM3 = createM3FromEclipseProject(projectLoc);
	println("Created M3 at <now()>");	
	int totalClasses = size ( {<aType> | <aType,_> <- inheritanceM3@declarations, isClass(aType) || isInterface(aType) } );
	println("Total number of classes and interfaces in M3 are: <totalClasses>");
	return inheritanceM3;
}

//public TypeSymbol getTypeSymbolFromSimpleType(Type aType) {
//	TypeSymbol returnSymbol; 
//	visit (aType) {
//		case sType: \simpleType(typeExpr) : {
//			returnSymbol =  typeExpr@typ;
//		}
// 	}
// 	return returnSymbol;
//}
//

//private set [inheritanceKey] subtypeEnhancedForLoop(TypeSymbol paramTypeSymbol, TypeSymbol collTypeSymbol) {
//	set [inheritanceKey] retSet = {};
//	TypeSymbol compTypeSymbol = DEFAULT_TYPE_SYMBOL;
//	switch (collTypeSymbol) {
//		case anArray:\array(TypeSymbol component, int dimension) : {
//			compTypeSymbol = component;
//		}
//		case anInterfaceColl:\class(loc decl, list[TypeSymbol] typeParameters) : {
//			if (size(typeParameters) != 1) throw "More than one type parameter in class collection def: <collTypeSymbol>"; 
//			compTypeSymbol = typeParameters[0];
//		}
//		case aClassColl:\interface(loc decl, list[TypeSymbol] typeParameters) : {
//			if (size(typeParameters) != 1) throw "More than one type parameter in interface collection def: <collTypeSymbol>"; 
//			compTypeSymbol = typeParameters[0];
//		}
//	}
//	if (compTypeSymbol != DEFAULT_TYPE_SYMBOL) {
//		tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(paramTypeSymbol, compTypeSymbol);
//		if (result.isSubtypeRel) { retSet += result.iKey; }
//	}	
//	return retSet;
//}
//


private void changeMap(map [int, int] aMap) {
	aMap += (3:4);
}


public void tryAChange() {
	map [int, int] myMap = (1:1);
	println("My map before method call is: <myMap>");
	changeMap(myMap);
	println("My map after method call is: <myMap>"); 
}




