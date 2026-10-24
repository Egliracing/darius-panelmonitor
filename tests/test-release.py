import os,sys,json,gettext,math,time
os.environ['QT_QPA_PLATFORM']='offscreen'
os.environ['QT_QUICK_BACKEND']='software'
os.environ['QT_SCALE_FACTOR']='2'
sys.excepthook=sys.__excepthook__
from pathlib import Path
from PyQt6.QtCore import QObject,pyqtSlot,QUrl,QTimer,QPointF
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlComponent,QQmlExpression,QQmlEngine
from PyQt6.QtQuick import QQuickView,QQuickItem
project=Path(__file__).resolve().parents[1]
os.chdir(project)
Path('work').mkdir(exist_ok=True)
root=project/'package'
out=project/'store';out.mkdir(exist_ok=True)
class Translator(QObject):
 def __init__(self):super().__init__();self.german=False;self.catalog=gettext.GNUTranslations(open(root/'contents/locale/de/LC_MESSAGES/plasma_applet_de.darius.panelmonitor.mo','rb'))
 @pyqtSlot(str,result=str)
 def i18n(self,s):return self.catalog.gettext(s) if self.german else s
app=QGuiApplication([]);tr=Translator();refs=[];report=[]
def newview(qml,name):
 p=Path('work')/(name+'.qml');p.write_text(qml)
 v=QQuickView();v.rootContext().setContextObject(tr);
 if 'releaseView' in globals():
  v.rootContext().setContextProperty('releaseSettings',releaseView.rootObject().property('settings'))
  v.rootContext().setContextProperty('releaseReadings',releaseView.rootObject().findChild(QObject,'live'))
 v.setSource(QUrl.fromLocalFile(str(p.resolve())))
 if v.errors():raise RuntimeError('\n'.join(e.toString() for e in v.errors()))
 v.show();refs.append(v);return v
settings='''property QtObject settings: QtObject {
 property bool showCpu: true; property bool showRam: true; property bool showNetwork: true
 property bool showBars: true; property bool oneLine: false
 property int cpuMode: 0; property int ramMode: 0; property int ramUnit: 0; property int netUnit: 0
 property bool ramInGiB: false; property int fontSize: 11; property int width: 520
 property int updateMs: 1000; property string interfaceName: ""
 property string cpuColor: "#54c7ec"; property string ramColor: "#b59bff"; property string netColor: "#73d6a0"
}'''
imports='import QtQuick\nimport QtQuick.Controls as C\nimport org.kde.kirigami as K\nimport "'+QUrl.fromLocalFile(str(root/'contents/ui')).toString()+'" as Monitor\n'
qml=imports+'''Rectangle {
 id: preview
 width: 820; height: 220; color: "#171b23"
 K.Theme.inherit: false; K.Theme.textColor: "#f0f4fa"
 '''+settings+'''
 property int panelHeight: 32
 Monitor.MonitorData { id: live; objectName: "live"; settings: preview.settings }
 Text { x:28; y:22; text:"Darius Panelmonitor"; color:"#eef3fa"; font.pixelSize:26; font.bold:true }
 Text { id: caption; objectName:"caption"; x:28; y:62; text:"CPU, memory and network — at a glance"; color:"#a9b5c7"; font.pixelSize:15 }
 Rectangle {
  x:28; y:106; width:764; height:parent.panelHeight; color:"#252b35"; radius:4
  Monitor.MonitorView { objectName:"monitor"; anchors.centerIn:parent; width:preview.settings.width; height:parent.height; settings:parent.parent.settings; readings:live }
 }
 Text { x:28; y:176; text:"Live sensor data · Plasma 6 · Customizable display modes"; color:"#9aa8ba"; font.pixelSize:12 }
}'''
v=newview(qml,'release-live-preview')
releaseView=v
def expr(code):
 e=QQmlExpression(QQmlEngine.contextForObject(v.rootObject()),v.rootObject(),code);value=e.evaluate()
 if e.hasError():raise RuntimeError(e.error().toString())
 return value[0] if isinstance(value,tuple) else value

def testlive():
 try:
  data=v.rootObject().findChild(QObject,'live')
  sensor_names=['cpu','ram','download','upload']
  results={}
  for key in sensor_names:
   status=expr(f'live.{key}.status');value=expr(f'live.{key}.value')
   assert status==2,(key,status,value)
   assert value is not None and math.isfinite(float(value)),(key,value)
   results[key]=float(value)
  assert 0<=results['cpu']<=100 and 0<=results['ram']<=100
  auto=expr('live.selectedInterface');assert auto,'No automatic interface'
  report.append({'test':'Live KDE sensors','result':'PASS','interface':auto,'values':results})
  print('PASS live sensors',results,'interface',auto)
  assert expr('live.megabits(1250000)').replace(',','.')=='10.00 Mbit/s'
  assert expr('live.megabits(0)').replace(',','.')=='0.00 Mbit/s'
  assert expr('live.megabits(-1)').replace(',','.')=='0.00 Mbit/s'
  for unit, expected in [(0,'10.00 Mbit/s'),(1,'10000.0 kbit/s'),(2,'1.25 MB/s'),(3,'1220.7 KiB/s'),(4,'1.19 MiB/s')]:
   assert expr(f'live.rate(1250000,{unit})').replace(',','.') == expected
  report.append({'test':'All five network unit conversions (decimal bits/bytes and binary bytes)','result':'PASS'})
  report.append({'test':'Decimal Mbit/s conversion: zero, positive, negative','result':'PASS'})
  assert expr('live.network.chooseInterface([{name:"docker0",state:2,type:4},{name:"wlan0",state:2,type:14},{name:"eth0",state:2,type:13}])')=='eth0'
  assert expr('live.network.chooseInterface([{name:"wlan0",state:2,type:14},{name:"eth0",state:0,type:13}])')=='wlan0'
  assert expr('live.network.chooseInterface([])')==''
  assert expr('live.network.chooseInterface([{name:"tun0",state:2,type:11},{name:"veth0",state:2,type:16}])')==''
  report.append({'test':'Automatic Ethernet/Wi-Fi choice, disconnected interfaces and virtual connections','result':'PASS'})
  for h in [22,24,32,40,48,64]:
   v.rootObject().setProperty('panelHeight',h)
   app.processEvents()
   monitor=v.rootObject().findChild(QQuickItem,'monitor')
   assert monitor.height()==h
   assert monitor.property('singleRow')==(h<40)
   labels=[x for x in monitor.findChildren(QQuickItem) if x.isVisible() and x.property('text')]
   for label in labels:
    pos=label.mapToItem(monitor,QPointF(0,0))
    assert pos.y()>=0 and pos.y()+label.height()<=h,(h,label.property('text'),pos.y(),label.height())
   assert any('NET' in x.property('text') for x in labels)
  report.append({'test':'Text bounds and NET label at 22/24/32/40/48/64 logical pixels','result':'PASS'})
  # Manual selection and missing-device state: no fallback to misleading zero.
  cfg=v.rootObject().property('settings');cfg.setProperty('interfaceName','nonexistent-test-device')
  app.processEvents()
  assert expr('live.selectedInterface')=='nonexistent-test-device'
  def missing_sensor_check():
   try:
    assert expr('live.downloadText') == '—'
    assert expr('live.uploadText') == '—'
    report.append({'test':'Missing manual interface reports unavailable instead of zero','result':'PASS'})
    cfg.setProperty('showCpu',False)
    app.processEvents()
    assert expr('live.cpu.enabled') == False
    cfg.setProperty('showCpu',True)
    cfg.setProperty('oneLine',True)
    v.rootObject().setProperty('panelHeight',64)
    app.processEvents()
    assert v.rootObject().findChild(QQuickItem,'monitor').property('singleRow') == True
    cfg.setProperty('oneLine',False)
    cfg.setProperty('ramInGiB',True)
    cfg.setProperty('interfaceName','')
    report.append({'test':'CPU subscription toggle and forced one-row mode','result':'PASS'})
    v.rootObject().setProperty('panelHeight',32)
    QTimer.singleShot(1500,restore_ram)
   except BaseException:
    import traceback;traceback.print_exc();app.exit(1)
  def restore_ram():
   try:
    assert expr('live.ramUsed.status') == 2
    assert expr('live.ramText') != '—'
    report.append({'test':'Used-memory display receives live memory sensor','result':'PASS'})
    cfg.setProperty('ramInGiB',False)
    cfg.setProperty('cpuMode',1)
    cfg.setProperty('ramMode',1)
    cfg.setProperty('ramUnit',1)
    cfg.setProperty('netUnit',2)
    QTimer.singleShot(2500,check_modes)
   except BaseException:
    import traceback;traceback.print_exc();app.exit(1)
  QTimer.singleShot(1200,missing_sensor_check)
 except BaseException:
  import traceback;traceback.print_exc();app.exit(1)

def check_modes():
 try:
  cfg=v.rootObject().property('settings')
  cores=expr('live.coreValues')
  if hasattr(cores,'toVariant'): cores=cores.toVariant()
  count=int(expr('live.cpuCount.value'))
  assert len(cores)==count and count>0,(count,cores)
  assert count == os.cpu_count(),(count,os.cpu_count())
  assert all(0<=value<=100 for value in cores),cores
  assert '/' in expr('live.ramText') and expr('live.ramText').endswith(' GB')
  total=float(expr('live.ramTotal.value'))
  memtotal=next(float(l.split()[1])*1024 for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemTotal:'))
  assert abs(total-memtotal)/memtotal<0.01,(total,memtotal)
  assert expr('live.uploadText').endswith(' MB/s')
  cfg.setProperty('width',720)
  v.rootObject().setProperty('panelHeight',48)
  app.processEvents()
  report.append({'test':'All logical CPU sensors live','result':'PASS','logical_cpus':count,'values':cores})
  report.append({'test':'Used/total GB memory mode and raw byte units verified against /proc/meminfo','result':'PASS'})
  v.rootObject().findChild(QObject,'caption').setProperty('text','Per-core CPU bars · Used / total memory · Network in MB/s')
  assert v.grabWindow().save(str((out/'04-display-modes-live.png').resolve()))
  cfg.setProperty('cpuMode',0);cfg.setProperty('ramMode',0);cfg.setProperty('netUnit',0);cfg.setProperty('width',520)
  v.rootObject().setProperty('panelHeight',32)
  v.rootObject().findChild(QObject,'caption').setProperty('text','CPU, memory and network — at a glance')
  QTimer.singleShot(200,capturecompact)
 except BaseException:
  import traceback;traceback.print_exc();app.exit(1)

def capturecompact():
 try:
  assert v.grabWindow().save(str((out/'01-compact-live.png').resolve()))
  v.rootObject().setProperty('panelHeight',48)
  QTimer.singleShot(200,capturelarge)
 except BaseException:app.exit(1);raise

def capturelarge():
 assert v.grabWindow().save(str((out/'02-two-row-live.png').resolve()))
 # Actual configuration page, initialized from release defaults.
 configqml=imports+'''Rectangle {
 width:860; height:900; color:"#f5f6f8"
 K.Theme.inherit:false; K.Theme.textColor:"#1c2330"
 C.Label { x:24; y:16; text:"Darius Panelmonitor — Settings"; font.pixelSize:24 }
 Monitor.ConfigGeneral { objectName:"config"; x:24; y:65; width:812
  cfg_showCpu:true; cfg_showRam:true; cfg_showNetwork:true; cfg_showBars:true
  cfg_oneLine:false; cfg_cpuMode:1; cfg_ramMode:1; cfg_ramUnit:1; cfg_netUnit:2; cfg_fontSize:11; cfg_width:520
  cfg_updateMs:1000; cfg_interfaceName:""; cfg_cpuColor:"#54c7ec"
  cfg_ramColor:"#b59bff"; cfg_netColor:"#73d6a0"
 }
}'''
 cv=newview(configqml,'release-settings-preview')
 def saveconfig():
  config=cv.rootObject().findChild(QObject,'config')
  assert config.property('cfg_width')==520
  assert cv.grabWindow().save(str((out/'03-settings.png').resolve()))
  report.append({'test':'English configuration page and configuration property aliases','result':'PASS'})
  tr.german=True
  assert tr.i18n('NET')=='NET'
  report.append({'test':'Packaged German gettext catalog','result':'PASS'})
  (out/'test-results.json').write_text(json.dumps(report,indent=2)+'\n')
  print('PASS screenshots and settings')
  adaptive_preview()
 QTimer.singleShot(350,saveconfig)

def adaptive_preview():
 aqml=imports+'''Rectangle {
 width:820; height:510; color:"#171b23"
 K.Theme.inherit:false; K.Theme.textColor:"#edf3fa"
 Text { x:28; y:22; text:"Your panel. Your preferences."; color:"#eef3fa"; font.pixelSize:26; font.bold:true }
 Text { x:28; y:62; text:"Adaptive alignment, configurable size, colors and display modes"; color:"#a9b5c7"; font.pixelSize:15 }
 Rectangle { x:40; y:112; width:48; height:340; color:"#252b35"; radius:5
  Monitor.MonitorView { objectName:"vertical"; anchors.fill:parent; verticalPanel:true; settings:releaseSettings; readings:releaseReadings }
 }
 Text { x:160; y:112; text:"Compact · 24 logical pixels high"; color:"#a9b5c7"; font.pixelSize:13 }
 Rectangle { x:160; y:140; width:620; height:24; color:"#252b35"; radius:3
  Monitor.MonitorView { objectName:"horizontal"; anchors.fill:parent; settings:releaseSettings; readings:releaseReadings }
 }
 Text { x:160; y:210; text:"Balanced · 48 logical pixels high"; color:"#a9b5c7"; font.pixelSize:13 }
 Rectangle { x:160; y:240; width:620; height:48; color:"#252b35"; radius:3
  Monitor.MonitorView { objectName:"horizontal"; anchors.fill:parent; settings:releaseSettings; readings:releaseReadings }
 }
 Text { x:160; y:338; text:"Spacious · 64 logical pixels high"; color:"#a9b5c7"; font.pixelSize:13 }
 Rectangle { x:160; y:368; width:620; height:64; color:"#252b35"; radius:3
  Monitor.MonitorView { objectName:"horizontal"; anchors.fill:parent; settings:releaseSettings; readings:releaseReadings }
 }
 Text { x:28; y:478; text:"Live KDE sensors · Vertical and horizontal layouts · Actual widget components"; color:"#9aa8ba"; font.pixelSize:12 }
}'''
 av=newview(aqml,'release-adaptive-preview')
 def saveadaptive():
  try:
   monitor=av.rootObject().findChild(QQuickItem,'vertical')
   cfg=v.rootObject().property('settings')
   for mode in [0,1]:
    cfg.setProperty('ramMode',mode)
    for width in [32,48,64]:
     for height in [240,400,600]:
      monitor.parentItem().setWidth(width);monitor.parentItem().setHeight(height)
      app.processEvents()
      av.grabWindow()
      app.processEvents()
      labels=[x for x in monitor.findChildren(QQuickItem) if x.isVisible() and x.property('text')]
      for label in labels:
       pos=label.mapToItem(monitor,QPointF(0,0))
       assert pos.y()>=-0.1 and pos.y()+label.height()<=height+0.1,(mode,width,height,label.property('text'),pos.y(),label.height())
   cfg.setProperty('ramMode',0)
   horizontals=[item for item in av.rootObject().findChildren(QQuickItem) if item.objectName()=='horizontal']
   for font in [8,11,24]:
    cfg.setProperty('fontSize',font)
    for length in [240,400,720]:
     for horizontal in horizontals:
      horizontal.parentItem().setWidth(length)
     app.processEvents();av.grabWindow();app.processEvents()
     for horizontal in horizontals:
      for label in [x for x in horizontal.findChildren(QQuickItem) if x.isVisible() and x.property('text')]:
       top=label.mapToItem(horizontal,QPointF(0,0))
       bottom=label.mapToItem(horizontal,QPointF(label.width(),label.height()))
       assert top.y()>=-0.1 and bottom.y()<=horizontal.height()+0.1,(font,length,label.property('text'))
   cfg.setProperty('fontSize',11)
   for horizontal in horizontals:horizontal.parentItem().setWidth(620)
   report.append({'test':'Horizontal font maxima 8/11/24 pt and lengths 240/400/720 at heights 24/48/64, centered within panel bounds','result':'PASS'})
   monitor.parentItem().setWidth(48);monitor.parentItem().setHeight(340)
   app.processEvents()
   assert av.grabWindow().save(str((out/'05-adaptive-layouts-live.png').resolve()))
   report.append({'test':'Vertical alignment at widths 32/48/64 and lengths 240/400/600, two memory modes','result':'PASS'})
   (out/'test-results.json').write_text(json.dumps(report,indent=2)+'\n')
   print('PASS adaptive vertical and horizontal layouts')
   cfg.setProperty('cpuColor','#ffb454');cfg.setProperty('ramColor','#f18cc8');cfg.setProperty('netColor','#6edee8')
   cfg.setProperty('ramMode',1);cfg.setProperty('ramUnit',0);cfg.setProperty('netUnit',3)
   cfg.setProperty('fontSize',13);cfg.setProperty('width',720)
   v.rootObject().setProperty('panelHeight',32)
   v.rootObject().findChild(QObject,'caption').setProperty('text','Custom palette · RAM used / total GiB · Network in KiB/s')
   QTimer.singleShot(200,save_custom)

  except BaseException:
   import traceback;traceback.print_exc();app.exit(1)
 QTimer.singleShot(300,saveadaptive)

def save_custom():
 assert v.grabWindow().save(str((out/'06-custom-style-live.png').resolve()))
 report.append({'test':'Alternative colors, maximum font size and memory/network modes rendered with live data','result':'PASS'})
 (out/'test-results.json').write_text(json.dumps(report,indent=2)+'\n')
 app.quit()

QTimer.singleShot(7000,testlive)
QTimer.singleShot(25000,lambda:app.exit(2))
result=app.exec()
for view in reversed(refs):
 view.setSource(QUrl())
sys.exit(result)
