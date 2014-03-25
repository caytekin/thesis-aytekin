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





public void runInitialWork() {
	M3 projectM3 = getM3Model(|project://InheritanceSamples|);
	//iprintln(projectM3@containment);
	iprintln(projectM3@types);
	loc classLoc = |java+class:///edu/uva/analysis/samples/Var1ArgsRunner|;
	//println("Classes or interfaces containing: <classLoc>");
	//iprintln({_owner | <_owner, _aClass> <- projectM3@containment, _aClass == classLoc, isClass(_owner) || isInterface(_owner)});
	//println("Classes or interfaces containing: <classLoc.parent>");
	//iprintln({_owner | <_owner, _aClass> <- projectM3@containment, _aClass == classLoc.parent, isClass(_owner) || isInterface(_owner)});	
	map [loc, set[loc]] invertedUnitContainment = getInvertedUnitContainment(projectM3);
	map [loc, set[loc]] invertedClassAndInterfaceContainment = getInvertedClassAndInterfaceContainment(projectM3);
	//println("Inverted containment entry for <classLoc> is: <invertedClassAndInterfaceContainment[classLoc]>");	
	map [loc, set[loc]] declarationsMap = toMap({<_compUnit, _file> | <_compUnit, _file> <- projectM3@declarations});
	//println("The parent of the class <classLoc> is: <classLoc.parent>. The grand parent of the class is <classLoc.parent.parent>");
	 //iprintln(getASTsOfAClass(classLoc, invertedClassAndInterfaceContainment, invertedUnitContainment , declarationsMap));
	//listNewObjectCalls(m3Model);
	//rel [loc, loc] methodContainment = {<_classOrInt, _method >| <_classOrInt, _method> <- m3Model@containment, _classOrInt == |java+class:///edu/uva/analysis/samples/A|};
	//println(methodContainment);
	//rel [loc, loc] methodContainment = {<_classOrInt, _method >| <_classOrInt, _method> <- m3Model@containment, _method == |java+method:///org/shiftone/jrat/core/RuntimeContextImpl/registerForShutdown()/$anonymous1/shutdown()|};
	//println("Method containment: ");
	//iprintln(sort(methodContainment));
	getInfoForMethod(projectM3, |java+method:///edu/uva/analysis/samples/ThisChangingTypeParent/subtypeViaConstructorCall()|);
	//getInfoForClass(m3Model, |java+class:///edu/uva/analysis/samples/ThisChangingTypeParent|);
	//println("Staring with constants at: <now()>");
	//println("Inheritance relations with constant attribute are: ");
	//iprintln(findConstantLocs(getConstantCandidates(m3Model), m3Model)) ;
	//println("Finished with constants at: <now()>");
	
	                       //<|java+constructor:///edu/uva/analysis/samples/Sub1/Sub1(int)|
	//getInfoForMethod(m3Model, |java+method:///edu/uva/analysis/samples/N/extReuse2222()|);
	//getInfoForMethod(m3Model, |java+method:///edu/uva/analysis/gensamples/Canvas/drawAll(java.util.List)|);	
	//getInfoForMethod(m3Model, |java+constructor:///edu/uva/analysis/samples/Sub1/Sub1(int)|);	
	//iprintln(getAscendantsInOrder(|java+class:///edu/uva/analysis/samples/G|, m3Model));
	//iprintln(getAscendantsInOrder(|java+class:///edu/uva/analysis/samples/GrandChild|, m3Model));	
	//iprintln(getAscendantsInOrder(|java+class:///edu/uva/analysis/samples/Parent|, m3Model));		
	//findDownCalls(m3Model);
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
	//print ("Extends relation (from loc, to loc): "); iprintln(inheritanceM3@extends);
	//print ("Implements relation (from loc, to loc): "); iprintln(inheritanceM3@implements);
	//print ("Method overrides: "); iprintln(inheritanceM3@methodOverrides);
	//print ("Method invocation: "); 
	//iprintln({<from, to> | <from, to> <- inheritanceM3@methodInvocation , from == |java+method:///edu/uva/analysis/samples/N/extReuse()|});
	//print ("Field access: "); 
	//iprintln({<from, to> | <from, to> <- inheritanceM3@fieldAccess , from == |java+method:///edu/uva/analysis/samples/N/extReuse()|});
	
	//println("******************************************************************************");
	//print ("Method invocation for variables only:");
	//iprintln({<from, to> |<from, to> <- inheritanceM3@methodInvocation, from == |java+variable:///edu/uva/analysis/samples/N/extReuse()/aCGlow| ||
																		//from == |java+variable:///edu/uva/analysis/samples/N/extReuse()/aGGlow| ||
																		//to == |java+variable:///edu/uva/analysis/samples/N/extReuse()/aCGlow| ||
																		//to == |java+variable:///edu/uva/analysis/samples/N/extReuse()/aGGlow|  });
	//print ("Containment: "); iprintln({<dClass, dField> | <dClass, dField> <- inheritanceM3@containment,
	//															dField == |java+field:///edu/uva/analysis/samples/P/intFieldParent|}); 
	//print ("Field access: "); iprintln(inheritanceM3@fieldAccess );
	//print("Declaration: "); iprintln(sort({<decl, prjct> | <decl, prjct> <- inheritanceM3@declarations}));
	//print ("Types: "); iprintln(sort({<from, to> | <from, to> <- inheritanceM3@types,
	//													from == |java+method:///edu/uva/analysis/samples/SubtypeRunner/aSubtypeViaReturnType()|}));
	//println("******************************************************************************");
	//print("Type dependency: "); 
	//rel [loc, loc] subtypeAssignmentTypeDep = { <from, to> | <from, to> <- inheritanceM3@typeDependency,
	//															isVariable(from),
	//															isClass(to) || isInterface(to) 
	//										  };

	//println("M3 Field Modifiers");
	//println("--------------------------------------------------------------------------");
	//lrel [loc, Modifier] myModifiers = sort({<from, to> | <from, to> <-inheritanceM3@modifiers,
	//																	isField(from)});
	//iprintln(myModifiers);																		
	//println("M3 Field Modifiers put in a map:");
	//map[loc definition, set[Modifier] modifier] modifiersPerField = index(myModifiers);
	//println("--------------------------------------------------------------------------");
	//iprintln(modifiersPerField);	
	//println(sort(subtypeAssignmentTypeDep));
							//from == |java+variable:///edu/uva/analysis/samples/SubtypeRunner/anotherSubtypeViaAssignment()/anSP| ||
								//from == |java+variable:///edu/uva/analysis/samples/SubtypeRunner/anotherSubtypeViaAssignment()/anSP2| ||
								//from == |java+variable:///edu/uva/analysis/samples/SubtypeRunner/anotherSubtypeViaAssignment()/anSP444| ||								
								//from == |java+variable:///edu/uva/analysis/samples/SubtypeRunner/subtypeViaAssignment()/anotherParent| ||
								//from == |java+variable:///edu/uva/analysis/samples/SubtypeRunner/subtypeViaAssignment()/aList| ||
								//from == |java+variable:///edu/uva/analysis/samples/SubtypeRunner/subtypeViaAssignment()/anSP33| ||
								//from == |java+variable:///edu/uva/analysis/samples/SubtypeRunner/subtypeViaAssignment()/aChild|  }; 
	//println("All type definitions for variables:");
	//iprintln(sort(subtypeAssignmenttypeDep));	
	//map [loc, set[loc]]	mapTypeDep = toMap(subtypeAssignmentTypeDep);
	////(fruit : fruits[fruit] | fruit <- fruits, size(fruit) <= 5);
	//set [loc] allSubtypeVars =  {typeDep | typeDep <- mapTypeDep, size(mapTypeDep[typeDep]) >= 2};				
	//map [loc, set [loc] ] varsAndClasses = (typeDep : mapTypeDep[typeDep] | typeDep <- mapTypeDep, size(mapTypeDep[typeDep]) >= 2);
	//for (loc x <- varsAndClasses) {
	//	println("Variable: <x>");
	//	println("has <size(varsAndClasses[x])> Classes: <varsAndClasses[x]>");
	//}
	//iprintToFile(|file://c:/Users/caytekin/InheritanceLogs/trial1.log|, inheritanceM3@typeDependency);
	//println("All type definitions for variables with two classes:");
	//iprintln(varsAndClasses);	
	//println("Overrides:");
	//iprintln(inheritanceM3@methodOverrides);
	return inheritanceM3;
}

public TypeSymbol getTypeSymbolFromSimpleType(Type aType) {
	TypeSymbol returnSymbol; 
	visit (aType) {
		case sType: \simpleType(typeExpr) : {
			returnSymbol =  typeExpr@typ;
		}
 	}
 	return returnSymbol;
}


private void getInfoForMethod(M3 projectModel, loc methodName) {
//|java+method:///edu/uva/analysis/samples/H/k(edu.uva.analysis.samples.P)|
	methodAST = getMethodASTEclipse(methodName, model = projectModel);
	// println("Method AST is: <methodAST>");
	visit(methodAST) {
		case newObject1:\newObject(Type \type, list[Expression] args) : {
		;}
		case newObject2:\newObject(Type \type, list[Expression] args, Declaration class) : {
		;}
		case newObject3:\newObject(Expression expr, Type \type, list[Expression] args) : {
		;}
		case newObject4:\newObject(Expression expr, Type \type, list[Expression] args, Declaration class) : {
		;}
		
		case cndStmt:\conditional(logicalExpr, thenBranch, elseBranch) : {
			//println("Logical expression: <logicalExpr>");
			//println("Type of the then branch : <thenBranch@typ>");
			//println("Type of the else branch : <elseBranch@typ>");
			//println("----------------------------------------------");
		;}
		// \conditional(Expression expression, Expression thenBranch, Expression elseBranch)
		case fAccess1:\fieldAccess(isSuper, expression, name) : {
			//println("Field access 1 ----------------------");
			//iprintln(expression);
		;}
    	case fAccess2:\fieldAccess(bool isSuper, str name) : {
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
		
		case f1:\fieldAccess(isSuper,name) : {
			    // \fieldAccess(bool isSuper, str name)
			    //println("Field access 1: ");
			    //println("Is super: <isSuper>, name: <name>");
				;
		}
		case f2:\fieldAccess(isSuper,expression,name) : {
				// 		(bool isSuper, Expression expression, str name)
			    //println("Field access 2: ");
			    //println("Is super: <isSuper>, expression: <expression>, name: <name>");
				;
		}
		
		case m1:\methodCall(_,_, args) : {
			//for (/this() := args) {
			//	println("m1: A this match at <m1@src>");
			//}
			//for (anArg <- args) {
			//	if (this() := anArg) {println("m1: SURFACE A this match at <m1@src>");;}
			//}		
		//case 1: case 3: case 5: {
			 // \methodCall(bool isSuper, str name, list[Expression] arguments)
			//println("m1: ");
			//text(m1);
			//dealWithMethodCall(m1, projectModel);
			;
		}
		case m2:\methodCall(_, _, _, args): {
			//for (/this() := args) {
			//	println("m2: A this match at <m2@src>");
			//}		
			//for (anArg <- args) {
			//	if (this() := anArg) {println("m2: SURFACE A this match at <m2@src>");;}
			//}
			//for (this() := args) {
			//	println("m2: SURFACE A this match at <m2@src>");
			//}			
        	//  \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments):
			//println("m2: ");
			//text(m2);
			//dealWithMethodCall(m2, projectModel);
   //     	println(m2);
   //     	println("receiver: <receiver>");
   //     	println("m2 Annotations: <getAnnotations(m2)>");
   //     	println("m2@typ: <m2@typ>");     
   //     	println("m2@decl with @decl: <m2@decl>");            	         	   	
   //     	println("Receiver annotations: <getAnnotations(receiver)>");
   //     	TypeSymbol typeOfReceiver = receiver@typ;
   //     	println("Receiver type: <typeOfReceiver>");
   //     	//println("Receiver class: <typeOfReceiver@decl>");        	        	
   //     	loc classOfReceiver = DEFAULT_LOC;
   //     	println("Is this a class? <isClass(classOfReceiver)>");
   //     	visit (typeOfReceiver) {
   //     		case c:\class(classLoc,_) : {
   //     			classOfReceiver = classLoc;  	
   //     		}
   //     	}
   //     	println("Receiver class: <classOfReceiver>");        	
   //     	// receiver@typ returns a TypeSymbol, this is again a Rascal construction (probably a node)
   //     	// which will be visited to find out the type of the receiver.
   //     	// The type of the receiver is also in the M3  	        	
   //     	println("Receiver declaration: <receiver@decl>");  	 
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
        case consCall1:\constructorCall(_, _): {
        //       (bool isSuper, list[Expression] arguments)
   //         print("constructor call 1: ");
			//println(consCall1); 
			;
        }
        case consCall2:\constructorCall(_, _, _): {
        //       (bool isSuper, Expression expr, list[Expression] arguments)
   //         print("constructor call 2: ");
			//println(consCall2); 
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





