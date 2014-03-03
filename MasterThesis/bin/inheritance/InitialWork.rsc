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


public bool areAllFieldsConstants(set [loc] fieldsInLoc, M3 projectM3) {
	bool retBool = false;
	lrel [loc, Modifier] myModifiers = {<from, to> | <from, to> <-inheritanceM3@modifiers,
																		from in fieldsInLoc};		
	map[loc definition, set[Modifier] modifier] modifiersPerField = index(myModifiers);

	// TODO: I am here.......-------->>>>>>>  3-3-2014, 332014
	// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
}


public bool containsConstantFieldsOnly(loc aLoc, M3 projectM3) {
	// we just want fields in the location
	bool retBool = false;
	set [loc] fieldsInLoc = {aField | <classOrInterface, aField>  <- projectM3@containment, 
													isField(aField),
													(classOrInterface == aLoc)};
	set [loc] everythingInLoc = {anItem | <classOrInterface, anItem> <- projectM3@containment,
													(classOrInterface == aLoc)};
	if (!isEmpty(fieldsInLoc) && isEmpty(everythingInLoc - fieldsInLoc) && areAllFieldsConstants(fieldsInLoc, projectM3)) {
		
		retBool = true;
	}
	return retBool;													
}  


public void getConstants(M3 projectM3) {
	if (containsConstantFieldsOnly(aLocation, projectM3)) {
	;}
	
}



public void runInitialWork() {
	M3 m3Model = getM3Model();
	                       //<|java+constructor:///edu/uva/analysis/samples/Sub1/Sub1(int)|
	//getInfoForMethod(m3Model, |java+method:///edu/uva/analysis/samples/DowncallParent/p()|);
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
			println("I am here with 4 args");
			println("Is receiver this: <isReceiverThis(receiver)>");
			text(m2);
			args = myArgs;
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





private M3 getM3Model() {
	M3 inheritanceM3 = createM3FromEclipseProject(|project://InheritanceSamples|);
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

	println("M3 Field Modifiers");
	println("--------------------------------------------------------------------------");
	lrel [loc, Modifier] myModifiers = sort({<from, to> | <from, to> <-inheritanceM3@modifiers,
																		isField(from)});
	iprintln(myModifiers);																		
	println("M3 Field Modifiers put in a map:");
	map[loc definition, set[Modifier] modifier] modifiersPerField = index(myModifiers);
	println("--------------------------------------------------------------------------");
	iprintln(modifiersPerField);	
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
	 //text(methodAST);
	visit(methodAST) {
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
    		//	println("The field: <expression@decl> is defined in class: <getDefiningClassOfALoc(expression@decl, projectModel)>");
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
		
		case m1:\methodCall(_,_, _) : {
		//case 1: case 3: case 5: {
			 // \methodCall(bool isSuper, str name, list[Expression] arguments)
			//println("m1: ");
			//text(m1);
			//dealWithMethodCall(m1, projectModel);
			;
		}
		case m2:\methodCall(_, _, _, _): {
        	//  \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments):
			//println("m2: ");
			//text(m2);
			dealWithMethodCall(m2, projectModel);
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





