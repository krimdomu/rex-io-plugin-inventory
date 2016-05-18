var inventory = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
    this.asset_id = 0;
  },

  load: function(force) {
    var self = this;

    /*
    self.ui.register_route(new RegExp('^inventory/asset/(\\d+)'), function(idx) {
      console.log("requesting inventory idx: " + idx[0]);
      self.asset_id = idx[0];

      self.ui.load_page(
        {
          "link" : "/inventory/asset/" + idx[0],
          "cb"   : function() {
            self.load_tabs(function() {
              prepare_tab();
              activate_tab($(".tab-pane:first"));
              console.log("inventory/asset page loaded!");
            });
          }
        }
      );
    });

    self.ui.load_page(
      {
        "link" : "/inventory",
        "cb"   : function() {
          prepare_tab();
          activate_tab($(".tab-pane:first"));

          console.log("Inventory page loaded!");
        }
      }
    ); 
    */
  },
  
  open_tree_node: function(node) {
    console.log("inventory.js: open_tree_node");
    console.log(node);
  },
  
  clicked_tree_node: function(event, node) {
    console.log("inventory.js: clicked_tree_node");
    console.log(node);

    ui.require_js(
        {
          "js": "/js/inventory/asset.js",
          "cb": function() {
            ui.require_js(
                {
                  "js": "/js/inventory/group.js",
                  "cb": function() {
                    ui.load_page(
                        {
                          "link" : "/inventory/" + node.id,
                          "cb"   : function() {
                            prepare_tab();
                            activate_tab($(".tab-pane:first"));

                            console.log("Inventory page loaded!");
                          }
                        }
                      ); 
                  }
                });
          }
        }
      );
  },
  
  onload: function() {
  },

  __END__: ""

});

ui.register_plugin(
  {
    "object" : "inventory"
  }
);
