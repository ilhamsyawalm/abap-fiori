	var vTotal = 0;	
	
    var subTotal = xfa.resolveNode("Table3.FooterRow1.Cell6");	    
	if (subTotal = null) {
		subTotal = 0;
	};
	
    var subTax = xfa.resolveNode("Table3.FooterRow1.Cell8");	    
	if (subTax = null) {
		subTax = 0;
	};
		
    // Convert ke number
    subTotal = Number(subTotal);
    subTax = Number(subTax);	    
	
	// Total Value
	vTotal = subTotal + subTax;
			    	
	// Output Value	
	this.rawValue = vTotal;