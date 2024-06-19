sap.ui.define(["sap/ui/core/mvc/Controller"], function (Controller) {
  "use strict";

  return Controller.extend("geomaps.controller.geomap", {
    onInit: function () {
      var oview = this.getView();

      this.getOwnerComponent()
        .getRouter()
        .attachRoutePatternMatched(this.geoMapCollection, this);
    },

    geoMapCollection: function () {
      var oDataModel = this.getView().getModel();
      var x = this;

      oDataModel.read("/CustomerCodeSet", {
        success: function (data) {
          var MapData = [];

          for (var i = 0; i < data.results.length; i++) {
            var item = data.results[i];

            const r = Math.round(Math.random() * 255);
            const g = Math.round(Math.random() * 255);
            const b = Math.round(Math.random() * 255);
            // var color = 'rgb(" + r + "," + g + "," + b + ")';
            var color = "rgb(0,255,0)";
            item.color = color;
            console.log(color);
            MapData.push(item);
          }
          var oModel = new sap.ui.model.json.JSONModel();
          oModel.setData({
            mapData: MapData,
          });
          x.getView().setModel(oModel, "viewModel");
        },
      });
    },
  });
});
