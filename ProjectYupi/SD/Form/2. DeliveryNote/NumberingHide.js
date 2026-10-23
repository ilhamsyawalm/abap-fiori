//Form.Original.Table.Table6.Row1.Cell1::initialize - (JavaScript, client)
//var result = "";
//var i = this.parent.index + 1;
//this.rawValue = i;
// Event: initialize di Cell1 (kolom Item/nomor)

var counter = 0;
var currentIndex = this.parent.index;

// Loop semua row dari index 0 sampai row saat ini
for (var i = 0; i <= currentIndex; i++) {
  var row = this.parent.parent.resolveNode("Row1[" + i + "]");

  if (row != null) {
    var cell4 = row.resolveNode("Cell4");
    var cell5 = row.resolveNode("Cell5");

    // Cek apakah row ini visible (tidak di-hide)
    var isHidden = false;

    if (cell4 == null || cell4.rawValue == null || cell4.rawValue == "") {
      isHidden = true;
    }
    if (cell5 != null && cell5.rawValue == "0.000") {
      isHidden = true;
    }

    // Kalau visible, tambah counter
    if (!isHidden) {
      counter++;
    }
  }
}

// Set nomor urut hanya kalau row ini visible
var myCell4 = this.parent.resolveNode("Cell4");
var myCell5 = this.parent.resolveNode("Cell5");

var myHidden = false;
if (myCell4 == null || myCell4.rawValue == null || myCell4.rawValue == "") {
  myHidden = true;
}
if (myCell5 != null && myCell5.rawValue == "0.000") {
  myHidden = true;
}

if (!myHidden) {
  this.rawValue = counter;
} else {
  this.rawValue = "";
}
