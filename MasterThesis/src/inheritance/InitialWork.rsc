module inheritance::InitialWork

import IO;
import Set;
import List;
import Map;
import ListRelation;
import Node;
import ValueIO;
import DateTime;

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






public void runInitialWork() {
	//loc projectHead = |project://|;
	//loc myProject = |project://|+ "EnumProject";
	//println("My project loc: <myProject>");
	loc projectLoc = |project://InheritanceSamples|;

	//makeDirectory(projectLoc);
	//println("Directory is made...");

	//println("Annotations on projectLoc");
	//iprintln(getAnnotations(projectLoc));
	M3 projectM3 = getM3Model(projectLoc);
	map[loc, set[loc]] 			extendsMap 		= toMap({<_child, _parent> | <_child, _parent> <- projectM3@extends});
	map[loc, set[loc]] 			implementsMap  	= toMap({<_child, _parent> | <_child, _parent> <- projectM3@implements});
	map [loc, set [loc]] 	declarationsMap				= toMap({<aLoc, aProject> | <aLoc, aProject> <- projectM3@declarations});
	
	set [loc] allTypesInProject =  getAllClassesAndInterfacesInProject(projectM3);
	
	for (aLoc <- allTypesInProject) {	
		println("Loc <aLoc>");
		loc immParent = getImmediateParent(aLoc ,extendsMap, implementsMap, declarationsMap);
		if (immParent != DEFAULT_LOC) {
			println("immediate parent of <aLoc> is <immParent>"); 
		}	
	}
	
	
	//println("Containment, : "); 
	//iprintln(sort({<_container, _item> | <_container, _item> <- projectM3@containment }));
	//
	//println("Method invocation:");
	//iprintln(sort({<_container, _item> | <_container, _item> <- projectM3@methodInvocation }));
	
	//println("Annotations on M3");
	//iprintln(getAnnotations(projectM3));

	//loc methodLoc = |java+method:///javax/swing/text/View/getAlignment(int)|;
	
	//println("Id: <methodLoc.id>");
	//println("Authority: <methodLoc.authority>");
	//println("parent: <methodLoc.parent>");
	//println("Scheme: <methodLoc.scheme>");
	//println("File <methodLoc.file>");


	//println("Extends annotation"); iprintln(sort(projectM3@extends));
	//println("Size of extends annotation is: <size(projectM3@extends)>");
	//println("Implements annotation"); iprintln(sort(projectM3@implements));
	//println("Size of implements annotation: <size(projectM3@implements)>");
	
	//getInfoForMethod(projectM3, |java+method:///edu/uva/analysis/samples/st/OuterInnerRunner/runIt()|); 
	//getInfoForMethod(projectM3, |java+constructor:///edu/uva/analysis/samples/st/ParamPassChild/ParamPassChild(edu.uva.analysis.samples.st.P)|); 
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


private void getInfoForMethod(M3 projectModel, loc methodName) {
//|java+method:///edu/uva/analysis/samples/H/k(edu.uva.analysis.samples.P)|
	methodAST = getMethodASTEclipse(methodName, model = projectModel);
	// println("Method AST is: <methodAST>");
	//text(methodAST);
	visit(methodAST) {
        case consCall1:\constructorCall(_, arguments:_): {
			Expression e = createMethodCallFromConsCall(consCall1);
			println("Method arguments: "); iprintln(e.arguments);
        }
        case consCall2:\constructorCall(_, expr:_, arguments:_): {
			Expression e = createMethodCallFromConsCall(consCall2);
			println("Method arguments: "); iprintln(e.arguments);
        }

		case m1:\methodCall(_,_, args) : {
			//text(m1);
		;}
		case m2:\methodCall(_, receiver:_, _, args): {
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
			//println("Logical expression: <logicalExpr>");
			//println("Type of the then branch : <thenBranch@typ>");
			//println("Type of the else branch : <elseBranch@typ>");
			//println("----------------------------------------------");
		;}
		// \conditional(Expression expression, Expression thenBranch, Expression elseBranch)
		case fAccess1:\fieldAccess(isSuper, expression, name) : {
			text(fAccess1);
			//println("Field access 1 ----------------------");
			//iprintln(expression);
		;}
    	case fAccess2:\fieldAccess(bool isSuper, str name) : {
    		text(fAccess2);
   // 		println("Field access 2 ----------------------");
			//iprintln(fAccess2);
    	;}
    	case quaName:\qualifiedName(qualifier, expression) : {
    		//println("Qualified name. Qualifier: ----------------------");
    		//iprintln(qualifier);
    		//println("Expression: ");
    		//iprintln(expression);
    		//println("Type symbol of qualifier is: <qualifier@typ>");
    		//println("Class of the qualifier is: <getClassOrInterfaceFromTypeSymbol(qualifier@typ)>");
    		//println("Is the expression a java field: <isField(expression@decl)>");
    		//if (isField(expression@decl)) {
    		//} 
    	;}
		//case dStmt : \declarationStatement(declr) : {
		// // \variables(Type \type, list[Expression] \fragments)
		//	print("Declaration statement:");
		//	println(dStmt);
		//	println("Declaration: <declr>");
		//	;
		//}
		//case dExpr : \declarationExpression(declr) : {
		//	print("Declaration expression:");
		//	println(dExpr);
		//	println("Declaration: <declr>");
		//	;
		//}	
		case variables : \variables(typeOfVar, fragments) : {
			// typeOfVar is Type
			// fragments is list of Expresssion's
			//println("--------------------------------------------------");
		 //	TypeSymbol lhsTypeSymbol ;
		 //	visit (typeOfVar) {
		 //		case sType: \simpleType(typeExpr) : {
		 //			lhsTypeSymbol =  getTypeSymbolFromSimpleType(sType);
		 //		}
		 //		case atype :\arrayType(simpleTypeOfArray) : {
		 //			lhsTypeSymbol = getTypeSymbolFromSimpleType(simpleTypeOfArray);
		 //		}
		 
		 //	}
		 //	//println("Lhs type symbol is: <lhsTypeSymbol>");
		 //	println("Lhs Java type is: <getClassOrInterfaceFromTypeSymbol(lhsTypeSymbol)>");
			//for (anExpression <- fragments) {
			//	loc rhsClass;
			//	println("Variable name: <anExpression@decl>");
			//	visit (anExpression) {
			//		case myVar: \variable(_,_,stmt) : {
			//			rhsClass = getClassOrInterfaceFromTypeSymbol(stmt@typ);
			//			println("Right hand side class: <rhsClass>");
			//		} 
			//	} // visit
			//	
			//} // for
			;
		}
		case a:\assignment(lhs, operator, rhs) : {  
			//println("***************************************");
			//println("Assignment statement: ");
			//println("rhs: <rhs>");
			//tuple [bool isSubtypeRel, inheritanceKey iKey] result = getSubtypeRelation(rhs@typ, lhs@typ);
   //     	// 	\assignment(Expression lhs, str operator, Expression rhs)
   //     	println("--------------------------------------------------------------------");
			//println("assignment: ");  
			//loc lhsClass = getClassFromTypeSymbol(lhs@typ);
			//lhsClass = getInterfaceFromTypeSymbol(lhs@typ);
			//println("Class or interface: <getClassOrInterfaceFromTypeSymbol(lhs@typ)>");
			//loc rhsClass = getClassFromTypeSymbol(rhs@typ);
			//println("Left hand side is of type : <lhsClass>");
			//println("Right hand side is of type : <rhsClass>");						
			//if (lhsClass != rhsClass) {
			//	set [loc] allClasses = getAllClassesAndInterfacesInProject(projectModel);
			//	if ( (lhsClass in allClasses) && (rhsClass in allClasses)) {
			//		println("Lhs name: <lhs@decl>");
			//		println("Rhs name: <rhs@decl>");					
			//		println("Subtype via assignment.");
			//	}	
			//}
			//println("Assignment statement <a>");
			//println("Source of the assignment statement <a@src>");			
			// Subtype via declarations are in the typeDependency annotation
			// in typeDependency you get two entries instead of one, one is the type
			// the other is the class where the variable refers to
			;			
        }
		
        case c:\cast(_, _) : { 
        	//  \cast(Type \type, Expression expression)
   //     	print("cast: ");
			//println(c); 
			;
        }
        case super1:\super(): {
   //         print("super: ");
			//println(super1); 
			;
        }
        
        case methodDecl : \method(methType, _, _, _, _) :{
        	//println("Declared return type symbol of method is: <getTypeSymbolFromSimpleType(methType)>");
        	//println("Declared return type of method is: <getClassOrInterfaceFromTypeSymbol(getTypeSymbolFromSimpleType(methType))>");
        ;
        }
        case returnStmt : \return(retExpr) : {
        	//println("Return statement. Return expression is:");
        	//text(retExpr);
        	//println("Type symbol of the return expression is: <retExpr@typ> ");
        	//println("Type of the return expression is : <getClassOrInterfaceFromTypeSymbol(retExpr@typ)>");
        	//println("Source code location of return expression is: <retExpr@src>");
        	//TypeSymbol declaredReturnType = getDeclaredReturnTypeOfMethod(methodName, projectModel);
        	//println("Declared return type symbol is: <declaredReturnType>");
        	//println("Declared return type is: <getClassOrInterfaceFromTypeSymbol(declaredReturnType)>");
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




