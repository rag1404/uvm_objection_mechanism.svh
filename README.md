# uvm_objection_mechanism.svh
This program is about UVM objections and Drain time !! 

// UVM objection mechanism is more like a counter incrementing when there is a objection raise and decrementing when there is objection drop.

# Example 1

// Let's look at the test 

// To start any UVM TB or to progress time, UVM components have to raise and drop objections.

// Obviosuly each component can raise and drop objections, but the ideal place would be test.

// phase.raise_objection(this); // The component raises and objection
 
 // In between we can execute the sequences we want
 
//   phase.drop_objection(this); // The component drops an objection

// This is all we need for running a test.

# Example 2

// Now that we know how to raise and drop objections

// Lets display the objections raised in our env

// phase.get_objection().set_propagate_mode(1);  

// Propagate_mode gives us hierarchial progation for components

// phase.get_objection().display_objections(uvm_root::get(), 1); 

// Using inbuilt method we can display the objections

// This tells wich components have raised an objections

// ---------------------------------------------------------

Source  Total   

 Count    Count     Object

 ---------------------------------------------------------

 0         2       uvm_top

 1         2         uvm_test_top

 0         1           env

 1         1             test_b

//---------------------------------------------------------

// you can see above two components have raised objections one is uvm_test_top and another one is test_b
