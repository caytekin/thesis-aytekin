package edu.uva.analysis.gensamples;

import java.lang.instrument.Instrumentation;

public interface InstrumentChild extends Instrumentation {
	
	void instrumentChildMethod();

}
