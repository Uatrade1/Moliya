<!DOCTYPE html>
<html lang="uz">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Moliya Dashboard</title>
<meta name="theme-color" content="#0f172a"/>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react/18.2.0/umd/react.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/react-dom/18.2.0/umd/react-dom.production.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/recharts/2.8.0/Recharts.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/7.23.2/babel.min.js"></script>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{background:#0f172a;color:#f1f5f9;font-family:'Inter','Segoe UI',sans-serif;min-height:100vh}
input,select,button{font-family:inherit}
.toast{position:fixed;top:16px;right:16px;z-index:999;padding:12px 16px;border-radius:12px;font-size:13px;font-weight:600;max-width:280px;display:flex;align-items:flex-start;gap:8px;box-shadow:0 8px 32px rgba(0,0,0,0.4)}
.toast-ok{background:#052e16;border:1px solid #166534;color:#4ade80}
.toast-warn{background:#431407;border:1px solid #9a3412;color:#fb923c}
.card{background:#0f172a;border:1px solid #1e293b;border-radius:16px;padding:20px}
.inp{background:#1e293b;border:1px solid #334155;border-radius:10px;padding:10px 14px;color:#f1f5f9;font-size:14px;width:100%;outline:none}
.inp:focus{border-color:#7c3aed}
.tag-i{background:#052e16;color:#4ade80;border:1px solid #166534;border-radius:6px;padding:2px 8px;font-size:11px;font-weight:700}
.tag-e{background:#450a0a;color:#f87171;border:1px solid #991b1b;border-radius:6px;padding:2px 8px;font-size:11px;font-weight:700}
.nav-btn{background:none;border:none;cursor:pointer;padding:8px 14px;border-radius:10px;color:#64748b;font-size:12px;font-weight:600;white-space:nowrap;transition:all .2s}
.nav-btn.active{background:#7c3aed;color:#fff}
.filter-btn{background:#1e293b;border:none;cursor:pointer;padding:6px 12px;border-radius:8px;color:#64748b;font-size:12px;font-weight:600;transition:all .2s}
.filter-btn.active{background:#7c3aed;color:#fff}
.progress-bar{height:10px;background:#1e293b;border-radius:99px;overflow:hidden}
.progress-fill{height:100%;border-radius:99px;transition:width .6s ease}
.tx-row{display:flex;align-items:center;gap:12px;padding:14px 16px;border-bottom:1px solid #1e293b;transition:background .15s}
.tx-row:last-child{border-bottom:none}
.icon-box{width:40px;height:40px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0}
</style>
</head>
<body>
<div id="root"></div>
<script type="text/babel">
const {useState,useEffect,useMemo,useCallback}=React;
const {BarChart,Bar,PieChart,Pie,Cell,XAxis,YAxis,CartesianGrid,Tooltip,ResponsiveContainer}=Recharts;
const MONTHS=["Yan","Fev","Mar","Apr","May","Iyun","Iyul","Avg","Sen","Okt","Noy","Dek"];
const fmt=n=>new Intl.NumberFormat("uz-UZ",{maximumFractionDigits:0}).format(n)+" so'm";
const fmtS=n=>n>=1000000?(n/1000000).toFixed(1)+"M":n>=1000?(n/1000).toFixed(0)+"K":n;
const INC=[{id:"oylik",label:"Oylik ish haqi",e:"💼",c:"#34d399"},{id:"staj",label:"Stajirovka",e:"📚",c:"#60a5fa"},{id:"tanish",label:"Tanishlardan qaytgan",e:"👥",c:"#a78bfa"},{id:"sirtqi",label:"Sirtqi ishlar",e:"💻",c:"#fbbf24"},{id:"boshqa",label:"Boshqa tushum",e:"➕",c:"#94a3b8"}];
const EXP=[{id:"ijara",label:"Kvartira/Ijara",e:"🏠",c:"#f87171"},{id:"oziq",label:"Oziq-ovqat",e:"🛒",c:"#fb923c"},{id:"yolkira",label:"Yo'lkira/Metro",e:"🚇",c:"#facc15"},{id:"kontrakt",label:"Kontrakt jamg'armasi",e:"🎓",c:"#a78bfa"},{id:"kongiloch",label:"Ko'ngilochar",e:"🎵",c:"#f472b6"},{id:"kutilmagan",label:"Kutilmagan xarajat",e:"⚡",c:"#94a3b8"}];
const ALL=[...INC,...EXP];
const getCat=id=>ALL.find(c=>c.id===id)||{label:id,e:"•",c:"#64748b"};
const SEED=[{id:"s1",desc:"May oyligi",amount:2500000,type:"tushum",category:"oylik",date:"2025-05-01"},{id:"s2",desc:"Kvartira ijarasi",amount:800000,type:"xarajat",category:"ijara",date:"2025-05-02"},{id:"s3",desc:"Oziq-ovqat",amount:350000,type:"xarajat",category:"oziq",date:"2025-05-05"},{id:"s4",desc:"Stajirovka",amount:600000,type:"tushum",category:"staj",date:"2025-05-10"},{id:"s5",desc:"Metro kartasi",amount:80000,type:"xarajat",category:"yolkira",date:"2025-05-11"},{id:"s6",desc:"Kontrakt jamg'arma",amount:500000,type:"xarajat",category:"kontrakt",date:"2025-05-15"},{id:"s7",desc:"Sirtqi loyiha",amount:400000,type:"tushum",category:"sirtqi",date:"2025-05-18"},{id:"s8",desc:"Kino",amount:120000,type:"xarajat",category:"kongiloch",date:"2025-05-20"},{id:"s9",desc:"Iyun oyligi",amount:2500000,type:"tushum",category:"oylik",date:"2025-06-01"},{id:"s10",desc:"Kvartira ijarasi",amount:800000,type:"xarajat",category:"ijara",date:"2025-06-02"},{id:"s11",desc:"Oziq-ovqat",amount:290000,type:"xarajat",category:"oziq",date:"2025-06-06"},{id:"s12",desc:"Tanishdan qaytgan",amount:200000,type:"tushum",category:"tanish",date:"2025-06-08"}];
function health(inc,exp){if(!inc)return{text:"Ma'lumot yo'q",color:"#64748b"};const r=exp/inc;if(r<0.5)return{text:"A'lo 🌟",color:"#34d399"};if(r<0.7)return{text:"Yaxshi ✅",color:"#60a5fa"};if(r<0.85)return{text:"O'rta ⚠️",color:"#fbbf24"};return{text:"Ehtiyot bo'ling 🔴",color:"#f87171"};}
function Toast({msg,type,onClose}){useEffect(()=>{const t=setTimeout(onClose,5000);return()=>clearTimeout(t)},[]);return <div className={"toast toast-"+type}><span>{msg}</span><button onClick={onClose} style={{background:"none",border:"none",cursor:"pointer",color:"inherit",marginLeft:"auto"}}>✕</button></div>;}function App(){
const[txns,setTxns]=useState(()=>{try{const s=localStorage.getItem("m_txns");return s?JSON.parse(s):SEED}catch{return SEED}});
const[goal,setGoal]=useState(()=>Number(localStorage.getItem("m_goal"))||10000000);
const[collected,setCollected]=useState(()=>Number(localStorage.getItem("m_coll"))||1500000);
const[budget,setBudget]=useState(()=>Number(localStorage.getItem("m_budget"))||2000000);
const[tab,setTab]=useState("dashboard");
const[toast,setToast]=useState(null);
const[showForm,setShowForm]=useState(false);
const[form,setForm]=useState({desc:"",amount:"",type:"tushum",category:"oylik",date:new Date().toISOString().slice(0,10)});
const[filter,setFilter]=useState("barchasi");
const[search,setSearch]=useState("");
const[gInput,setGInput]=useState("");
const[cInput,setCInput]=useState("");
const[bInput,setBInput]=useState("");
useEffect(()=>{localStorage.setItem("m_txns",JSON.stringify(txns))},[txns]);
useEffect(()=>{localStorage.setItem("m_goal",goal)},[goal]);
useEffect(()=>{localStorage.setItem("m_coll",collected)},[collected]);
useEffect(()=>{localStorage.setItem("m_budget",budget)},[budget]);
const totalInc=useMemo(()=>txns.filter(t=>t.type==="tushum").reduce((s,t)=>s+t.amount,0),[txns]);
const totalExp=useMemo(()=>txns.filter(t=>t.type==="xarajat").reduce((s,t)=>s+t.amount,0),[txns]);
const balance=totalInc-totalExp;
const h=health(totalInc,totalExp);
const savePct=totalInc>0?((totalInc-totalExp)/totalInc*100):0;
useEffect(()=>{if(budget>0&&totalExp>=budget*0.85)setToast({msg:`⚠️ Oylik limitingizning ${Math.round(totalExp/budget*100)}%ini sarfladingiz!`,type:"warn"})},[totalExp,budget]);
const monthlyData=useMemo(()=>{const m={};txns.forEach(t=>{const d=new Date(t.date);const k=d.getFullYear()+"-"+d.getMonth();if(!m[k])m[k]={name:MONTHS[d.getMonth()],Tushum:0,Xarajat:0};t.type==="tushum"?m[k].Tushum+=t.amount:m[k].Xarajat+=t.amount;});return Object.values(m).slice(-6)},[txns]);
const pieData=useMemo(()=>{const m={};txns.filter(t=>t.type==="xarajat").forEach(t=>{const c=getCat(t.category);if(!m[t.category])m[t.category]={name:c.label,value:0,color:c.c};m[t.category].value+=t.amount;});return Object.values(m).sort((a,b)=>b.value-a.value)},[txns]);
const filteredTxns=useMemo(()=>txns.filter(t=>filter==="barchasi"||t.type===filter).filter(t=>t.desc.toLowerCase().includes(search.toLowerCase())).sort((a,b)=>new Date(b.date)-new Date(a.date)),[txns,filter,search]);
const addTx=useCallback(()=>{if(!form.desc.trim()||!form.amount){setToast({msg:"Barcha maydonlarni to'ldiring!",type:"warn"});return;}setTxns(p=>[{...form,id:Date.now().toString(),amount:Number(form.amount)},...p]);setForm(f=>({...f,desc:"",amount:""}));setShowForm(false);setToast({msg:"✅ Qo'shildi!",type:"ok"})},[form]);
const delTx=useCallback(id=>setTxns(p=>p.filter(t=>t.id!==id)),[]);
const cats=form.type==="tushum"?INC:EXP;
const goalPct=Math.min(100,collected/goal*100);
const budgetPct=budget>0?Math.min(100,totalExp/budget*100):0;
const Tip=({active,payload,label})=>{if(!active||!payload?.length)return null;return <div style={{background:"#1e293b",border:"1px solid #334155",borderRadius:10,padding:"8px 12px",fontSize:12}}><p style={{color:"#94a3b8",marginBottom:4}}>{label}</p>{payload.map((p,i)=><p key={i} style={{color:p.color,fontWeight:700}}>{p.name}: {fmtS(p.value)} so'm</p>)}</div>};
return(<div style={{minHeight:"100vh",background:"#0f172a"}}>
{toast&&<Toast msg={toast.msg} type={toast.type} onClose={()=>setToast(null)}/>}
<div style={{background:"#0f172a",borderBottom:"1px solid #1e293b",padding:"12px 16px",display:"flex",alignItems:"center",justifyContent:"space-between",position:"sticky",top:0,zIndex:20}}>
<div><h1 style={{fontSize:18,fontWeight:800,color:"#f1f5f9"}}>💰 Moliya</h1><p style={{fontSize:11,color:"#475569"}}>Shaxsiy byudjet tahlilchisi</p></div>
<button style={{background:"#7c3aed",color:"#fff",border:"none",cursor:"pointer",padding:"8px 16px",borderRadius:12,fontSize:13,fontWeight:700}} onClick={()=>setShowForm(v=>!v)}>+ Qo'shish</button>
</div>
{showForm&&(<div style={{background:"#0f172a",borderBottom:"1px solid #1e293b",padding:"16px"}}>
<div style={{maxWidth:480,margin:"0 auto",display:"flex",flexDirection:"column",gap:10}}>
<div style={{display:"flex",borderRadius:10,overflow:"hidden",border:"1px solid #334155",width:"fit-content"}}>
<button onClick={()=>setForm(f=>({...f,type:"tushum",category:"oylik"}))} style={{padding:"8px 20px",fontSize:13,fontWeight:700,border:"none",cursor:"pointer",background:form.type==="tushum"?"#059669":"#1e293b",color:form.type==="tushum"?"#fff":"#64748b"}}>↑ Tushum</button>
<button onClick={()=>setForm(f=>({...f,type:"xarajat",category:"ijara"}))} style={{padding:"8px 20px",fontSize:13,fontWeight:700,border:"none",cursor:"pointer",background:form.type==="xarajat"?"#dc2626":"#1e293b",color:form.type==="xarajat"?"#fff":"#64748b"}}>↓ Xarajat</button>
</div>
<input className="inp" placeholder="Tavsif (masalan: Oylik maosh)" value={form.desc} onChange={e=>setForm(f=>({...f,desc:e.target.value}))}/>
<input className="inp" type="number" placeholder="Miqdor (so'm)" value={form.amount} onChange={e=>setForm(f=>({...f,amount:e.target.value}))}/>
<select className="inp" value={form.category} onChange={e=>setForm(f=>({...f,category:e.target.value}))}>{cats.map(c=><option key={c.id} value={c.id}>{c.e} {c.label}</option>)}</select>
<input className="inp" type="date" value={form.date} onChange={e=>setForm(f=>({...f,date:e.target.value}))}/>
<button onClick={addTx} style={{padding:"12px",fontSize:14,background:form.type==="tushum"?"#059669":"#dc2626",color:"#fff",border:"none",cursor:"pointer",borderRadius:12,fontWeight:700}}>{form.type==="tushum"?"✅ Tushum qo'shish":"❌ Xarajat qo'shish"}</button>
</div></div>)}
<div style={{background:"#0f172a",borderBottom:"1px solid #1e293b",padding:"8px 12px",display:"flex",gap:4,overflowX:"auto"}}>
{[{id:"dashboard",l:"📊 Bosh"},{id:"transactions",l:"📋 Tarix"},{id:"goals",l:"🎯 Maqsad"},{id:"budget",l:"🔔 Byudjet"}].map(item=>(
<button key={item.id} className={"nav-btn"+(tab===item.id?" active":"")} onClick={()=>setTab(item.id)}>{item.l}</button>
))}
</div>
<div style={{padding:"16px",maxWidth:640,margin:"0 auto"}}>
{tab==="dashboard"&&(<div style={{display:"flex",flexDirection:"column",gap:14}}>
<div style={{display:"grid",gridTemplateColumns:"1fr 1fr",gap:10}}>
{[{e:"💳",l:"Jami balans",v:fmtS(balance)+" so'm",c:balance>=0?"#a78bfa":"#f87171"},{e:"📈",l:"Jami tushum",v:fmtS(totalInc)+" so'm",c:"#34d399"},{e:"📉",l:"Jami xarajat",v:fmtS(totalExp)+" so'm",c:"#f87171"}].map(s=>(
<div key={s.l} className="card"><div style={{display:"flex",justifyContent:"space-between",marginBottom:8}}><span style={{fontSize:11,fontWeight:700,color:"#475569",textTransform:"uppercase",letterSpacing:1}}>{s.l}</span><span style={{fontSize:20}}>{s.e}</span></div><p style={{fontSize:22,fontWeight:800,color:s.c}}>{s.v}</p></div>
))}
<div className="card"><span style={{fontSize:11,fontWeight:700,color:"#475569",textTransform:"uppercase",letterSpacing:1}}>Salomatlik</span><p style={{fontSize:18,fontWeight:800,color:h.color,marginTop:8}}>{h.text}</p><p style={{fontSize:11,color:"#475569",marginTop:4}}>Jamg'arma: {savePct.toFixed(1)}%</p></div>
</div>
<div className="card"><p style={{fontWeight:700,fontSize:14,marginBottom:14,color:"#f1f5f9"}}>📊 Oylik Tushum vs Xarajat</p>
{monthlyData.length===0?<p style={{color:"#475569",textAlign:"center",padding:32}}>Ma'lumot yo'q</p>:(
<ResponsiveContainer width="100%" height={180}><BarChart data={monthlyData} barGap={3}><CartesianGrid strokeDasharray="3 3" stroke="#1e293b" vertical={false}/><XAxis dataKey="name" tick={{fill:"#64748b",fontSize:11}} axisLine={false} tickLine={false}/><YAxis tick={{fill:"#64748b",fontSize:10}} axisLine={false} tickLine={false} tickFormatter={fmtS}/><Tooltip content={<Tip/>}/><Bar dataKey="Tushum" fill="#34d399" radius={[6,6,0,0]} maxBarSize={24}/><Bar dataKey="Xarajat" fill="#f87171" radius={[6,6,0,0]} maxBarSize={24}/></BarChart></ResponsiveContainer>
)}</div>
{pieData.length>0&&(<div className="card"><p style={{fontWeight:700,fontSize:14,marginBottom:14,color:"#f1f5f9"}}>🥧 Xarajat tarkibi</p>
<div style={{display:"flex",gap:16,alignItems:"center",flexWrap:"wrap"}}>
<ResponsiveContainer width={140} height={140}><PieChart><Pie data={pieData} cx="50%" cy="50%" innerRadius={38} outerRadius={60} paddingAngle={3} dataKey="value">{pieData.map((e,i)=><Cell key={i} fill={e.color} stroke="transparent"/>)}</Pie><Tooltip formatter={v=>[fmt(v)]}/></PieChart></ResponsiveContainer>
<div style={{flex:1,display:"flex",flexDirection:"column",gap:8}}>{pieData.slice(0,5).map((d,i)=><div key={i} style={{display:"flex",alignItems:"center",gap:8}}><div style={{width:8,height:8,borderRadius:"50%",background:d.color}}/><span style={{fontSize:12,color:"#94a3b8",flex:1}}>{d.name}</span><span style={{fontSize:12,fontWeight:700,color:d.color}}>{fmtS(d.value)}</span></div>)}</div>
</div></div>)}
<div className="card" style={{padding:0,overflow:"hidden"}}><div style={{padding:"16px",borderBottom:"1px solid #1e293b",display:"flex",justifyContent:"space-between"}}><p style={{fontWeight:700,fontSize:14,color:"#f1f5f9"}}>🕐 So'nggi tranzaksiyalar</p><button onClick={()=>setTab("transactions")} style={{background:"none",border:"none",cursor:"pointer",color:"#7c3aed",fontSize:12,fontWeight:700}}>Barchasi →</button></div>
{txns.slice(0,5).map(t=>{const c=getCat(t.category);return(<div key={t.id} className="tx-row"><div className="icon-box" style={{background:c.c+"22"}}>{c.e}</div><div style={{flex:1,minWidth:0}}><p style={{fontSize:13,fontWeight:600,color:"#f1f5f9",overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>{t.desc}</p><p style={{fontSize:11,color:"#475569"}}>{t.date} · {c.label}</p></div><span style={{fontSize:13,fontWeight:700,color:t.type==="tushum"?"#34d399":"#f87171",flexShrink:0}}>{t.type==="tushum"?"+":"-"}{fmtS(t.amount)}</span></div>);})}
</div></div>)}
{tab==="transactions"&&(<div style={{display:"flex",flexDirection:"column",gap:12}}>
<div className="card" style={{display:"flex",flexDirection:"column",gap:10}}>
<div style={{position:"relative"}}><span style={{position:"absolute",left:12,top:11}}>🔍</span><input className="inp" style={{paddingLeft:34}} placeholder="Qidirish..." value={search} onChange={e=>setSearch(e.target.value)}/></div>
<div style={{display:"flex",gap:6,flexWrap:"wrap"}}>{["barchasi","tushum","xarajat"].map(f=><button key={f} className={"filter-btn"+(filter===f?" active":"")} onClick={()=>setFilter(f)}>{f==="barchasi"?"Barchasi":f==="tushum"?"↑ Tushumlar":"↓ Xarajatlar"}</button>)}</div>
</div>
<div className="card" style={{padding:0,overflow:"hidden"}}>
{filteredTxns.length===0?<p style={{textAlign:"center",padding:40,color:"#475569"}}>Topilmadi</p>:filteredTxns.map(t=>{const c=getCat(t.category);return(<div key={t.id} className="tx-row"><div className="icon-box" style={{background:c.c+"22"}}>{c.e}</div><div style={{flex:1,minWidth:0}}><p style={{fontSize:13,fontWeight:600,color:"#f1f5f9",overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap"}}>{t.desc}</p><div style={{display:"flex",gap:6,marginTop:2}}><span style={{fontSize:10,color:c.c,fontWeight:700}}>{c.label}</span><span style={{color:"#334155",fontSize:10}}>·</span><span style={{fontSize:10,color:"#475569"}}>{t.date}</span></div></div><div style={{display:"flex",alignItems:"center",gap:8,flexShrink:0}}><div style={{textAlign:"right"}}><p style={{fontSize:13,fontWeight:700,color:t.type==="tushum"?"#34d399":"#f87171"}}>{t.type==="tushum"?"+":"-"}{fmt(t.amount)}</p><span className={t.type==="tushum"?"tag-i":"tag-e"}>{t.type==="tushum"?"Tushum":"Xarajat"}</span></div><button onClick={()=>delTx(t.id)} style={{background:"none",border:"none",cursor:"pointer",fontSize:16,padding:4}}>🗑</button></div></div>);})}
</div></div>)}
{tab==="goals"&&(<div style={{display:"flex",flexDirection:"column",gap:14}}>
<div className="card" style={{display:"flex",flexDirection:"column",gap:16}}>
<div style={{display:"flex",alignItems:"center",gap:12}}><div style={{width:44,height:44,borderRadius:14,background:"#4c1d95",display:"flex",alignItems:"center",justifyContent:"center",fontSize:22}}>🎓</div><div><p style={{fontWeight:800,fontSize:14,color:"#f1f5f9"}}>Oliy Maqsad: Universitet Kontrakti</p><p style={{fontSize:11,color:"#475569"}}>Maqsadli jamg'arma treker</p></div></div>
<div><div style={{display:"flex",justifyContent:"space-between",fontSize:12,marginBottom:8}}><span style={{color:"#94a3b8"}}>Jamlangan: <strong style={{color:"#34d399"}}>{fmt(collected)}</strong></span><span style={{color:"#94a3b8"}}>Maqsad: <strong style={{color:"#f1f5f9"}}>{fmt(goal)}</strong></span></div>
<div className="progress-bar"><div className="progress-fill" style={{width:goalPct+"%",background:"linear-gradient(90deg,#7c3aed,#3b82f6)"}}/></div>
<div style={{display:"flex",justifyContent:"space-between",fontSize:11,marginTop:6}}><span style={{fontWeight:700,color:"#7c3aed"}}>{goalPct.toFixed(1)}% {goalPct>=100?"— 🎉 Maqsadga yetildi!":"davom etmoqda..."}</span><span style={{color:"#475569"}}>Qoldi: {fmt(Math.max(0,goal-collected))}</span></div></div>
<div style={{borderTop:"1px solid #1e293b",paddingTop:14,display:"flex",flexDirection:"column",gap:10}}>
<input className="inp" type="number" placeholder={"Maqsad miqdori (hozir: "+fmtS(goal)+")"} value={gInput} onChange={e=>setGInput(e.target.value)}/>
<input className="inp" type="number" placeholder={"Jamlangan (hozir: "+fmtS(collected)+")"} value={cInput} onChange={e=>setCInput(e.target.value)}/>
<button onClick={()=>{if(gInput)setGoal(Number(gInput));if(cInput)setCollected(Number(cInput));setGInput("");setCInput("");setToast({msg:"Maqsad yangilandi ✅",type:"ok"});}} style={{padding:"11px",fontSize:14,background:"#7c3aed",color:"#fff",border:"none",cursor:"pointer",borderRadius:12,fontWeight:700}}>Maqsadni yangilash</button>
</div></div>
<div className="card"><p style={{fontWeight:700,fontSize:14,marginBottom:14,color:"#f1f5f9"}}>🐷 Jamg'arma tahlili</p>
{[{l:"Oylik tushum",v:totalInc,c:"#34d399"},{l:"Oylik xarajat",v:totalExp,c:"#f87171"},{l:"Sof jamg'arma",v:Math.max(0,totalInc-totalExp),c:"#a78bfa"}].map(r=><div key={r.l} style={{display:"flex",justifyContent:"space-between",padding:"10px 0",borderBottom:"1px solid #1e293b"}}><span style={{fontSize:13,color:"#94a3b8"}}>{r.l}</span><span style={{fontSize:13,fontWeight:700,color:r.c}}>{fmt(r.v)}</span></div>)}
{totalInc>totalExp&&<div style={{marginTop:14,background:"#1e1b4b",border:"1px solid #3730a3",borderRadius:10,padding:"10px 12px",fontSize:12,color:"#a5b4fc"}}>💡 Hozirgi sur'atda maqsadingizga <strong>{Math.ceil((goal-collected)/Math.max(1,totalInc-totalExp))} oy</strong> kerak bo'ladi.</div>}
</div></div>)}
{tab==="budget"&&(<div style={{display:"flex",flexDirection:"column",gap:14}}>
<div className="card" style={{display:"flex",flexDirection:"column",gap:14}}>
<div style={{display:"flex",alignItems:"center",gap:12}}><div style={{width:44,height:44,borderRadius:14,background:budgetPct>=85?"#450a0a":"#431407",display:"flex",alignItems:"center",justifyContent:"center",fontSize:22}}>🔔</div><div><p style={{fontWeight:800,fontSize:14,color:"#f1f5f9"}}>Oylik Xarajat Limiti</p><p style={{fontSize:11,color:"#475569"}}>85% dan oshsa ogohlantirish keladi</p></div></div>
<div><div style={{display:"flex",justifyContent:"space-between",fontSize:12,marginBottom:8}}><span style={{color:"#94a3b8"}}>Sarflangan: <strong style={{color:"#f87171"}}>{fmt(totalExp)}</strong></span><span style={{color:"#94a3b8"}}>Limit: <strong style={{color:"#f1f5f9"}}>{fmt(budget)}</strong></span></div>
<div className="progress-bar"><div className="progress-fill" style={{width:Math.min(100,budgetPct)+"%",background:budgetPct>=85?"linear-gradient(90deg,#dc2626,#ef4444)":budgetPct>=60?"linear-gradient(90deg,#d97706,#f59e0b)":"linear-gradient(90deg,#059669,#34d399)"}}/></div>
<div style={{display:"flex",justifyContent:"space-between",fontSize:11,marginTop:6}}><span style={{fontWeight:700,color:budgetPct>=85?"#f87171":budgetPct>=60?"#fbbf24":"#34d399"}}>{budgetPct.toFixed(1)}% ishlatildi</span><span style={{color:"#475569"}}>{totalExp<budget?"Qoldi: "+fmt(budget-totalExp):"⚠️ Limitdan oshdi!"}</span></div></div>
{budgetPct>=85&&<div style={{background:"#450a0a",border:"1px solid #991b1b",borderRadius:10,padding:"12px",display:"flex",gap:10}}><span style={{fontSize:20}}>⚠️</span><div><p style={{fontWeight:700,fontSize:13,color:"#fca5a5"}}>Byudjet ogohlantirishи!</p><p style={{fontSize:12,color:"#f87171",marginTop:2}}>Xarajatlaringiz limitning {budgetPct.toFixed(0)}%ini tashkil etdi!</p></div></div>}
<div style={{borderTop:"1px solid #1e293b",paddingTop:12,display:"flex",gap:8}}>
<input className="inp" type="number" placeholder={"Yangi limit (hozir: "+fmtS(budget)+")"} value={bInput} onChange={e=>setBInput(e.target.value)}/>
<button onClick={()=>{if(bInput){setBudget(Number(bInput));setBInput("");setToast({msg:"Byudjet yangilandi ✅",type:"ok"});}}} style={{background:"#d97706",color:"#fff",border:"none",cursor:"pointer",padding:"10px 16px",borderRadius:10,fontWeight:700,flexShrink:0}}>Saqlash</button>
</div></div>
<div className="card"><p style={{fontWeight:700,fontSize:14,marginBottom:14,color:"#f1f5f9"}}>📊 Kategoriya bo'yicha xarajat</p>
{pieData.length===0?<p style={{color:"#475569",textAlign:"center",padding:24}}>Xarajat yo'q</p>:pieData.map((d,i)=><div key={i} style={{marginBottom:12}}><div style={{display:"flex",justifyContent:"space-between",fontSize:12,marginBottom:5}}><span style={{color:"#e2e8f0",fontWeight:600}}>{d.name}</span><span style={{fontWeight:700,color:d.color}}>{fmt(d.value)} ({totalExp>0?(d.value/totalExp*100).toFixed(1):0}%)</span></div><div className="progress-bar" style={{height:6}}><div className="progress-fill" style={{width:(totalExp>0?d.value/totalExp*100:0)+"%",background:d.color}}/></div></div>)}
</div></div>)}
</div></div>);}
ReactDOM.createRoot(document.getElementById("root")).render(<App/>);
</script>
</body>
</html>
