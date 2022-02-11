class DataStatics {
  //สำหรับรถที่ยังไม่ได้อัปโหลด
  int countRiderNotup;
  //ผู้ใช้คน ๆ นั้น
  int countMeRidertoday; //จำนวนรถที่ผู้ใช้แต่ละอัปมารายวัน
  int countMeRidertomonth; //จำนวนรถที่ผู้ใช้แต่ละอัปมารายเดือน
  int countMeRidertotal; //จำนวนรถที่ผู้ใช้แต่ละอัปมาทั้งหมด
  //ผู้ใช้ทั้งหมด
  int countAllRidertoday; //จำนวนรถที่ผู้ใช้ทั้งหมดอัปมารายวัน
  int countAllRidertomonth; //จำนวนรถที่ผู้ใช้ทั้งหมดอัปมารายเดือน
  int countAllRidertotal; //จำนวนรถที่ผู้ใช้ทั้งหมดอัปมาทั้งหมด

  DataStatics(
    this.countRiderNotup,
    this.countMeRidertoday,
    this.countMeRidertomonth,
    this.countMeRidertotal,
    this.countAllRidertoday,
    this.countAllRidertomonth,
    this.countAllRidertotal,
  );
}
