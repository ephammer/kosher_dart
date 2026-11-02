import sys,re,collections,json
REN={'getChatzos':'getChatzosHayom','getTzais':'getTzaisGeonim8Point5Degrees','getAlosHashachar':'getAlos16Point1Degrees','getSofZmanShmaMGA':'getSofZmanShmaMGA72Minutes','getSofZmanTfilaMGA':'getSofZmanTfilaMGA72Minutes','getMinchaGedola':'getMinchaGedolaGRA','getMinchaKetana':'getMinchaKetanaGRA','getPlagHamincha':'getPlagHaminchaGRA','getShaahZmanisMGA':'getShaahZmanis72Minutes','getShaahZmanisMga':'getShaahZmanis72Minutes','getShaahZmanisGra':'getShaahZmanisGRA','isAssurBemlacha':'isAssurBemelacha','getMinchaGedolaGreaterThan30':'getMinchaGedolaGRAGreaterThan30','getShaahZmanisAlos16Point1ToTzais3Point8':'getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point8Degrees','getShaahZmanisAlos16Point1ToTzais3Point7':'getShaahZmanisAlos16Point1DegreesToTzaisGeonim3Point7Degrees','getSofZmanShmaAlos16Point1ToTzaisGeonim7Point083Degrees':'getSofZmanShmaAlos16Point1DegreesToTzaisGeonim7Point083Degrees','getPlagAlos16Point1ToTzaisGeonim7Point083Degrees':'getPlagAlos16Point1DegreesToTzaisGeonim7Point083Degrees','getMoladAsDateTime':'getMoladAsInstant','getTchilasZmanKidushLevana3Days':'getTchilasZmanKidushLevana3Days','getBainHasmashosRT13Point24Degrees':'getBainHashmashosRT13Point24Degrees','getFixedLocalChatzos':'getFixedLocalChatzosHayom'}
def mp(n):
    n=n.replace('Hasmashos','Hashmashos').replace('Yereim3Point5Degrees','Yereim3Point05Degrees').replace('getSofZmanTfilahAteretTorah','getSofZmanTfilaAteretTorah')
    n=REN.get(n,n); m=re.fullmatch(r'get(Alos|Tzais)(\d+)',n); return f'get{m[1]}{m[2]}Minutes' if m else n
def rows(fn):
    for l in open(fn,encoding='utf8'):
        k1,k2,m,v=l.rstrip('\n').split('|',3); yield (k1,k2),m,v
def groups(fn):
    cur=None;b={}
    for k,m,v in rows(fn):
        if k!=cur:
            if cur: yield cur,b
            cur=k;b={}
        b[m]=v
    if cur: yield cur,b
def go(jf,df,S):
    for (kj,bj),(kd,bd) in zip(groups(jf),groups(df)):
        assert kj==kd,(kj,kd)
        S['jn'].update(bj); md={}
        for m,v in bd.items():
            md[mp(m)]=(m,v)
        S['dn'].update(md)
        for m,vj in bj.items():
            if m not in md: continue
            dm,vd=md[m]; S['cmp'][m]+=1
            if vj==vd: continue
            try:
                diff=abs(int(vj)-int(vd))
                if diff<1000 and len(vj)>6: S['small'][m]+=1; continue
                t='num'
            except: diff=None;t='other'
            e=S['bad'][m]; e['n']+=1; e['ctx'][kj[0]]+=1
            if diff is not None: e['max']=max(e['max'],diff); e['diffs'].append(diff)
            if len(e['ex'])<6: e['ex'].append((kj[0],kj[1],vj,vd))
def new(): return {'jn':set(),'dn':set(),'cmp':collections.Counter(),'small':collections.Counter(),'bad':collections.defaultdict(lambda:{'n':0,'max':0,'ctx':collections.Counter(),'ex':[],'diffs':[]})}
def rep(S,name,minutes):
    print(f'=== {name}: compared {len(S["cmp"])} methods, {sum(S["cmp"].values())} values, sub-second diffs in {sum(S["small"].values())} ==='); 
    for m,e in sorted(S['bad'].items(),key=lambda x:-x[1]['n']):
        d=sorted(e['diffs']); med=d[len(d)//2] if d else 0
        print(f"{m}: n={e['n']}/{S['cmp'][m]} med={med/ (60000 if minutes else 1):.2f} max={e['max']/(60000 if minutes else 1):.2f} {dict(e['ctx'])} ex={e['ex'][:3]}")
    print('JAVA ONLY:',sorted(S['jn']-S['dn'])); print('DART ONLY:',sorted(S['dn']-S['jn']))
c=new(); go('out/j_cal.txt','out/d_cal.txt',c); rep(c,'CALENDAR',False)
z=new()
for n in [l.split()[0] for l in open('places.txt')]: go(f'out/j_{n}.txt',f'out/d_{n}.txt',z)
rep(z,'ZMANIM',True)
