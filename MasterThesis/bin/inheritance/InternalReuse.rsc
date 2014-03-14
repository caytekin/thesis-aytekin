module inheritance::InternalReuse

import IO;
import Map;
import Set;
import Relation;
import List;
import ListRelation;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import inheritance::InheritanceDataTypes;
import inheritance::InheritanceModules;




public rel [inheritanceKey, inheritanceType] getInternalReuseCases(M3 projectM3) {
	// Get all the child classes in CC relation, they are the only ones which can initiate internal reuse.
	//
	// The super() calls in the constructors are not counted as internal reuse, also see assumptions document.
	//
	// In classes, not only the methods, but also the initializers are taken into account
	//
	// I do NOT traverse  framework inheritance relationships.
	//
	// It also works for arrays and collections
	//
	// TODO: I should look (and test) if I take the constructors in to account.
	// A constructor can also invoke parent methods (not only super())
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, internalReuseDetail] internalReuseLog = []; 
	rel [loc, loc] allInheritanceRels = getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);
	set [loc] intReuseClasses = { child | <child, parent> <- allInheritanceRels, isClass(child), isClass(parent)};
	map [loc, set [loc]] containmentMap 		= toMap({<owner, declared> |<owner, declared> <- projectM3@containment, isClass(owner), isField(declared) || isMethod(declared)});
	map [loc, set [loc]] containmentMapWithInit = toMap({<owner, declared> |<owner, declared> <- projectM3@containment, isClass(owner), isField(declared) || isMethod(declared) || declared.scheme == "java+initializer"});
	map [loc, set [loc]] invertedContainmentMap = toMap(invert({<owner, declared> |<owner, declared> <- projectM3@containment, isClass(owner), isField(declared) || isMethod(declared) || declared.scheme == "java+initializer"}));
	map [loc, set [loc]] invocationMap 			= toMap({ <caller, invoked> | <caller, invoked> <- projectM3@methodInvocation});
	map [loc, set [loc]] fieldAccessMap 		= toMap({<accessor, accessed> | <accessor, accessed> <- projectM3@fieldAccess, isMethod(accessor) || accessor.scheme == "java+initializer"});
	// map [loc, set[loc]] methInvocationMap = toMap(projectM3@methodInvocation);
	for (oneClass <- intReuseClasses) {
		// println("One class is: <oneClass>");
		set [loc] ancestorClasses = { parent | <child, parent> <- allInheritanceRels, child == oneClass, isClass(parent)};
		set [loc] ancestorFieldsMethods = {};
		for (anAncestorClass <- ancestorClasses) {
			ancestorFieldsMethods += anAncestorClass in containmentMap ? containmentMap[anAncestorClass] : {}; 
		}		
		
		set [loc] declaredFieldsMethods = oneClass in containmentMapWithInit ? containmentMapWithInit[oneClass] : {} ; 
		
		set [loc] declaredMethods = { declMeth | declMeth <- declaredFieldsMethods, isMethod(declMeth) || declMeth.scheme == "java+initializer" };
										
		for (oneMethod <- declaredMethods) {
			set [loc] allInvokedMethods	= oneMethod in invocationMap ? invocationMap[oneMethod] : {};
			
			set [loc] internalReuseMethodInvocation = { invoked | invoked <- allInvokedMethods, invoked notin declaredFieldsMethods, 
																			invoked in ancestorFieldsMethods, 
																			invoked.scheme != "java+constructor" };	
			set [loc] allAccessedFields = oneMethod in fieldAccessMap ? fieldAccessMap[oneMethod] : {} ;																
																			
			set [loc] internalReuseFieldAccess = { accessed | accessed <- allAccessedFields,  accessed notin declaredFieldsMethods, 
																							  accessed in ancestorFieldsMethods };
																							  	
			set [loc] internalReuseLoc = internalReuseMethodInvocation + internalReuseFieldAccess;																		
			for (reusedLoc <- internalReuseLoc) {
				set [loc]  classOfLoc = reusedLoc in invertedContainmentMap ? invertedContainmentMap[reusedLoc] : {}; 
				if (size(classOfLoc) != 1) { throw "A method or a field  can be defined in one class only! <reusedLoc>"; }; 
				loc parentClass = getOneFrom(classOfLoc);
				inheritanceKey iKey = <oneClass, parentClass>;
				resultRel  += < iKey, INTERNAL_REUSE>;
				internalReuseLog += < iKey, <reusedLoc, oneMethod>>;		
			};																			
		};	
	};
	iprintToFile(internalReuseLogFile , internalReuseLog);
	return resultRel;
}

