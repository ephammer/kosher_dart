import com.kosherjava.zmanim.*;import com.kosherjava.zmanim.util.*;import com.kosherjava.zmanim.hebrewcalendar.*;
import java.lang.reflect.*;import java.time.*;import java.util.*;import java.io.*;
public class Dump{
 static String norm(Object v){ if(v==null)return "null"; if(v instanceof Instant)return ""+((Instant)v).toEpochMilli();
  if(v instanceof Duration)return ""+((Duration)v).toMillis(); if(v instanceof Double)return ""+Math.round((Double)v); if(v instanceof Number||v instanceof Boolean)return v.toString();
  if(v instanceof Enum)return ((Enum<?>)v).name().replace("_","").toUpperCase(); if(v instanceof Daf)return ((Daf)v).getMasechtaNumber()+":"+((Daf)v).getDaf(); return null;}
 static List<Method> ms(Class<?> c,int n){List<Method> l=new ArrayList<>();for(Method m:c.getMethods()){String s=m.getName();
  if(Modifier.isStatic(m.getModifiers())||m.getParameterCount()!=n||!(s.startsWith("get")||s.startsWith("is")))continue;
  if(m.getDeclaringClass()==Object.class)continue;l.add(m);}l.sort(Comparator.comparing(Method::getName));return l;}
 static void dump(PrintWriter w,String k,Object o,List<Method> l,Object...a){for(Method m:l){String r;try{r=norm(m.invoke(o,a));if(r==null)continue;}catch(Exception e){r="ERR";}w.println(k+"|"+m.getName()+"|"+r);}}
 public static void main(String[] x)throws Exception{PrintWriter w=new PrintWriter(new BufferedWriter(new FileWriter(x[1])));
  if(x[0].equals("zman")){List<Method> l=ms(ComprehensiveZmanimCalendar.class,0);
   String n=x[2];GeoLocation g=new GeoLocation(n,Double.parseDouble(x[3]),Double.parseDouble(x[4]),Double.parseDouble(x[5]),ZoneId.of(x[6]));
   ComprehensiveZmanimCalendar c=new ComprehensiveZmanimCalendar(g);c.setUseElevation(Double.parseDouble(x[5])>0);
   for(LocalDate d=LocalDate.of(2026,1,1);d.getYear()==2026;d=d.plusDays(1)){c.setLocalDate(d);dump(w,n+"|"+d,c,l);}
  }else{List<Method> l=ms(JewishCalendar.class,0);List<Method> t=new ArrayList<>();for(Method m:TefilaRules.class.getMethods())if(m.getParameterCount()==1&&m.getParameterTypes()[0]==JewishCalendar.class&&m.getName().startsWith("is"))t.add(m);t.sort(Comparator.comparing(Method::getName));
   TefilaRules r=new TefilaRules();HebrewDateFormatter he=new HebrewDateFormatter();he.setHebrewFormat(true);HebrewDateFormatter en=new HebrewDateFormatter();
   for(boolean il:new boolean[]{false,true})for(LocalDate d=LocalDate.of(2000,1,1);d.getYear()<=2050;d=d.plusDays(1)){JewishCalendar j=new JewishCalendar(d);j.setInIsrael(il);j.setUseModernHolidays(true);String k=(il?"IL":"DI")+"|"+d;
    dump(w,k,j,l);dump(w,k,r,t,j);int fi=0;for(HebrewDateFormatter f:new HebrewDateFormatter[]{he,en}){String p=fi++==0?"he.":"en.";
     w.println(k+"|"+p+"format|"+f.format(j));w.println(k+"|"+p+"yomtov|"+f.formatYomTov(j));w.println(k+"|"+p+"rc|"+f.formatRoshChodesh(j));w.println(k+"|"+p+"omer|"+f.formatOmer(j));w.println(k+"|"+p+"dow|"+f.formatDayOfWeek(j));w.println(k+"|"+p+"parsha|"+f.formatParshah(j));w.println(k+"|"+p+"special|"+f.formatSpecialParshah(j));w.println(k+"|"+p+"daf|"+f.formatDafYomiBavli(j.getDafYomiBavli()));}
   }}
  w.close();}}
