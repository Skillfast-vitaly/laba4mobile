import 'package:flutter/material.dart';

const bg=Color(0xffe9e4d8);
const ink = Color(0xff39424e);
const green=Color(0xffa9b89a);

const ms=['Январь','Февраль','Март','Апрель','Май','Июнь',
 'Июль','Август','Сентябрь','Октябрь','Ноябрь','Декабрь'];
const ws=['Пн','Вт','Ср','Чт','Пт','Сб','Вс'];
const cats=['Личное','Учёба','Дела'];
const cols=[Color(0xfff0b968),Color(0xffa1c4ee),Color(0xffa7cc94)];

String two(int n)=>n.toString().padLeft(2,'0');
String date(DateTime d)=>'${two(d.day)}.${two(d.month)}.${d.year}';
String time(TimeOfDay t)=>'${two(t.hour)}:${two(t.minute)}';
int mins(TimeOfDay t)=>t.hour*60+t.minute;

void main()=>runApp(const MyApp());

class MyApp extends StatelessWidget{
 const MyApp({super.key});
  @override
 Widget build(BuildContext context){
   return const MaterialApp(debugShowCheckedModeBanner:false,home:Home());
 }
}

class Ev{
 final int id,cat;
 final String name;
 final DateTime d;
 final TimeOfDay a,b;
 Ev(this.id,this.name,this.d,this.a,this.b,this.cat);
}

class Repo {
 final List<Ev> list=[];
 int id=1;

 void put(Ev e){
   if(e.id==0){
     list.add(Ev(id,e.name,e.d,e.a,e.b,e.cat));
      id++;
     return;
   }
   for(int i=0;i<list.length;i++){
    if(list[i].id==e.id){
      list[i]=e;
       return;
    }
   }
 }

 void del(Ev e){list.remove(e);}

 List<Ev> day(DateTime d){
   List<Ev> l=[];
    for(Ev e in list){
     if(e.d.year==d.year && e.d.month==d.month && e.d.day==d.day){
       l.add(e);
     }
   }
   l.sort((x,y)=>mins(x.a).compareTo(mins(y.a)));
   return l;
 }
}

class Home extends StatefulWidget {
 const Home({super.key});
 @override
 State<Home> createState()=>_HomeState();
}

class _HomeState extends State<Home>{
 final rep=Repo();
 DateTime d=DateUtils.dateOnly(DateTime.now());

 void move(int n){
   DateTime x=DateTime(d.year,d.month+n,1);
   if(x.year<1900||x.year>2100)return;
    setState((){d=x;});
 }

 Future<void> open([Ev? e])async{
   final x=await Navigator.push<Ev>(context,
     MaterialPageRoute<Ev>(builder:(ctx)=>Edit(d:d,e:e)));
   if(!mounted||x==null)return;
    setState((){
     rep.put(x);
     d=x.d;
   });
 }

 List<Widget> tiles(){
   List<Widget> l=[];
   int skip=DateTime(d.year,d.month,1).weekday-1;
   int cnt=DateTime(d.year,d.month+1,0).day;

   for(String s in ws){
     l.add(Center(child:Text(s,style:const TextStyle(color:ink))));
   }
   for(int i=0;i<skip;i++) {l.add(const SizedBox());}

   for(int i=1;i<=cnt;i++){
    l.add(TextButton(
      onPressed:(){setState((){d=DateTime(d.year,d.month,i);});},
       style:TextButton.styleFrom(
        backgroundColor:i==d.day?green:bg,foregroundColor:ink,
        padding:EdgeInsets.zero,
        shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(6)),
      ),
      child:FittedBox(fit:BoxFit.scaleDown,child:Text('$i')),
    ));
   }
   return l;
 }

 Widget cal(){
   return Card(color:Colors.white,margin:EdgeInsets.zero,
    child:Padding(padding:const EdgeInsets.all(10),
     child:Column(children:[
      Row(children:[
       IconButton(onPressed:(){move(-1);},icon:const Icon(Icons.chevron_left),
        tooltip:'Предыдущий месяц'),
       Expanded(child:Text('${ms[d.month-1]} ${d.year}',
        textAlign:TextAlign.center,
        style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold))),
        IconButton(onPressed:(){move(1);},icon:const Icon(Icons.chevron_right),
         tooltip:'Следующий месяц'),
      ]),
      GridView.count(crossAxisCount:7,mainAxisExtent:40,
       crossAxisSpacing:4,mainAxisSpacing:4,
       primary:false,shrinkWrap:true,padding:EdgeInsets.zero,
       physics:const NeverScrollableScrollPhysics(),children:tiles()),
    ]),
   ));
 }

 Widget card(Ev e){
   return Card(color:Colors.white,margin:const EdgeInsets.only(top:8),
    child:ListTile(
      onTap:(){open(e);},
      leading:CircleAvatar(radius:8,backgroundColor:cols[e.cat]),
      title:Text(e.name,maxLines:2,overflow:TextOverflow.ellipsis),
       subtitle:Text('${time(e.a)}–${time(e.b)} · ${cats[e.cat]}'),
      trailing:PopupMenuButton<String>(
        tooltip:'Действия',
        itemBuilder:(ctx)=>const [
         PopupMenuItem(value:'edit',child:Text('Редактировать')),
         PopupMenuItem(value:'del',child:Text('Удалить')),
        ],
         onSelected:(s){
          if(s=='edit'){open(e);}
          if(s=='del') {setState((){rep.del(e);});}
        },
      ),
    ),
   );
 }

 @override
 Widget build(BuildContext context){
   List<Ev> l=rep.day(d);
   return Scaffold(
    backgroundColor:bg,
    appBar:AppBar(title:const Text('Календарь'),
     backgroundColor:ink,foregroundColor:Colors.white),
     floatingActionButton:FloatingActionButton.extended(
       onPressed:(){open();},backgroundColor:green,foregroundColor:ink,
       icon:const Icon(Icons.add),label:const Text('Добавить'),
     ),
    body:SafeArea(child:Center(child:ConstrainedBox(
     constraints:const BoxConstraints(maxWidth:520),
     child:ListView(padding:const EdgeInsets.fromLTRB(12,12,12,95),
       children:[
        cal(),
        const SizedBox(height:14),
         Container(color:green,padding:const EdgeInsets.all(12),
          child:Text('События / '+date(d),
           style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold))),
        if(l.isEmpty)const Padding(padding:EdgeInsets.all(16),
         child:Text('В этот день событий нет',textAlign:TextAlign.center)),
        for(Ev e in l)card(e),
       ],
     ),
    ))),
   );
 }
}

class Edit extends StatefulWidget{
 final DateTime d;
 final Ev? e;
 const Edit({super.key,required this.d,this.e});
 @override
 State<Edit> createState()=>_EditState();
}

class _EditState extends State<Edit>{
 final c=TextEditingController();
 final f=GlobalKey<FormState>();
 late DateTime d;
 TimeOfDay a=const TimeOfDay(hour:9,minute:0);
 TimeOfDay b=const TimeOfDay(hour:10,minute:0);
 int cat=0;
 String err='';

 @override
 void initState(){
   super.initState();
   d=widget.d;
    Ev? e=widget.e;
   if(e!=null){
     c.text=e.name;
     d=e.d;
     a=e.a;b=e.b;
      cat=e.cat;
   }
 }

 Future<void> pickDay()async{
   final x=await showDatePicker(context:context,
    initialDate:d,firstDate:DateTime(1900),lastDate:DateTime(2100,12,31),
     helpText:'Дата события',cancelText:'Отмена',confirmText:'ОК');
   if(!mounted||x==null)return;
   setState((){d=x;});
 }

 Future<void> pickTime(bool start)async{
    final x=await showTimePicker(context:context,initialTime:start?a:b,
     helpText:start?'Время начала':'Время окончания',
     cancelText:'Отмена',confirmText:'ОК',
     builder:(ctx,w)=>MediaQuery(
       data:MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat:true),child:w!),
   );
   if(!mounted||x==null)return;
   setState((){
    if(start){a=x;}
     else {b=x;}
    err='';
   });
 }

 void save(){
   if(!f.currentState!.validate())return;
   if(mins(b)<=mins(a)){
     setState((){err='Конец должен быть позже начала в тот же день';});
      return;
   }
   Ev x=Ev(widget.e?.id??0,c.text.trim(),d,a,b,cat);
   Navigator.pop(context,x);
 }

 @override
 Widget build(BuildContext context){
   return Scaffold(backgroundColor:bg,
    appBar:AppBar(title:Text(widget.e==null?'Новое событие':'Редактирование'),
     backgroundColor:ink,foregroundColor:Colors.white),
    body:SafeArea(child:Form(key:f,child:ListView(
     padding:const EdgeInsets.all(16),
     children:[
      TextFormField(controller:c,
       decoration:const InputDecoration(labelText:'Название',border:OutlineInputBorder()),
        validator:(s){
         if(s==null||s.trim()=='') return 'Введи название';
          return null;
        },
      ),
      const SizedBox(height:12),
       OutlinedButton(onPressed:pickDay,child:Text('Дата: '+date(d))),
      OutlinedButton(onPressed:(){pickTime(true);},child:Text('Начало: '+time(a))),
       OutlinedButton(onPressed:(){pickTime(false);},child:Text('Конец: '+time(b))),
      if(err!='')Text(err,style:const TextStyle(color:Colors.red)),
      const SizedBox(height:12),
      const Text('Категория'),
       Wrap(spacing:8,children:[
        for(int i=0;i<cats.length;i++)
          ChoiceChip(label:Text(cats[i]),selected:cat==i,selectedColor:cols[i],
           onSelected:(v){setState((){cat=i;});}),
       ]),
      const SizedBox(height:16),
      ElevatedButton(onPressed:save,child:const Text('Сохранить')),
     ],
    ))),
   );
 }

 @override
 void dispose(){
   c.dispose();
    super.dispose();
 }
}