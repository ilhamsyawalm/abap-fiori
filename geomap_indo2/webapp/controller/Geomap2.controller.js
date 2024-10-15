sap.ui.define(["sap/ui/core/mvc/Controller"], function (Controller) {
  "use strict";

  return Controller.extend("geomapindo.controller.Geomap2", {
    onNavigateBack: function () {
      // Navigasi kembali ke view pertama
      var oRouter = sap.ui.core.UIComponent.getRouterFor(this);
      oRouter.navTo("RouteGeomap");
    },
  });
});
