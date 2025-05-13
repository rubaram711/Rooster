class RolesAndPermissionsModel {
  List<RolesAndPermissions>? rolesAndPermissions;
  List<Roles>? roles;
  List<Permissions>? permissions;

  RolesAndPermissionsModel({this.rolesAndPermissions, this.roles, this.permissions});

  RolesAndPermissionsModel.fromJson(Map<String, dynamic> json) {
    if (json['rolesAndPermissions'] != null) {
      rolesAndPermissions = <RolesAndPermissions>[];
      json['rolesAndPermissions'].forEach((v) {
        rolesAndPermissions!.add(RolesAndPermissions.fromJson(v));
      });
    }
    if (json['roles'] != null) {
      roles = <Roles>[];
      json['roles'].forEach((v) {
        roles!.add(Roles.fromJson(v));
      });
    }
    if (json['permissions'] != null) {
      permissions = <Permissions>[];
      json['permissions'].forEach((v) {
        permissions!.add(Permissions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rolesAndPermissions != null) {
      data['rolesAndPermissions'] =
          rolesAndPermissions!.map((v) => v.toJson()).toList();
    }
    if (roles != null) {
      data['roles'] = roles!.map((v) => v.toJson()).toList();
    }
    if (permissions != null) {
      data['permissions'] = permissions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RolesAndPermissions {
  int? id;
  int? companyId;
  String? name;
  String? guardName;
  String? createdAt;
  String? updatedAt;
  List<Permissions>? permissions;

  RolesAndPermissions(
      {this.id,
        this.companyId,
        this.name,
        this.guardName,
        this.createdAt,
        this.updatedAt,
        this.permissions});

  RolesAndPermissions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    name = json['name'];
    guardName = json['guard_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['permissions'] != null) {
      permissions = <Permissions>[];
      json['permissions'].forEach((v) {
        permissions!.add(Permissions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['company_id'] = companyId;
    data['name'] = name;
    data['guard_name'] = guardName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (permissions != null) {
      data['permissions'] = permissions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Permissions {
  int? id;
  String? name;
  // String? displayName;
  // String? type;
  // String? guardName;
  // String? createdAt;
  // String? updatedAt;
  // Pivot? pivot;

  Permissions(
      {this.id,
        this.name,
        // this.displayName,
        // this.type,
        // this.guardName,
        // this.createdAt,
        // this.updatedAt,
        // this.pivot
      });

  Permissions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    // displayName = json['display_name'];
    // type = json['type'];
    // guardName = json['guard_name'];
    // createdAt = json['created_at'];
    // updatedAt = json['updated_at'];
    // pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    // data['display_name'] = displayName;
    // data['type'] = type;
    // data['guard_name'] = guardName;
    // data['created_at'] = createdAt;
    // data['updated_at'] = updatedAt;
    // if (pivot != null) {
    //   data['pivot'] = pivot!.toJson();
    // }
    return data;
  }
}

// class Pivot {
//   int? roleId;
//   int? permissionId;
//
//   Pivot({this.roleId, this.permissionId});
//
//   Pivot.fromJson(Map<String, dynamic> json) {
//     roleId = json['role_id'];
//     permissionId = json['permission_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['role_id'] = roleId;
//     data['permission_id'] = permissionId;
//     return data;
//   }
// }

class Roles {
  int? id;
  String? name;

  Roles({this.id, this.name});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}