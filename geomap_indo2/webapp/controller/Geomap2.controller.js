sap.ui.define(
  ["sap/ui/core/mvc/Controller", "sap/ui/model/json/JSONModel"],
  function (Controller, JSONModel) {
    "use strict";

    return Controller.extend("geomapindo.controller.Geomap2", {
      onInit: function () {
      // Get data dari json
      },
      onNavigateBack: function () {
        // Navigasi kembali ke view pertama
        var oRouter = sap.ui.core.UIComponent.getRouterFor(this);
        oRouter.navTo("RouteGeomap");
      },
    });
  }
);
