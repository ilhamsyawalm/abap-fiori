sap.ui.define(["sap/ui/core/mvc/Controller"], function (Controller) {
  "use strict";

  return Controller.extend("analytics.controller.View1", {
    onInit: function () {
      this.getOwnerComponent()
        .getRouter()
        .attachRoutePatternMatched(this.geoMapCollection, this);
    },
    geoMapCollection: function () {
      var oDataModel = this.getView().getModel();
      var x = this;

      oDataModel.read("/geomapSet", {
        success: function (data) {
          var aMapData = [];

          for (var i = 0; i < data.results.length; i++) {
            var item = data.results[i];

            const r = Math.round(Math.random() * 255);
            const g = Math.round(Math.random() * 255);
            const b = Math.round(Math.random() * 255);

            var color = "rgb(" + r + "," + g + "," + b + ")";
            let color2 = 'rgb(0,255,0)';
            item.color = color;
            aMapData.push(item);
            console.log(color2);
          }
          var oModel = new sap.ui.model.json.JSONModel();
          oModel.setData({
            mapData: aMapData,
          });
          x.getView().setModel(oModel, "viewModel");
        },
      });
    },
  });
});
