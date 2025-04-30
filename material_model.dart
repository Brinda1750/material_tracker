class MaterialItem {
  String name;
  double unitCost;
  int stock;

  MaterialItem({required this.name, required this.unitCost, required this.stock});
}

class UsageLog {
  String materialName;
  int quantity;
  double totalCost;
  DateTime date;

  UsageLog(this.materialName, this.quantity, this.totalCost, this.date);
}

class Task {
  String material;
  int quantity;
  String assignedTo;

  Task(this.material, this.quantity, this.assignedTo);
}

List<MaterialItem> materials = [];
List<UsageLog> usageLogs = [];
List<Task> tasks = [];

int lowStockThreshold = 10;
