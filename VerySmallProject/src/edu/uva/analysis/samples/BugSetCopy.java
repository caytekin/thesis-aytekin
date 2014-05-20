package edu.uva.analysis.samples;

/*
 * FindBugs - Find Bugs in Java programs
 * Copyright (C) 2006, University of Maryland
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston MA 02111-1307, USA
 */



import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;



/**
 * BugSet is what we use instead of SortedBugCollections.  BugSet is somewhat poorly named, in that its actually a HashList of bugs, 
 * not a Set of them.  (It can't be a set because we need to be able to sort it, also, HashList is great for doing contains and indexOf, its just slow for removing which we never need to do)  The power of BugSet is in query.  You can query a BugSet with a BugAspects, a list of StringPairs like <priority,high>, <designation,unclassified>
 * and you will get out a new BugSet containing all of the bugs that are both high priority and unclassified.  Also, after the first time a query is made, the results will come back instantly on future calls
 * because the old queries are cached.  Note that this caching can also lead to issues, problems with the BugTreeModel and the JTree getting out of sync, if there comes a time when the model and tree are out of sync
 * but come back into sync if the tree is rebuilt, say by sorting the column headers, it probably means that resetData needs to be called on the model after doing one of its operations.  
 * 
 * @author Dan
 *
 */
public class BugSetCopy implements Iterable<BugLeafNode>{

	private ArrayList<BugLeafNode> mainList;
	private HashMap<SortableValue,BugSetCopy> doneMap;


	public static BugSetCopy getMainBugSet()
	{
		return new BugSetCopy(new ArrayList());
	}

	BugSetCopy(Collection<? extends BugLeafNode> filteredSet)
	{
		this.mainList=new ArrayList<BugLeafNode>(filteredSet);
		doneMap=new HashMap<SortableValue,BugSetCopy>();
	}

	@Override
	public Iterator<BugLeafNode> iterator() {
		// TODO Auto-generated method stub
		return null;
	}

}

