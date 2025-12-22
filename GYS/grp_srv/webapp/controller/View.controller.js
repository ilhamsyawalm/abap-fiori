sap.ui.define(
  ["sap/ui/core/mvc/Controller"],
  /**
   * @param {typeof sap.ui.core.mvc.Controller} Controller
   */
  function (Controller) {
    "use strict";

    return Controller.extend("grpsrv.grpsrv.controller.View", {
      onInit: function () {
        let oModel = this.getOwnerComponent().getModel();
        let oData = this.getView().getModel("data");
        let oContext = this;

        //? //Mengambil data dari OData service dengan filter tertentu
        // oModel.read("/getMtsStocksSet", {
        //   filters: [
        //     new sap.ui.model.Filter(
        //       "Material",
        //       sap.ui.model.FilterOperator.EQ,
        //       "RBFF"
        //     ),
        //     new sap.ui.model.Filter(
        //       "Sloc",
        //       sap.ui.model.FilterOperator.EQ,
        //       "*"
        //     ),
        //     new sap.ui.model.Filter(
        //       "Plant",
        //       sap.ui.model.FilterOperator.EQ,
        //       "CBTG"
        //     ),
        //   ],
        //   success: function (data) {
        //     console.log("Data berhasil diambil:", data);
        //   },
        //   error: function (err) {
        //     console.error("Gagal mengambil data:", err);
        //   },
        // });

        //? //Mengambil data dari OData service tanpa filter
        // oModel.read("/wbmsWgtDataSet", {
        //   success: function (data) {
        //     console.log("Data tanpa filter berhasil diambil:", data);
        //   },
        //   error: function (err) {
        //     console.error("Gagal mengambil data tanpa filter:", err);
        //   },
        // });

        //? //Memanggil function import OData service dengan parameter tertentu
        // oModel.callFunction("/getBonOrder", {
        //   method: "GET",
        //   urlParameters: {
        //     BonOrdNo: "231211BON001",
        //   },
        //   success: function (data) {
        //     console.log("Data getBonOrder berhasil diambil:", data);
        //   },
        //   error: function (err) {
        //     console.error("Gagal mengambil data getBonOrder:", err);
        //   },
        // });

        // oModel.callFunction("/getDoData", {
        //   method: "GET",
        //   urlParameters: {
        //     ChangedDate: "20250917",
        //     DlvNo: "",
        //     DlvType: "ZDRG",
        //     // DlvType: "ZDST",
        //   },
        //   success: function (data) {
        //     console.log("Data getDoData berhasil diambil:", data);
        //     console.log(data.results);
        //   },
        //   error: function (err) {
        //     console.error("Gagal mengambil data getDoData:", err);
        //   },
        // });

        let oToday = new Date();
        // Change format ke YYYYMMDD
        let sChangedDate =
          oToday.getFullYear().toString() +
          String(oToday.getMonth() + 1).padStart(2, "0") +
          String(oToday.getDate()).padStart(2, "0");

        this.byId("ChangeDate").setValue(sChangedDate);
        console.log(oToday);
        oModel.callFunction("/getDoData", {
          method: "GET",
          urlParameters: {
            ChangedDate: sChangedDate,
            DlvNo: "",
            DlvType: "",
          },
          success: function (hasil) {
            console.log("Data getDoData berhasil diambil:", hasil);
            let result = hasil.results;
            oContext.getView().setModel(oData, "result");

            if (result.length === 0) {
              sap.m.MessageToast.show("Data tidak ditemukan");
            } else {
              sap.m.MessageToast.show("Data berhasil diambil");
            }
          },
          error: function (err) {
            console.error("Gagal mengambil data getDoData:", err);
          },
        });
      },

      onPress: function () {
        // let select = this.getView().byId("Detail").getSelectedKey();  "Kalo mau pake dropdown"
        let noDo = this.getView().byId("DelivNo").getValue();
        let select = this.getView().byId("DelivType").getValue().toUpperCase();
        let changeDate = this.getView().byId("ChangeDate").getValue();

        let oData = this.getView().getModel("data");
        let oContext = this;
        let oModel = this.getOwnerComponent().getModel();

        let formattedDate = changeDate.split("-").join("");

        console.log(formattedDate);
        console.log(select);

        oModel.callFunction("/getDoData", {
          method: "GET",
          urlParameters: {
            ChangedDate: formattedDate,
            DlvNo: noDo,
            DlvType: select,
          },
          success: function (hasil) {
            console.log("Data getDoData berhasil diambil:", hasil);
            let result = hasil.results;
            console.log(result.length);
            oData.setData(result);
            oContext.getView().setModel(oData, "result");

            if (result.length === 0) {
              sap.m.MessageToast.show("Data tidak ditemukan");
            } else {
              sap.m.MessageToast.show("Data berhasil diambil");
            }
          },
          error: function (err) {
            console.error("Gagal mengambil data getDoData:", err);
          },
        });
      },
    });
  }
);
