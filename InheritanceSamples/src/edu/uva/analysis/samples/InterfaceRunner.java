package edu.uva.analysis.samples;



public abstract class InterfaceRunner {
	abstract Object getObject() throws Exception;

	final Object getApiObject() throws Exception{
		Object obj = getObject();
		if(obj instanceof MyMutable){
			return ((MyMutable)obj).getImmutableObject();
		}
		return obj;
	}
	
	void tryWithAPackage() {
		edu.uva.analysis.gensamples.Rectangle myRectangle = new edu.uva.analysis.gensamples.Rectangle();
	}

	void invokeAMethod() {
		I2 anI2= new ImplI2();
		anI2.i2();
	}
	
}
