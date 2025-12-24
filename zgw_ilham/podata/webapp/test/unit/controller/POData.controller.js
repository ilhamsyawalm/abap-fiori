/*global QUnit*/

sap.ui.define([
	"podata/controller/POData.controller"
], function (Controller) {
	"use strict";

	QUnit.module("POData Controller");

	QUnit.test("I should test the POData controller", function (assert) {
		var oAppController = new Controller();
		oAppController.onInit();
		assert.ok(oAppController);
	});

});
