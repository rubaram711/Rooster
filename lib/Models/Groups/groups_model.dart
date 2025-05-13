

class Group {
  int? id;
  String? code;
  String? name;
  String? showName;
  String? parentId;
  List<Group>? children;

  Group(
      {this.id,
        this.code,
        this.name,
        this.showName,
        this.parentId,
        this.children,
       });

  Group.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    showName = json['show_name'];
    parentId = '${json['parent_id']??''}';
    if (json['children'] != null) {
      children = <Group>[];
      json['children'].forEach((v) {
        children!.add(Group.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['show_name'] = showName;
    data['parent_id'] = parentId;
    // data['active'] = this.active;
    if (children != null) {
      data['children'] =
          children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


