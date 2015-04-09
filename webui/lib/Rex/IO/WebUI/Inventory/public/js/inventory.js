var inventory = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
  },

  load: function(force) {
    this.ui.load_page(
      {
        "link" : "/inventory",
        "cb"   : function() {
          prepare_tab();
          activate_tab($(".tab-pane:first"));

          console.log("Inventory page loaded!");
        }
      }
    );
  }
});

ui.register_plugin(
  {
    "object" : "inventory"
  }
);
