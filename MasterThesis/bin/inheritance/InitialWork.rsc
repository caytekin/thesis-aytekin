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
import lang::java::m3::TypeSymbol;

loc DEFAULT_LOC = |java+project:///|;

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
	print ("Containment: "); iprintln({<dClass, dMethod> | <dClass, dMethod> <- inheritanceM3@containment,
																dMethod == |java+method:///edu/uva/analysis/samples/P/returnOne()|}); 
	//print ("Field access: "); iprintln(inheritanceM3@fieldAccess );
	//print("Declaration: "); iprintln({<decl, prjct> | <decl, prjct> <- inheritanceM3@declarations}); 
														//isClass(decl) || isInterface(decl)}));
	//print ("Types: "); iprintln(inheritanceM3@types);
	//println("******************************************************************************");
	//print("Type dependency: "); 
	//iprintln({<from, to> | <from, to> <- inheritanceM3@typeDependency, 
	//							from == |java+variable:///edu/uva/analysis/samples/N/extReuse()/aCGlow| ||
	//							from == |java+variable:///edu/uva/analysis/samples/N/extReuse()/aGGlow| });
	//iprintToFile(|file://c:/Users/caytekin/InheritanceLogs/trial1.log|, inheritanceM3@typeDependency);
	return inheritanceM3;
}

private void getInfoForMethod(M3 projectModel, loc methodName) {
//|java+method:///edu/uva/analysis/samples/H/k(edu.uva.analysis.samples.P)|
	methodAST = getMethodASTEclipse(methodName, model = projectModel);
	//println("Method AST is: <methodAST>");run
	visit(methodAST) {
		case f1: \fieldAccess(_,_) : {
			    // \fieldAccess(bool isSuper, str name)
			    println("Field access 1: ");
			    println("Is super: <isSuper>, name: <name>");
		}
		case f2: \fieldAccess(_,_,_) : {
				// 		(bool isSuper, Expression expression, str name)
			    println("Field access 2: ");
			    println("Is super: <isSuper>, expression: <expression>, name: <name>");
		}
		
		case m1:\methodCall(_, _, _): {
			 // \methodCall(bool isSuper, str name, list[Expression] arguments)
			//print("m1: ");
			//println(m1);
			;
		}
		case m2:\methodCall(_, receiver:_, _, _): {
        	//  \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments):
			//print("m2: ");
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
        case a:\assignment(_, _, _) : {  
        	// 	\assignment(Expression lhs, str operator, Expression rhs)
			print("assignment: ");  
			println(a); 
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

public bool isMethodInProject(loc methodPar, M3 projectM3) {
	return ! isEmpty({<aMethod> | <aClass, aMethod> <- projectM3@containment, aMethod == methodPar});
}


public void runInitialWork() {
	M3 m3Model = getM3Model();
	                       //<|java+constructor:///edu/uva/analysis/samples/Sub1/Sub1(int)|
	//getInfoForMethod(m3Model, |java+method:///edu/uva/analysis/samples/H/k(edu.uva.analysis.samples.P)|);
	getInfoForMethod(m3Model, |java+method:///edu/uva/analysis/samples/N/extReuse()|);
	//getInfoForMethod(m3Model, |java+method:///edu/uva/analysis/gensamples/Canvas/drawAll(java.util.List)|);	
	//getInfoForMethod(m3Model, |java+constructor:///edu/uva/analysis/samples/Sub1/Sub1(int)|);	
	
}