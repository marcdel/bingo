// Used in the new session form to set the "player_color" hidden 
// input field value to the selected color. Also updates the 
// background color of the "player_name" input field, just for fun!

$("#color-selector .color").click(function() {
  $(this)
    .addClass("selected")
    .siblings()
    .removeClass("selected")

  const color = $(this).css("background-color")

  $("#player_color").val(color)

  $("#player_name").css("border-color", color)
})
