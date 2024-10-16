sap.ui.define(
  ["sap/ui/core/mvc/Controller", "sap/ui/model/json/JSONModel"],
  function (Controller, JSONModel) {
    "use strict";

    return Controller.extend("geomapindo.controller.Geomap2", {
      onInit: function () {
        // Mengambil model yang sudah diatur secara global
      },
      onNavigateBack: function () {
        var oModel = sap.ui.getCore().getModel("productModel");

        if (oModel) {
          // Mendapatkan data dari model
          var oData = oModel.getData();
          // console.log("Data yang diambil:", oData);
          console.log(oData);
        } else {
          console.log("Model tidak ditemukan.");
        }
        // Navigasi kembali ke view pertama
        var oRouter = sap.ui.core.UIComponent.getRouterFor(this);
        oRouter.navTo("RouteGeomap");
      },
    });
  }
);
