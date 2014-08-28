module inheritance::Test1

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


public void main() {
	loc projectLoc = |project://VerySmallProject|;
	M3 projectM3 = createM3FromEclipseProject(projectLoc);
	println("Extends annotation:");
	iprintln(sort(projectM3@extends));
	println("Implements annotation:");
	iprintln(sort(projectM3@implements));
}
