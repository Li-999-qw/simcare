"""Versioned editable role personas, separate from fixed case/state rules."""
import ast,json,sys,threading
from pathlib import Path
ROOT=Path(__file__).parent
PATH=ROOT/'role-personas.json'
LOCK=threading.Lock()
def defaults():
 source=Path.home()/'C:/Users/LCJNZX8/Desktop/SimCare-Windows-Deployment (1)/backend/engines/chest/agent.py'
 result={}
 for n in ast.parse(source.read_text(encoding='utf-8-sig')).body:
  if isinstance(n,ast.Assign):
   for t in n.targets:
    if isinstance(t,ast.Name) and t.id in ('PATIENT_RULES','SENIOR_RULES','RULES'):result[t.id]=ast.literal_eval(n.value)
 return {'patient':result['PATIENT_RULES'],'senior':result['SENIOR_RULES'],'fixed_rules':result['RULES']}
def read():
 d=defaults();stored=json.loads(PATH.read_text(encoding='utf-8')) if PATH.exists() else {'revision':0}
 return {**d,**stored}
def apply(rules,role,override=None):
 if override is None:
  if not PATH.exists():return rules
  stored=json.loads(PATH.read_text(encoding="utf-8"))
  if role not in stored:return rules
 value=override if override is not None else read()[role]
 module=sys.modules.get('agent');original=getattr(module,'PATIENT_RULES' if role=='patient' else 'SENIOR_RULES',None)
 return rules.replace(original,value,1) if original and original in rules else rules+'\n角色人设补充：\n'+value
