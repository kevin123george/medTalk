
class Records {
 final int? id;
 String text;
 final int timestamp;
 final int? uid;
 String? name;
 String? title;
 String? session;

 Records({
  required this.text,
  required this.timestamp,
  this.id,
  this.uid,
  this.name,
  this.title,
  this.session,
 });

 Map<String, dynamic> toMap() {
  return {
   'id': id,
   'text': text,
   'timestamp': timestamp,
   'name': name,
   'title': title,
   'session': session,
  };
 }

 factory Records.fromMap(Map<String, dynamic> map) {
  return Records(
   id: map['id'],
   text: map['text'],
   timestamp: map['timestamp'],
   name: map['name'],
   title: map['title'],
   session: map['session'],
  );
 }
}