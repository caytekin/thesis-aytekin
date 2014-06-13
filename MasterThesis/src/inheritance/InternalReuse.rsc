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



lrel [inheritanceKey, inheritanceSubtype, internalReuseDetail] getClassLevelInternalReuse(loc oneClass, set [loc] declaredFields, set [loc] declaredMethods, 
																							set [loc] ancestorFieldsMethods, map [loc, set [loc]] invocationMap, map [loc, set [loc]] fieldAccessFromClassMap,
																							map [loc, set [loc]] invertedContainmentMap) {
	lrel [inheritanceKey, inheritanceSubtype, internalReuseDetail] retRel = [];
	set [loc] invokedMethodsClassLevel 	= oneClass in invocationMap ? invocationMap[oneClass] : {};
	set [loc] accessedFieldsClassLevel  = oneClass in fieldAccessFromClassMap ? fieldAccessFromClassMap[oneClass] : {};
	set [loc] internalReuseLocs 		= 	{aMethod | aMethod <- invokedMethodsClassLevel, isMethod(aMethod), aMethod notin declaredMethods,  aMethod in ancestorFieldsMethods }
	  									    +
	  									    {aField | aField <- accessedFieldsClassLevel, isField(aField), aField notin declaredFields, aField in ancestorFieldsMethods };
	for (reusedLoc <- internalReuseLocs) {
		loc parentClass =  getDefiningClassOfALoc(reusedLoc, invertedContainmentMap);
		inheritanceKey iKey = <oneClass, parentClass>;
		retRel += < iKey, INTERNAL_REUSE_CLASS_LEVEL, <reusedLoc, oneClass>>;		
	};																			
	return retRel; 							    
}	
			


public rel [inheritanceKey, inheritanceType] getInternalReuseCases(M3 projectM3) {
	// Get all the child classes in CC relation, they are the only ones which can initiate internal reuse.
	// The super() calls in the constructors are not counted as internal reuse, also see assumptions document.
	//
	// In classes, not only the methods, but also the initializers are taken into account
	rel [inheritanceKey, inheritanceType] resultRel = {};
	lrel [inheritanceKey, inheritanceSubtype, internalReuseDetail] internalReuseLog = []; 
	rel [loc, loc] allInheritanceRels = getNonFrameworkInheritanceRels(getInheritanceRelations(projectM3), projectM3);
	set [loc] intReuseClasses = { child | <child, parent> <- allInheritanceRels, isClass(child), isClass(parent)};
	map [loc, set [loc]] containmentMap 		= toMap({<owner, declared> |<owner, declared> <- projectM3@containment, isClass(owner), isField(declared) || isMethod(declared)});
	map [loc, set [loc]] containmentMapWithInit = toMap({<owner, declared> |<owner, declared> <- projectM3@containment, isClass(owner), isField(declared) || isMethod(declared) || declared.scheme == "java+initializer"});
	map [loc, set [loc]] invertedContainmentMap = toMap(invert({<owner, declared> |<owner, declared> <- projectM3@containment, isClass(owner), isField(declared) || isMethod(declared) || declared.scheme == "java+initializer"}));
	map [loc, set [loc]] invocationMap 			= toMap({ <caller, invoked> | <caller, invoked> <- projectM3@methodInvocation});
	map [loc, set [loc]] fieldAccessFromMethodMap 		= toMap({<accessor, accessed> | <accessor, accessed> <- projectM3@fieldAccess, isMethod(accessor) || accessor.scheme == "java+initializer"});
	map [loc, set [loc]] fieldAccessFromClassMap 		= toMap({<accessor, accessed> | <accessor, accessed> <- projectM3@fieldAccess, isClass(accessor)});

	for (oneClass <- intReuseClasses) {
		// println("One class is: <oneClass>");
		set [loc] ancestorClasses = { parent | <child, parent> <- allInheritanceRels, child == oneClass, isClass(parent)};
		set [loc] ancestorFieldsMethods = {};
		for (anAncestorClass <- ancestorClasses) {
			ancestorFieldsMethods += anAncestorClass in containmentMap ? containmentMap[anAncestorClass] : {}; 
		}		
		set [loc] declaredFieldsMethods = oneClass in containmentMapWithInit ? containmentMapWithInit[oneClass] : {} ; 
		set [loc] declaredMethods = { declMeth | declMeth <- declaredFieldsMethods, isMethod(declMeth) || declMeth.scheme == "java+initializer" };
		set [loc] declaredFields = declaredFieldsMethods - declaredMethods;
			
		internalReuseLog += getClassLevelInternalReuse(oneClass, declaredFields, declaredMethods, 	ancestorFieldsMethods, invocationMap, 
																									fieldAccessFromClassMap, invertedContainmentMap );	
		for (oneMethod <- declaredMethods) {
			set [loc] allInvokedMethods	= oneMethod in invocationMap ? invocationMap[oneMethod] : {};
			
			set [loc] internalReuseMethodInvocation = { invoked | invoked <- allInvokedMethods, invoked notin declaredFieldsMethods, 
																			invoked in ancestorFieldsMethods, 
																			invoked.scheme != "java+constructor" };	
			set [loc] allAccessedFields = oneMethod in fieldAccessFromMethodMap ? fieldAccessFromMethodMap[oneMethod] : {} ;																
																			
			set [loc] internalReuseFieldAccess = { accessed | accessed <- allAccessedFields,  accessed notin declaredFieldsMethods, 
																							  accessed in ancestorFieldsMethods };
			set [loc] internalReuseLoc = internalReuseMethodInvocation + internalReuseFieldAccess;																		
			for (reusedLoc <- internalReuseLoc) {
				loc parentClass =  getDefiningClassOfALoc(reusedLoc, invertedContainmentMap);
				inheritanceKey iKey = <oneClass, parentClass>;
				internalReuseLog += < iKey, INTERNAL_REUSE_METHOD_LEVEL, <reusedLoc, oneMethod>>;		
			};																			
		};	
	};
	
	resultRel = {<iKey, INTERNAL_REUSE> | <iKey, _, <_,_>> <- internalReuseLog};
	iprintToFile(getFilename(projectM3.id, internalReuseLogFile), internalReuseLog);
	println("Size of internal reuse log is: <size(internalReuseLog)>");
	return resultRel;
}

