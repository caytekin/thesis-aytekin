module inheritance::InitialWork

import IO;
import Set;
import List;
import Map;
import ListRelation;
import Node;
import ValueIO;

import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::m3::TypeSymbol;
import util::ValueUI;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;



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
	//print ("Containment: "); iprintln({<dClass, dMethod> | <dClass, dMethod> <- inheritanceM3@containment,
	//															dMethod == |java+method:///edu/uva/analysis/samples/P/returnOne()|}); 
	//print ("Field access: "); iprintln(inheritanceM3@fieldAccess );
	//print("Declaration: "); iprintln({<decl, prjct> | <decl, prjct> <- inheritanceM3@declarations}); 
														//isClass(decl) || isInterface(decl)}));
	//print ("Types: "); iprintln(inheritanceM3@types);
	//println("******************************************************************************");
	//print("Type dependency: "); 
	rel [loc, loc] subtypeAssignmentTypeDep = { <from, to> | <from, to> <- inheritanceM3@typeDependency,
																isVariable(from),
																isClass(to) || isInterface(to) 
											  };
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
	println("Method AST is: <methodAST>");
	text(methodAST);
	visit(methodAST) {
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
			println("--------------------------------------------------");
		 	TypeSymbol lhsTypeSymbol ;
		 	visit (typeOfVar) {
		 		case sType: \simpleType(typeExpr) : {
		 			lhsTypeSymbol =  getTypeSymbolFromSimpleType(sType);
		 		}
		 		case atype :\arrayType(simpleTypeOfArray) : {
		 			lhsTypeSymbol = getTypeSymbolFromSimpleType(simpleTypeOfArray);
		 		}
		 	}
		 	//println("Lhs type symbol is: <lhsTypeSymbol>");
		 	println("Lhs Java type is: <getClassOrInterfaceFromTypeSymbol(lhsTypeSymbol)>");
			for (anExpression <- fragments) {
				loc rhsClass;
				println("Variable name: <anExpression@decl>");
				visit (anExpression) {
					case myVar: \variable(_,_,stmt) : {
						rhsClass = getClassOrInterfaceFromTypeSymbol(stmt@typ);
						println("Right hand side class: <rhsClass>");
					} 
				} // visit
				
			} // for
		}
		case a:\assignment(lhs, operator, rhs) : {  
        	// 	\assignment(Expression lhs, str operator, Expression rhs)
        	println("--------------------------------------------------------------------");
			println("assignment: ");  
			loc lhsClass = getClassFromTypeSymbol(lhs@typ);
			lhsClass = getInterfaceFromTypeSymbol(lhs@typ);
			println("Class or interface: <getClassOrInterfaceFromTypeSymbol(lhs@typ)>");
			loc rhsClass = getClassFromTypeSymbol(rhs@typ);
			println("Left hand side is of type : <lhsClass>");
			println("Right hand side is of type : <rhsClass>");						
			if (lhsClass != rhsClass) {
				set [loc] allClasses = getAllClassesAndInterfacesInProject(projectModel);
				if ( (lhsClass in allClasses) && (rhsClass in allClasses)) {
					println("Lhs name: <lhs@decl>");
					println("Rhs name: <rhs@decl>");					
					println("Subtype via assignment.");
				}	
			}
			println("Assignment statement <a>");
			println("Source of the assignment statement <a@src>");			
			// Subtype via declarations are in the typeDependency annotation
			// in typeDependency you get two entries instead of one, one is the type
			// the other is the class where the variable refers to
			
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
		
		case m1:\methodCall(_, _, _): {
			 // \methodCall(bool isSuper, str name, list[Expression] arguments)
			print("m1: ");
			//println(m1);
			;
		}
		case m2:\methodCall(_, receiver:_, _, _): {
        	//  \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments):
			print("m2: ");
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
        	print("cast: ");
			println(c); 
        }
        case super1:\super(): {
            print("super: ");
			println(super1); 
        }
        case consCall1:\constructorCall(_, _): {
        //       (bool isSuper, list[Expression] arguments)
            print("constructor call 1: ");
			println(consCall1); 
        }
        case consCall2:\constructorCall(_, _, _): {
        //       (bool isSuper, Expression expr, list[Expression] arguments)
            print("constructor call 2: ");
			println(consCall2); 
        }
        
	} // visit
}





public void runInitialWork() {
	M3 m3Model = getM3Model();
	                       //<|java+constructor:///edu/uva/analysis/samples/Sub1/Sub1(int)|
	//getInfoForMethod(m3Model, |java+method:///edu/uva/analysis/samples/H/k(edu.uva.analysis.samples.P)|);
	getInfoForMethod(m3Model, |java+method:///edu/uva/analysis/samples/N/fieldTest()|);
	//getInfoForMethod(m3Model, |java+method:///edu/uva/analysis/gensamples/Canvas/drawAll(java.util.List)|);	
	//getInfoForMethod(m3Model, |java+constructor:///edu/uva/analysis/samples/Sub1/Sub1(int)|);	
	
}