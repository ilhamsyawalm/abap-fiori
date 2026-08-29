var vTotal = 0;

// Mendapatkan semua PurchaseOrderItemNode
var itemNodes = xfa.resolveNodes(
  "xfa.datasets.data.Form.PurchaseOrderNode.PurchaseOrderItems.PurchaseOrderItemNode[*]",
);

xfa.host.messageBox("Total Item = " + itemNodes.length);

// Loop setiap item
for (var i = 0; i < itemNodes.length; i++) {
  var item = itemNodes.item(i);

  // Ambil semua pricing condition dari item tersebut
  var conditionNodes = xfa.resolveNodes(
    "xfa.datasets.data.Form.PurchaseOrderNode.PurchaseOrderItems.PurchaseOrderItemNode[" +
      i +
      "].ItemPricingConditionNodeSet.ItemPricingConditionNode[*]",
  );

  if (conditionNodes == null) {
    continue;
  }

  // Loop setiap pricing condition
  for (var j = 0; j < conditionNodes.length; j++) {
    var condition = conditionNodes.item(j);

    // Null check untuk condition
    if (condition == null) {
      continue;
    }

    // Cek Condition Type
    if (
      condition.ConditionType != null &&
      condition.ConditionType.value == "TTX1"
    ) {
      var AmountVAT =
        condition.ConditionAmount != null
          ? condition.ConditionAmount.value
          : null;

      // Jika kosong atau null
      if (AmountVAT == null || AmountVAT == "") {
        AmountVAT = 0;
      }

      // Convert ke Number
      AmountVAT = parseFloat(AmountVAT);

      // Jika bukan angka
      if (isNaN(AmountVAT)) {
        AmountVAT = 0;
      }

      // Tambahkan ke total
      vTotal += AmountVAT;
    }
  }
}

// Format 2 decimal
this.rawValue = parseFloat(vTotal.toFixed(2));
