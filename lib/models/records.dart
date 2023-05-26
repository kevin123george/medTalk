class Records{
 final int? id;
 final String text;
 final DateTime timestamp;
 final int? uid;

 const Records({required this.text,required this.timestamp,this.id,this.uid});

 Map<String, dynamic> toMap() {
  return {
   'id': id,
   'text': text,
   'timestamp': timestamp,
  };
 }

 factory Records.fromMap(Map<String, dynamic> map) {
  return Records(
   id: map['id'],
   text: map['text'],
   timestamp: map['timestamp'],
  );
 }
}

