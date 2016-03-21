package uhx.macro;

import haxe.macro.Printer;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Compiler;

using haxe.macro.Context;
using haxe.macro.ExprTools;
using haxe.macro.TypedExprTools;

/**
 * ...
 * @author Skial Bainn
 */
class Trait {
	
	public static function build() {
		return handler( Context.getLocalType() , Context.getBuildFields() );
	}
	
	public static function handler(type:Type, fields:Array<Field>):Array<Field> {
		var meta:Metadata = null;
		
		switch (type) {
			case TInst(_.get() => cls, params):
				meta = cls.meta.get();
				
			case _:
				
		}
		
		if (meta != null) {
			for (m in meta) if (m.name == ':use') {
				for (p in m.params) switch (p.expr) {
					case EConst(CIdent(ident)):
						trace( ident );
						switch (Context.getType( ident )) {
							case TInst(_.get() => cls, params):
								trace( cls.name );
								if (fields.filter( function(f) return f.name == 'new' ).length == 0 && cls.constructor != null) fields = fields.concat( handleClassFields( [cls.constructor.get()] ) );
								fields = fields.concat( handleClassFields( cls.fields.get() ).filter( duplicates.bind(_, fields) ) );
								fields = fields.concat( handleClassFields( cls.statics.get(), true ).filter( duplicates.bind(_, fields) ) );
								
							case _:
								
						}
						
					case _:
						
				}
				
			}
			
		}
		
		return fields;
	}
	
	public static function handleClassFields(fields:Array<ClassField>, ?isStatic:Bool = false):Array<Field> {
		var results = [];
		
		for (field in fields) {
			//trace( field.name, field.meta.get().filter( function(m) return m.name == ':astSource' ).map( function(m) return m.params[0] ) );
			
			var body = field.meta.get().filter( function(m) return m.name == ':astSource' ).map( function(m) return m.params[0] )[0];
			var newField:Field = {
				meta: field.meta.get(),
				name: field.name,
				pos: field.pos,
				kind: null,
				access: [field.isPublic ? APublic : APrivate].concat( isStatic ? [AStatic] : [] ),
			}
			
			switch (field.kind) {
				case FMethod(k):
					var fieldType = switch (field.type) {
						case TLazy(f): f();
						case _: field.type;
					}
					
					var ret:ComplexType = null;
					var args:Array<FunctionArg> = [];
					
					switch (fieldType) {
						case TFun(a, r):
							ret = r.toComplexType();
							
							if (!'display'.defined()) {
								var expr = try field.expr().getTypedExpr() catch (e:Dynamic) null;
								
								if (expr != null) switch (expr.expr) {
									case EFunction(name, method):
										args = method.args;
										
									case _:
										
								} 
								
								if (expr == null && a.length > 0) {
									args = a.map( function(arg) {
										return { name:arg.name, type:arg.t.toComplexType(), opt:arg.opt } 
									} );
									
								}
								
							}
							
						case _:
							
					}
					
					switch (k) {
						case MethMacro: newField.access.push( AMacro );
						case MethInline: newField.access.push( AInline );
						case MethDynamic: newField.access.push( ADynamic );
						case _:
					}
					
					newField.kind = FFun( {
						args: args,
						ret: (field.name == 'new') ? null : ret,
						expr: body,
					} );
					
				case FVar(r, w):
					var fieldType = switch (field.type) {
						case TLazy(f): f();
						case _: field.type;
					}
					
					var get = null;
					var set = get;
					var expr = try field.expr().getTypedExpr() catch (e:Dynamic) null;
					
					if (!'display'.defined()) {
						switch (r) {
							case AccNo: get = 'null';
							case AccNever: get = 'never';
							case AccCall: 
								for (f in fields) if (f.name == 'get_${field.name}') {
									get = 'get';
									break;
									
								}
								if (get != 'get') get = 'dynamic';
								
							case AccNormal: get = 'default';
							case _:
						}
						
						switch (w) {
							case AccNo: set = 'null';
							case AccNever: set = 'never';
							case AccCall: 
								for (f in fields) if (f.name == 'set_${field.name}') {
									set = 'set';
									break;
									
								}
								if (set != 'set') set = 'dynamic';
								
							case AccNormal: set = 'default';
							case _:
						}
						
					}
					
					newField.kind = get != null && set != null ? FProp(get, set, fieldType.toComplexType(), expr ) : FVar( fieldType.toComplexType(), expr );
					
				
			}
			
			results.push( newField );
			//trace( new Printer().printField( newField ) );
			
		}
		
		return results;
	}
	
	private static function duplicates(f1:Field, fields:Array<Field>):Bool {
		return fields.filter( function(f2) return f2.name == f1.name ).length == 0;
	}
	
	public static function initialize() {
		#if klas
		
		#else
		Compiler.addGlobalMetadata('', '@:astSource', true, false, true);
		#end
	}
	
}