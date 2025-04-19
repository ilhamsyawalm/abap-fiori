sap.ui.define(
	[
	  "sap/ui/Device",
	  "sap/ui/core/mvc/Controller",
	  "sap/ui/model/json/JSONModel",
	  "sap/m/Popover",
	  "sap/m/Button",
	  "sap/m/Dialog",
	  "sap/m/Text",
	  "sap/m/library",
	  "sap/tnt/library",
	  "sap/m/MessageToast",
	  "sap/suite/ui/commons/ChartContainer",
	  "sap/suite/ui/commons/ChartContainerContent",
	],
	function (
	  Device,
	  Controller,
	  JSONModel,
	  Popover,
	  Button,
	  Dialog,
	  Text,
	  library,
	  tntLibrary,
	  MessageToast,
	  ChartContainer,
	  ChartContainerContent
	) {
	  "use strict";
  
	  let aMapData = [];
  
	  var ButtonType = library.ButtonType,
		PlacementType = library.PlacementType,
		NavigationListItemDesign = tntLibrary.NavigationListItemDesign;
  
	  return Controller.extend("navigation3.controller.dashboard", {
		onInit: function () {
		  // this.getOwnerComponent()
		  //   .getRouter()
		  //   .attachRoutePatternMatched(this.geoMapCollection, this);
  
		  var oModel = new sap.ui.model.json.JSONModel("../model/Data.json");
		  this.getView().setModel(oModel);
  
		  var oViewModel = new sap.ui.model.json.JSONModel();
		  oViewModel.setData({
			geocustomerSet: [
			  { Text: "Company A", Value: 120 },
			  { Text: "Company B", Value: 200 },
			  { Text: "Company C", Value: 340 },
			],
		  });
		  this.getView().setModel(oViewModel, "viewModel");
		  // var oModel2 = new sap.ui.model.json.JSONModel();
  
		  // oModel2.setData({
		  //   products: aMapData,
		  //   navi: oModel,
		  // });
  
		  // this.getView().setModel(oModel2, "productModel");
  
		  // console.log(this.getView().getModel("productModel").getData());
  
		  this._setToggleButtonTooltip(!Device.system.desktop);
  
		  var oView = this.getView();
		  this.adjustMyChartBox(oView, "idVizFrame1", "idCell1");
		},
  
		//   geoMapCollection: function () {
		//     let oData = this.getView().getModel(); // Mendapatkan odata dari SAP
		//     console.log(oData);
  
		//     oData.read("/geomapSet", {
		//       success: function (data) {
		//         for (let i = 0; i < data.results.length; i++) {
		//           const item = data.results[i];
		//           aMapData.push(item);
		//         }
  
		//         console.log(aMapData);
		//       },
		//     });
		//   },
  
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
		  var oItem = oEvent.getParameter("item");
		  this.byId("pageContainer").to(this.getView().createId(oItem.getKey()));
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
  
		// Untuk hamburger side navigation
		onSideNavButtonPress: function () {
		  var oToolPage = this.byId("toolPage");
		  var bSideExpanded = oToolPage.getSideExpanded();
  
		  this._setToggleButtonTooltip(bSideExpanded);
  
		  oToolPage.setSideExpanded(!oToolPage.getSideExpanded());
		},
  
		onQuickActionPress: function (oEvent) {
		  if (oEvent.oSource.getDesign() !== NavigationListItemDesign.Action) {
			return;
		  }
		  if (!this.oDefaultDialog) {
			this.oDefaultDialog = new Dialog({
			  title: "Create Item",
			  type: "Message",
			  content: new Text({ text: "Create New Navigation List Item" }),
			  beginButton: new Button({
				type: ButtonType.Emphasized,
				text: "Create",
				press: function () {
				  this.oDefaultDialog.close();
				}.bind(this),
			  }),
			  endButton: new Button({
				text: "Cancel",
				press: function () {
				  this.oDefaultDialog.close();
				}.bind(this),
			  }),
			});
  
			// to get access to the controller's model
			this.getView().addDependent(this.oDefaultDialog);
		  }
  
		  this.oDefaultDialog.open();
		},
  
		_setToggleButtonTooltip: function (bLarge) {
		  var oToggleButton = this.byId("sideNavigationToggleButton");
		  if (bLarge) {
			oToggleButton.setTooltip("Large Size Navigation");
		  } else {
			oToggleButton.setTooltip("Small Size Navigation");
		  }
		},
	  });
	}
  );
  