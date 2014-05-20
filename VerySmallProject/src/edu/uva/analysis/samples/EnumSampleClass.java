package edu.uva.analysis.samples;

public class EnumSampleClass {

	public EnumSampleClass() {
		
	}
	
	interface ViewFilterEnum {
		boolean show();
	}

	
	enum RankFilter implements ViewFilterEnum {
		SCARIEST(4, "Scariest"), SCARY(9, "Scary"), TROUBLING(14, "Troubling"), ALL(Integer.MAX_VALUE, "All bug ranks");
		final int maxRank;

		final String displayName;

		private RankFilter(int maxRank, String displayName) {
			this.maxRank = maxRank;
			this.displayName = displayName;
		}

		public boolean show() {
			return true;
		}

		@Override
		public String toString() {
			if (maxRank < Integer.MAX_VALUE)
				return displayName + " (Ranks 1 - " + maxRank + ")";
			return displayName;
		}

	}

}
