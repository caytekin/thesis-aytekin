package edu.uva.analysis.samples;

import java.net.HttpCookie;
import java.net.URI;
import java.util.List;

public class CookieChildImplementor implements CookieChild {

	public CookieChildImplementor() {
		
	}

	@Override
	public void add(URI uri, HttpCookie cookie) {
	}

	@Override
	public List<HttpCookie> get(URI uri) {
		return null;
	}

	@Override
	public List<HttpCookie> getCookies() {
		return null;
	}

	@Override
	public List<URI> getURIs() {
		return null;
	}

	@Override
	public boolean remove(URI uri, HttpCookie cookie) {
		return false;
	}

	@Override
	public boolean removeAll() {
		return false;
	}

	@Override
	public void someMethod() {
		// TODO Auto-generated method stub
		
	}

}
