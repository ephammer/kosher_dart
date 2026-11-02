import 'dart:io';import 'dart:mirrors';import 'package:kosher_dart/kosher_dart.dart';
String? norm(Object? v){if(v==null)return 'null';if(v is DateTime)return '${v.millisecondsSinceEpoch}';if(v is double)return v.isFinite?'${v.round()}':'null';if(v is int||v is bool)return '$v';
 if(v is Enum)return v.name.replaceAll('_','').toUpperCase();if(v is Daf)return '${v.getMasechtaNumber()}:${v.getDaf()}';return null;}
List<Symbol> ms(Type t,int n){final l=<Symbol>[];reflectClass(t).instanceMembers.forEach((s,m){final x=MirrorSystem.getName(s);if(!m.isRegularMethod||m.isStatic||x.startsWith('_')||!(x.startsWith('get')||x.startsWith('is')))return;if(m.parameters.where((p)=>!p.isOptional).length!=n)return;l.add(s);});l.sort((a,b)=>MirrorSystem.getName(a).compareTo(MirrorSystem.getName(b)));return l;}
void dump(IOSink w,String k,Object o,List<Symbol> l,[List a=const []]){final r=reflect(o);for(final s in l){String? v;try{v=norm(r.invoke(s,a).reflectee);if(v==null)continue;}catch(e){v='ERR';}w.writeln('$k|${MirrorSystem.getName(s)}|$v');}}
String safe(String Function() f){try{return f();}catch(e){return 'ERR';}}
Future<void> main(List<String> x)async{final w=File(x[1]).openWrite();
 if(x[0]=='zman'){final l=ms(ComplexZmanimCalendar,0);final n=x[2];final lat=double.parse(x[3]),lon=double.parse(x[4]),e=double.parse(x[5]);
  for(var d=DateTime.utc(2026);d.year==2026;d=d.add(const Duration(days:1))){final dt=DateTime(d.year,d.month,d.day);final g=GeoLocation.setLocation(n,lat,lon,dt,e);final c=ComplexZmanimCalendar.intGeoLocation(g);c.setUseElevation(e>0);c.setCalendar(dt);
   dump(w,'$n|${d.toIso8601String().substring(0,10)}',c,l);await w.flush();}
 }else{final l=ms(JewishCalendar,0);final t=ms(TefilaRules,1);final r=TefilaRules();final he=HebrewDateFormatter()..hebrewFormat=true;final en=HebrewDateFormatter();
  for(final il in [false,true])for(var d=DateTime.utc(2000);d.year<=2050;d=d.add(const Duration(days:1))){final j=JewishCalendar.fromDateTime(DateTime(d.year,d.month,d.day));j.inIsrael=il;j.setUseModernHolidays(true);final k='${il?"IL":"DI"}|${d.toIso8601String().substring(0,10)}';
   dump(w,k,j,l);dump(w,k,r,t,[j]);var fi=0;for(final f in [he,en]){final p=fi++==0?'he.':'en.';
    void o(String a,String Function() g)=>w.writeln('$k|$p$a|${safe(g)}');o('format',()=>f.format(j));o('yomtov',()=>f.formatYomTov(j));o('rc',()=>f.formatRoshChodesh(j));o('omer',()=>f.formatOmer(j));o('dow',()=>f.formatDayOfWeek(j));o('parsha',()=>f.formatWeeklyParsha(j));o('special',()=>f.formatSpecialParsha(j));o('daf',()=>f.formatDafYomiBavli(j.getDafYomiBavli()));}
   await w.flush();}}
 await w.close();}
