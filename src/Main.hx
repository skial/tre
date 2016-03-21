package;

/**
 * ...
 * @author Skial Bainn
 */
class Main {
	
	static function main() {
		var a = new Implementation1();
		var b = new Implementation2();
	}
	
}

private class Trait1 {
	
	public var a:Int = 0;
	public var b:Int;
	public var c(get, set):String;
	public var d(get, dynamic):String;
	public var e(dynamic, set):String;
	
	public function new() {
		
	}
	
	public function ma(a:String, b:String, ?c:String, d:String = 'boo'):Array<String> {
		return [a, b];
	}
	
	public static function mb(a:Int, b:Float, ?c:String, d:Bool = false):Array<Dynamic> {
		return [a, b, c, d];
	}
	
	public static inline function mc(a:Int, b:Int, ?c:Int, d:Int = 10):Int {
		return a + b + (c == null ? 100 : c) + d;
	}
	
	private function get_c() return 'hello';
	private function set_c(v:String):String return v;
	
	private function get_d():String return 'goodbye';
	
	private function set_e(v:String):String return v;
	
}

private class Trait2 {
	
	public var a:String = 'a';
	
	public function new(b:Int = 10) {
		
	}
	
}

@:use(Trait1, Trait2)
@:build( uhx.macro.Trait.build() )
private class Implementation1 {
	
	
	
}

@:use(Trait2, Trait1)
@:build( uhx.macro.Trait.build() )
private class Implementation2 {
	
	
	
}
