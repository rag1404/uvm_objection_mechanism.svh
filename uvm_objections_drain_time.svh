 

import uvm_pkg::*;
`include "uvm_macros.svh"
program tb;

class transaction extends uvm_object;
  rand bit[3:0] data;
  rand bit[5:0] addr;
  rand bit wr_en;
  
  `uvm_object_utils_begin(transaction);
  `uvm_field_int(data,UVM_ALL_ON)
  `uvm_field_int(addr,UVM_ALL_ON)
  `uvm_field_int(wr_en,UVM_ALL_ON)
  `uvm_object_utils_end;
  
  
  function new (string name  = "transaction");
    super.new(name);
  endfunction  
    
endclass

// comp_a has a analysis port which it sends transactions to comp_c
// you can  see the write function getting called.

class comp_a extends uvm_component;
  `uvm_component_utils (comp_a)
  
  uvm_analysis_port #(transaction) broadcast_port;
  
  function new (string name = "comp_a", uvm_component parent);
    super.new(name,parent);
  endfunction
  
   function void build_phase(uvm_phase phase);
     broadcast_port = new("broadcast_port",this);
  endfunction
  
  task run_phase (uvm_phase phase);
    transaction tx;
    
    tx = transaction::type_id::create("tx", this);
    
    void'(tx.randomize());
    `uvm_info(get_type_name(),$sformatf(" tranaction randomized"),UVM_LOW)
    tx.print();
    `uvm_info(get_type_name(),$sformatf(" tranaction sending to comp_c"),UVM_LOW)
    broadcast_port.write(tx);

  endtask  
  
endclass

// comp_b has a analysis port which it sends transactions to comp_c
// you can see the write function getting called.

class comp_b extends uvm_component;
  `uvm_component_utils (comp_b)
  
  uvm_analysis_port #(transaction) aport_send;
  
  function new (string name = "comp_b", uvm_component parent);
    super.new(name,parent);
  endfunction
  
   function void build_phase(uvm_phase phase);
     aport_send = new("aport_send",this);
  endfunction
  
 virtual task run_phase (uvm_phase phase);
    
   // phase.raise_objection(this);
   
    transaction trans;
   phase.raise_objection(this);
    phase.get_objection().display_objections(uvm_root::get(), 1);
   trans = transaction::type_id::create("trans",this);
    
    trans.data = 4'h3;
    trans.addr = 6'h10;
    trans.wr_en = 1;
    
    `uvm_info(get_type_name(),$sformatf(" tranaction not randomized"),UVM_LOW)
    trans.print();
    `uvm_info(get_type_name(),$sformatf(" tranaction sending to comp_c"),UVM_LOW)
    aport_send.write(trans);
    phase.drop_objection(this);
 
  endtask  
 
endclass

// comp_c has two imp_decl ports which is called comp_a export and comp_b export
// comp_c also implements two write functions one for comp_a and one for comp_b

  `uvm_analysis_imp_decl(_comp_a)
  `uvm_analysis_imp_decl(_comp_b)
  
  class comp_c extends uvm_component;
    `uvm_component_utils (comp_c)
  
    uvm_analysis_imp_comp_a #(transaction,comp_c) comp_a_export;
    uvm_analysis_imp_comp_b #(transaction,comp_c) comp_b_export;
    
    
    function new (string name = "comp_c", uvm_component parent);
    super.new(name,parent);
  endfunction
  
   function void build_phase(uvm_phase phase);
     comp_a_export = new ("comp_a_export",this);
     comp_b_export = new ("comp_b_export",this);
  endfunction
  
    function void write_comp_a (transaction t);
      `uvm_info(get_type_name(),$sformatf(" tranaction Received in scoreboard comp_a"),UVM_LOW)
    t.print();
      
    endfunction

    function void write_comp_b (transaction tr);
      `uvm_info(get_type_name(),$sformatf(" tranaction Received in scoreboard comp_b"),UVM_LOW)
    tr.print();
      
    endfunction
    
 
endclass

// Top env connects comp_a export to comp_c imp port.
// Top env connects comp_b export to comp_c imp port.

class my_env extends uvm_env;
  `uvm_component_utils(my_env)
  
  comp_a test_a;
  comp_b test_b;
  comp_c test_c;
  
  function new (string name = "my_env", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
   function void build_phase(uvm_phase phase);
     test_a = comp_a::type_id::create("test_a",this);
     test_b = comp_b::type_id::create("test_b",this);
     test_c = comp_c::type_id::create("test_c",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    test_a.broadcast_port.connect(test_c.comp_a_export);
    test_b.aport_send.connect(test_c.comp_b_export);
    
  endfunction
  
  task run_phase (uvm_phase phase);
  
    
  endtask
  
endclass

class base_test extends uvm_test;

  `uvm_component_utils(base_test)
  
 
  my_env env;

  
  function new(string name = "base_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = my_env::type_id::create("env", this);
  endfunction : build_phase
  
  
   function void end_of_elaboration();
   
    print();
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    uvm_objection objection;
    
    objection = phase.get_objection();
    
    phase.get_objection().set_propagate_mode(1); 
    
    phase.raise_objection(this);
    
    objection.get_objection_total();
    #500;
    
    phase.drop_objection(this);
  endtask
  
endclass : base_test



  initial begin
    run_test("base_test");  
  end  
  
endprogram
