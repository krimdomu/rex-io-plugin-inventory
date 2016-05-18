var inventory_group = new Class({
  Extends: ui_plugin,

  initialize: function(ui) {
    this.parent(ui);
  },

  load: function(force) {
    var self = this;
  },

  remove_group_dialog: function() {
    var group_id = $("#current_group_id").val();
    var group_name = $("#current_group_name").val();
    
    ui.dialog_confirm({
      "id"     : "delete_group_confirm_dialog",
      "title"  : "Really delete group <b>" + group_name + "</b>?",
      "text"   : "This action will permanently delete <b>" + group_name + "</b>.",
      "button" : "Delete",
        "ok": function() {
          rexio.call("DELETE",
                    "1.0",
                    "inventory",
                    ["group", group_id],
                    function(data) {
                      if(data.ok != true || data.ok == 0) {
                        $.pnotify({
                          "title" : "Error deleting group",
                          "text"  : "Can't delete group "
                                      + "<b>" + group_name + "</b>"
                                      + "<br /><br /><b>Error</b>: " + data["error"],
                          "type"  : "error"
                        });
                      }
                      else {
                        $.pnotify({
                          "title" : "Group deleted",
                          "text"  : "Group "
                                      + "<b>" + group_name + "</b>"
                                      + " deleted.",
                          "type"  : "info"
                        });
                      }

                      // load server list.
                      //self.ui.redirect_to("inventory");
                    }
                  );
        },
      "cancel": function() {}
    });
  },
  
  add_group_dialog: function() {
    $("#group_name").val("");
    $("#add_group").dialog("option", "title", "New Group");
    $("#add_group").dialog("open");
  },

  click_add_group_cancel: function() {
    $("#group_name").val("");
    $("#add_group").dialog("close");
  },

  click_add_group: function() {
    var self = this;

    rexio.call("POST",
      "1.0",
      "inventory",
      [
        "group", null,
        "ref", {
          "name": $("#group_name").val(),
          "parent_id": $("#current_group_id").val()
        }
      ],
      function(data) {
        if(data['ok']) {
          $.pnotify({
            "title" : "New group created",
            "text"  : "New group "
                        + "<b>" + $("#group_name").val() + "</b>"
                        + " created. ",
            "type"  : "info"
          });

        }
        else {
          $.pnotify({
            "title" : "Error "
                        + " creating "
                        + " group",
            "text"  : "Can't "
                        + " create new "
                        + " group "
                        + "<b>" + $("#group_name").val() + "</b>"
                        + "<br /><br /><b>Error</b>: " + data['error'],
            "type"  : "error"
          });
        }
      });
  },

  __END__: ""
});

ui.register_plugin(
    {
      "object" : "inventory/group"
    }
  );
