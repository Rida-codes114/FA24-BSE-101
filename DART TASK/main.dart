void main() {

  String studentName = "Rida";
  int age = 20;
  String department = "Software Engineering";
  double cgpa = 3.45;
  bool isRegistered = true;
  
  print("=> SMART CAMPUS CANTEEN ENGINE");


  print("\n TASK 1: STUDENT PROFILE");

  print("Student Name: $studentName");
  print("Age: $age");
  print("Department: $department");
  print("CGPA: $cgpa");
  print("Registered: $isRegistered");



  print("\n TASK 2: ACCESS & DISCOUNT");

  double discountRate = 0.0;

  if (isRegistered) {
    print("Access Granted");

    if (cgpa >= 3.0) {
      discountRate = 0.20;
      print("Discount: 20%");
      print("Reason: CGPA is 3.0 or above.");
    } else {
      discountRate = 0.10;
      print("Discount: 10%");
      print("Reason: CGPA is below 3.0.");
    }
   
  // ignore: dead_code
  } else {
    discountRate = 0.0;

    print("Access Denied");
    print("Student is not registered.");
    print("Discount: 0%");
  }
  

  print("\nTASK 3: CANTEEN MENU");

  List<String> foodItems = [
    "Burger",
    "Pizza",
    "Fries",
    "Sandwich",
    "Cold Drink"
  ];
  Map<String, double> foodPrices = {
    "Burger": 300,
    "Pizza": 450,
    "Fries": 150,
    "Sandwich": 200,
    "Cold Drink": 100
  };

  print("Available Items:");

  for (String item in foodItems) {
    print("$item - Rs. ${foodPrices[item]}");
  }


  print("\n ORDER DETAILS ");
  Map<String, int> order = {
    "Burger": 1,
    "Cold Drink": 2,
    "Fries": 1
  };

  print("Selected Items:");

  for (String item in order.keys) {
    int quantity = order[item]!;
    double price = foodPrices[item]!;
    double itemTotal = price * quantity;

    print("$item x $quantity = Rs. $itemTotal");
  }

  print("\n ORDER / BILL CALCULATION ");

  double totalBill = 0;

  for (String item in order.keys) {
    int quantity = order[item]!;
    double price = foodPrices[item]!;

    totalBill = totalBill + (price * quantity);
  }

  double discountAmount = totalBill * discountRate;

  double finalBill = totalBill - discountAmount;

  print("Total Bill: Rs. $totalBill");
  print("Discount Amount: Rs. $discountAmount");
  print("Final Bill: Rs. $finalBill");
  
  print("=>  FINAL SUMMARY");

  print("Student: $studentName");
  print("Department: $department");
  print("CGPA: $cgpa");

  if (isRegistered) {
    print("Access: Granted");
  // ignore: dead_code
  } else{
    print("Access: Denied");
  }

  print("Discount Rate: ${discountRate * 100}%");
  print("Total Bill: Rs. $totalBill");
  print("Discount: Rs. $discountAmount");
  print("Final Amount: Rs. $finalBill");

  print("\nThank you for using Smart Campus Canteen!");
}