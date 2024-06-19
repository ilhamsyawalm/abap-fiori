/*global QUnit*/

sap.ui.define([
	"geomaps/controller/geomap.controller"
], function (Controller) {
	"use strict";

	QUnit.module("geomap Controller");

	QUnit.test("I should test the geomap controller", function (assert) {
		var oAppController = new Controller();
		oAppController.onInit();
		assert.ok(oAppController);
	});

});
