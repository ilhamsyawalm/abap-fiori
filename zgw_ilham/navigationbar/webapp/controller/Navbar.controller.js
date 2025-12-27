sap.ui.define(
  [
    "sap/ui/Device",
    "sap/ui/core/mvc/Controller",
    "sap/m/Popover",
    "sap/m/Button",
    "sap/m/library",
    "sap/tnt/library",
    "sap/m/MessageToast",
    "sap/suite/ui/commons/ChartContainer",
    "sap/suite/ui/commons/ChartContainerContent",
  ],
  /**
   * @param {typeof sap.ui.core.mvc.Controller} Controller
   */
  function (
    Device,
    Controller,
    Popover,
    Button,
    library,
    tntLibrary,
    MessageToast,
    ChartContainer,
    ChartContainerContent
  ) {
    "use strict";

    var ButtonType = library.ButtonType,
      PlacementType = library.PlacementType,
      NavigationListItemDesign = tntLibrary.NavigationListItemDesign;

    return Controller.extend("navigationbar.controller.Navbar", {
      onInit: function () {
        var oModel = new sap.ui.model.json.JSONModel(
          "https://ilhamsyawalm.github.io/abap-fiori/zgw_ilham/navigationbar/webapp/model/Data.json"
        );

        this.getView().setModel(oModel, "jsonModel");
      },

      adjustMyChartBox: function (oView, sChartId, sBlockId) {
        var oVizFrame = oView.byId(sChartId);
        var oChartContainerContent = new ChartContainerContent({
          content: [oVizFrame],
        });
        var oChartContainer = new ChartContainer({
          content: [oChartContainerContent],
        });

        oChartContainer.setShowFullScreen(true);
        oChartContainer.setAutoAdjustHeight(true);
        oView.byId(sBlockId).addContent(oChartContainer);
      },

      // Saat side navigation digunakan
      onItemSelect: function (oEvent) {
        let oDataOld = this.getOwnerComponent().getModel();
        let oData = this;

        var oItem = oEvent.getParameter("item");
        this.byId("pageContainer").to(this.getView().createId(oItem.getKey()));
        if (oItem.getKey() === "Project1") {
          // // "Get data dari entitySet"
          // oDataOld.read("/PoDataSet", {
          //   success: function (data) {
          //     console.log("Data PoDataSet berhasil diambil:", data);
          //     let result = data.results;

          //     let oModelNew = new sap.ui.model.json.JSONModel();
          //     oModelNew.setData(result);
          //     oData.getView().setModel(oModelNew, "output");
          //   },
          //   error: function (err) {
          //     console.error("Gagal mengambil data PoDataSet:", err);
          //   },
          // });
          const oModel = new sap.ui.model.odata.v2.ODataModel(
            "/sap/opu/odata/sap/ZGW_ILHAM_SRV/PoDataSet"
          );
          this.getView().setModel(oModel);
        } else if (oItem.getKey() === "Project2") {
          // "Get data dari Function Import"
          let oToday = new Date();
          let sChangedDate =
            oToday.getFullYear().toString() +
            String(oToday.getMonth() + 1).padStart(2, "0") +
            String(oToday.getDate()).padStart(2, "0");

          this.byId("CreateOn").setValue(sChangedDate);

          oDataOld.callFunction("/getPoData", {
            method: "GET",
            urlParameters: {
              PONumber: "",
              material: "",
              orderType: "",
              createOn: sChangedDate,
            },
            success: function (data) {
              console.log("Data getPoData berhasil diambil:", data);
              let result = data.results;

              let oModelNew = new sap.ui.model.json.JSONModel();
              oModelNew.setData(result);
              oData.getView().setModel(oModelNew, "output");

              if (result.length === 0) {
                sap.m.MessageToast.show("Data tidak ditemukan");
              } else {
                sap.m.MessageToast.show("Data berhasil diambil");
              }
            },
            error: function (err) {
              console.error("Gagal mengambil data getPoData:", err);
            },
          });
        }
      },

      // Memasukan button baru saat nama di click
      handleUserNamePress: function (event) {
        var oPopover = new Popover({
          showHeader: false,
          placement: PlacementType.Bottom,
          content: [
            new Button({
              text: "Feedback",
              type: ButtonType.Transparent,
            }),
            new Button({
              text: "Help",
              type: ButtonType.Transparent,
            }),
            new Button({
              text: "Logout",
              type: ButtonType.Transparent,
            }),
          ],
        }).addStyleClass("sapMOTAPopover sapTntToolHeaderPopover");

        oPopover.openBy(event.getSource());
      },

      // Alert saat user di click
      onAvatarPressed: function () {
        MessageToast.show("Hello everyone! :)");
      },

      onFixedPressed: function () {
        MessageToast.show("Fixed navigation got press! :)");
      },

      // Untuk hamburger side navigation
      onSideNavButtonPress: function () {
        var oToolPage = this.byId("toolPage");
        var bSideExpanded = oToolPage.getSideExpanded();

        this._setToggleButtonTooltip(bSideExpanded);

        oToolPage.setSideExpanded(!oToolPage.getSideExpanded());
      },

      _setToggleButtonTooltip: function (bLarge) {
        var oToggleButton = this.byId("sideNavigationToggleButton");
        if (bLarge) {
          oToggleButton.setTooltip("Large Size Navigation");
        } else {
          oToggleButton.setTooltip("Small Size Navigation");
        }
      },

      onPress: function () {
        let poNumber = this.getView().byId("PONumber").getValue();
        let material = this.getView().byId("Material").getValue().toUpperCase();
        let orderType = this.getView()
          .byId("OrderType")
          .getValue()
          .toUpperCase();
        let createOn = this.getView().byId("CreateOn").getValue();

        let formattedDate = createOn.split("-").join("");

        let oModel = this.getOwnerComponent().getModel();
        let oData = this;

        oModel.callFunction("/getPoData", {
          method: "GET",
          urlParameters: {
            PONumber: poNumber,
            material: material,
            orderType: orderType,
            createOn: formattedDate,
          },
          success: function (data) {
            console.log("Data getPoData berhasil diambil:", data);
            let result = data.results;

            let oModelNew = new sap.ui.model.json.JSONModel();
            oModelNew.setData(result);
            oData.getView().setModel(oModelNew, "output");

            if (result.length === 0) {
              sap.m.MessageToast.show("Data tidak ditemukan");
            } else {
              sap.m.MessageToast.show("Data berhasil diambil");
            }
          },
          error: function (err) {
            console.error("Gagal mengambil data getPoData:", err);
          },
        });
      },
      onBeforeExport: function (oEvt) {
        const mExcelSettings = oEvt.getParameter("exportSettings");
        // GW export
        if (mExcelSettings.url) {
          return;
        }
        // For UI5 Client Export --> The settings contains sap.ui.export.SpreadSheet relevant settings that be used to modify the output of excel

        // Disable Worker as Mockserver is used in Demokit sample --> Do not use this for real applications!
        mExcelSettings.worker = false;
      },
      onExit: function () {
        this._oMockServer.destroy();
      },
    });
  }
);
